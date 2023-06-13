* Project: Impact of firm-level covid rescue policies
* Authors: Glenn Magerman & Dieter Van Esbroeck
* Version: 02/06/23

*----------------------------------------------------------------------------
**# results for Davis and Haltiwanger (1992) job and value added reallocation
*----------------------------------------------------------------------------

*-------------------------------
**# 1. load and prepare the data
*-------------------------------
use  "generated_data/data_aggregate", clear

// choose labour variable
gen labour = fte 

// remove firms that have gaps (years missing) in their data (creates artificial entry and exit)
su year
bys vat: egen minyear = min(year)
bys vat: egen maxyear = max(year)
label var minyear "First year firm occurs in the dataset"
label var maxyear "Last year firm occurs in the dataset"
bys vat: gen n_years_shouldbe = maxyear - minyear + 1
bys vat: gen n_years = _N
drop if n_years != n_years_shouldbe

// expand the dataset
xtset vat year
tsfill, full
gsort vat -year
bysort vat: carryforward minyear, replace
sort vat year
bysort vat: carryforward minyear, replace
sort vat year
bysort vat: carryforward maxyear, replace
gsort vat -year
bysort vat: carryforward maxyear, replace
sort vat year
drop if year < minyear
drop if year > maxyear + 1

// missing labour is set to 0	
xtset vat year
replace labour = 0 if labour == .
replace nav = 0 if nav == .

// generate lagged employment and value added
gen l_labour = l.labour
gen l_nav = l.nav

*----------------------------------------------
**# 2. results for labour and value added flows
*----------------------------------------------
// compute the average size of employment and value added, x_it: 	
gen size = (labour+l_labour)/2
replace size = 0 if missing(size)
gen size2 = (nav+l_nav)/2
replace size2 = 0 if missing(size2)

// generate firm level job and value added flow variables
// gross creation
gen jc = max(labour - l_labour, 0)
gen vc = max(nav - l_nav, 0)

// gross destruction
gen jd = abs(min(labour - l_labour, 0))
gen vd = abs(min(nav - l_nav, 0))

// gross creation, destruction, and reallocation rates
collapse (sum) size jc jd size2 vc vd, by(year) 

// creation rate
gen pos = jc/size 			
gen pos2 = vc/size2			

// destruction rate
gen neg = jd/size		
gen neg2 = vd/size2

// gross reallocation
gen gross = pos + neg		
gen gross2 = pos2 + neg2

// net growth rate
gen net = pos - neg		
gen net2 = pos2 - neg2

// label variables
label var pos "creation rate"
label var pos2 "creation rate"
label var neg "destruction rate"
label var neg2 "destruction rate"
label var gross "gross reallocation rate"
label var gross2 "gross reallocation rate"
label var net "net employment growth"
label var net2 "net value added growth"

// figure 11
line pos neg gross year, graphregion(color(white)) ylabel(0(0.05)0.25)
*graph export "results/EER-D-22-01148_Figure_11.eps", replace

// figure 12
line pos2 neg2 gross2 year, graphregion(color(white)) ylabel(0(0.05)0.25)
*graph export "results/EER-D-22-01148_Figure_12.eps", replace

clear
