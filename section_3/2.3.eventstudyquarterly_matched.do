* Project: Impact of firm-level covid rescue policies
* Authors: Glenn Magerman & Dieter Van Esbroeck
* Version: 02/06/23

*----------------------------------------------------------
**# quarterly event study results with a matching procedure
*----------------------------------------------------------
// nearest neighbour matching algorithm
use "tmp/estdata_eventstudy", clear

// choose variables to match on
global matching_variables lnfte lnk

// create variable for pre-treatment sample
gen pretreated=I_pre1+I_pre2+I_pre3+I_pre4

// create variables for treatment samples
gen tquarter= quarter if I_post1==1
bysort vat (quarter): egen treatmentquarter = min(tquarter)
drop tquarter
tabulate treatmentquarter , gen(treatment_sample_)
foreach v of varlist treatment_sample_1 treatment_sample_2 treatment_sample_3{
	replace `v'=0 if missing(`v')
}
ren (treatment_sample_1 treatment_sample_2 treatment_sample_3)(treatment_sample_241 treatment_sample_242 treatment_sample_243)
	

// implement nearest neighbour matching algorithm
// Separately for each 'batch' of treatment quarters, because we average over pretreatment period
// loop over all treatment periods
levelsof quarter if I_post1 == 1
foreach quarter in `r(levels)' {
	local treatquarter = `quarter'
	// Save master data
	tempfile fulldata
	save `fulldata'
	
	// generate variables collecting results
	gen str matchID_`quarter' = ""
	gen matchweight_`quarter' = .
	gen matchdistance_`quarter' = .
		
	// define matching dataset
	drop if treatment_sample_`quarter' == 0 & eversupport == 1
	drop if quarter >= `treatquarter'
							
	global matching_variables_means	// Global collecting variable means of matching variables 
	foreach v in $matching_variables {	// Compute pretreatment average value of all matching variables
		bysort vat (quarter): egen `v'_m =mean(`v') 
		global matching_variables_means $matching_variables_means `v'_m
	}

	// implement matching
	duplicates drop vat, force
	ultimatch $matching_variables_means , treated(treatment_sample_`quarter') exact(nacerev2_recoded) copy //draw(5) //copy includes matches multiple times, see lines under to include these in regressions as well
	tab quarter
	unique vat
		
 	// keep matched couples
	replace matchID_`quarter' = "`treatquarter'_"+string(_match) if _match != . & matchID_`quarter' == ""
	replace matchweight_`quarter' = _weight if _weight != . & matchweight_`quarter' == .
	replace matchdistance_`quarter' = _distance if _distance != . & matchdistance_`quarter' == .
		
	// save results
	tempfile matched_pairs
	keep vat matchID_`quarter' matchweight_`quarter' matchdistance_`quarter'
	drop if matchID_`quarter' == ""
	bys vat: gen copy_obs_`quarter' = _N
	duplicates drop vat, force
	save `matched_pairs'
		
	unique vat
		
	// restore full data and add results
	use `fulldata', clear
	merge m:1 vat using `matched_pairs'
	drop _merge
		
	unique matchID_`quarter'
	count if mi(matchID_`quarter')
}
		
// list all matched pairs
levelsof quarter if I_post1 == 1
foreach quarter in `r(levels)' {
	preserve
	keep if matchID_`quarter' != ""
	duplicates drop matchID_`quarter' vat, force
	sort matchID_`quarter' quarter eversupport
	noi list matchID_`quarter' quarter vat eversupport nacerev2_recoded matchweight_`quarter' matchdistance_`quarter' in 1/50
	restore
}
					
// save matched pairs
levelsof quarter if I_post1 == 1
foreach quarter in `r(levels)' {
			
	// Data of pairs
	preserve 
	keep if matchID_`quarter' != ""
	rename matchID_`quarter' matchID
	rename matchweight_`quarter' matchweight
	rename matchdistance_`quarter' matchdistance
	sort matchID eversupport quarter
	save matched_sample_`quarter', replace
	restore
			
	// IDs of pairs
	preserve
	duplicates drop vat matchID_`quarter', force
	keep vat matchID_`quarter' eversupport matchweight_`quarter' matchdistance_`quarter'
	keep if matchID_`quarter' != ""
	rename matchID_`quarter' matchID
	rename matchweight_`quarter' matchweight
	rename matchdistance_`quarter' matchdistance
	sort matchID eversupport
	save "tmp/treatedandmatchedcontrolfirmIDs", replace
	restore
}

// collect sample of treated+controls
levelsof quarter if I_post1 == 1
clear
foreach quarter in `r(levels)' {
	append using matched_sample_`quarter'
	erase matched_sample_`quarter'.dta					
}

// check comparability of neighbours
/*
// across all treatment quarters
// graphically
// taking into account treatment quarter
gen matched_sample = substr(matchID, 1,4)
destring matched_sample, replace
preserve
drop if matchID == ""
expand matchweight // workaround to take into account controls appearing multiple times
collapse (mean) $matching_variables , by(eversupport quarter matched_sample)
levelsof matched_sample 
foreach sample in `r(levels)' {
foreach depvar in $matching_variables {
twoway 	(line `depvar' quarter if eversupport == 0 & matched_sample==`sample', lp(dash)) ///
(line `depvar' quarter if eversupport == 1 & matched_sample==`sample',  ) ///
, legend(order(2 "Treated" 1 "Control")) title(`depvar') ///
ytitle("Average") xtitle("quarter") graphregion(color(white)) bgcolor(white) xline(`sample')
graph export $filename/figure1_`depvar'_`sample'.pdf, replace
}
}
restore

// statistically		
// for each treatment quarter separately
preserve
bysort matchID: egen treatquarter = max(treatmentquarter)
gen pretreatment = 0
replace pretreatment = 1 if quarter < treatquarter
expand matchweight // 
levelsof matched_sample 
tempname postMeans
tempfile means
postfile `postMeans' ///
str100 varname quarter TreatedN TreatedMeans TreatedSE ControlN ControlMeans ControlSE diffMeans pMeans using "`means'", replace
foreach sample in `r(levels)' {
	foreach var in $matching_variables {
		local name: variable label `var'
		ttest `var' if pretreatment == 1 & matched_sample == `sample', by(eversupport) unequal
		post `postMeans' ("`var'") (`sample') (round(r(N_1),.001)) 	(round(r(mu_1),.001)) (round(r(sd_1),.001)) (round(r(N_2),.001)) (round(r(mu_2),.001)) (round(r(sd_2),.001)) (round(r(mu_2)-r(mu_1),.001)) (round(r(p),.001))
	}
}
postclose `postMeans'
restore

// across all treatment quarters
preserve
bysort matchID: egen treatquarter = max(treatmentquarter)
gen pretreatment = 0
replace pretreatment = 1 if quarter < treatquarter
expand matchweight 
tempname postMeans
tempfile means
postfile `postMeans' ///
str100 varname TreatedN TreatedMeans TreatedSE ControlN ControlMeans ControlSE diffMeans pMeans using "`means'", replace
foreach var in $matching_variables {
	local name: variable label `var'
	ttest `var' if pretreatment == 1, by(eversupport) unequal
	post `postMeans' ("`var'") (round(r(N_1),.001)) (round(r(mu_1),.001)) (round(r(sd_1),.001)) (round(r(N_2),.001)) (round(r(mu_2),.001)) (round(r(sd_2),.001)) (round(r(mu_2)-r(mu_1),.001)) (round(r(p),.001))
}
postclose `postMeans'
restore
preserve
use `means', clear
format *Means %3.2f
list in 1/100
export excel using "results/table_overall.xls", firstrow(variables) replace	restore
*/

// drop irrelevant variables 
drop  matchID_* matchweight_* matchdistance_*

*-----------------------------
**# 2. regressions and results
*-----------------------------
// event study regression
eststo : reghdfe lnsales_fte I_pre4 I_pre3 I_pre2 I_pre1 I_post1 I_post2 I_post3 I_post4 I_post5 I_post6 I_post7, absorb(vatFE=vat indFE=indqFE) cluster(vat)

// store coefficients
estimates store lnsales_fte_coef
keep if e(sample)
regsave using "tmp/reg_lnsales_fte", ci level(95) replace
	
// create graph with results
use "tmp/reg_lnsales_fte", clear
drop if var=="_cons"
drop if stderr ==0
gen t=.
forv k=1/7 {
	 replace t = -`k' if var=="I_pre`k'"
	 replace t = `k' if var=="I_post`k'"
}
replace t = 0 if var == "I_t0"

// figure 8
twoway (scatter coef t) (rspike ci_lower ci_upper t, legend(label(1 "Coefficient")) legend(label(2 "95% CI"))), yline(0) xlabel(-4(1)7) ylabel(-0.10(0.05)0.10) xtitle("") graphregion(fcolor(white)) name("lnsales_fte", replace)
*graph export "results/EER-D-22-01148_Figure_8.eps", replace

clear
