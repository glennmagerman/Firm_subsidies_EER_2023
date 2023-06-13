* Project: Impact of firm-level covid rescue policies
* Authors: Glenn Magerman & Dieter Van Esbroeck
* Version: 02/06/23

*--------------------------------------------------------------------------------
**# results for Melitz and Polanec (2015) decomposition using labour productivity
*--------------------------------------------------------------------------------

*-------------------------------
**# 1. Load and prepare the data
*-------------------------------
use  "generated_data/data_aggregate", clear

// choose productivity (tfp) measure
gen TFP = lnprod_fte_norm

// choose variable that serves as market share
gen weight = fte 

// defining survivors, entry and exit
xtset vat year
gen surv = (year == year[_n-1] + 1   &   vat == vat[_n-1])
gen entry = (surv == 0)
gen exit = 0 if year == year[_n+1] - 1 & vat == vat[_n+1]
replace exit = 1 if exit == .
label var surv "Incumbent"
label var entry "Entering firm"
label var exit "Exiting firm (equal to 1 the last year the firm is active)"

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

// to define surviving, entering and exiting firms, use 'active'
gen active = 0
gen lag_active = 0
replace active = 1 if surv == 1 | entry == 1
replace lag_active = 1 if surv == 1 | l.exit == 1

*--------------------------------
**# 2. create decomposition terms
*--------------------------------

// 2.1 all firms
// size
bys year: egen weight_t = total(weight) 	if active == 1
bys year: egen avg_weight_t = mean(weight) 	if active == 1
gen ms_it = weight / weight_t
bys year: egen avg_ms_it = mean(ms_it)		if active == 1

xtset vat year
gen lag_weight = l.weight
gen lag_ms_it = l.ms_it
bys year: egen lag_weight_t = total(lag_weight)

// productivity
bys year: egen aggr_tfp_t = total(TFP * ms_it) if active == 1
xtset vat year
gen lag_aggr_tfp_t = l.aggr_tfp_t

bys year: egen avg_tfp_t = mean(TFP) if active == 1

// covariance
bys year: egen cov_t = total((TFP - avg_tfp_t)*(ms_it - avg_ms_it)) if active == 1

// test olley and pakes (1996) decomposition
/*xtset vat year
gen diff_avg_tfp = avg_tfp_t - l.avg_tfp_t
gen diff_cov_tfp = cov_t - l.cov_t
gen diff_aggr_tfp = aggr_tfp_t - lag_aggr_tfp_t
gen res = diff_aggr_tfp - (diff_avg_tfp + diff_cov_tfp)
tabstat diff_avg_tfp diff_cov_tfp diff_aggr_tfp res, by(year)*/

// 2.2 surviving firms
// size
bys year: egen weight_surv_t = total(weight) 		if active == 1 & lag_active == 1
bys year: egen avg_weight_surv_t = mean(weight)		if active == 1 & lag_active == 1
gen ms_it_surv = weight / weight_surv_t				if active == 1 & lag_active == 1
bys year: egen avg_ms_it_surv = mean(ms_it_surv) 	if active == 1 & lag_active == 1
	
bys year: egen lag_weight_surv_t = total(lag_weight) 	if lag_active == 1 & active == 1
bys year: egen avg_lag_weight_surv_t = mean(lag_weight) if lag_active == 1 & active == 1
gen lag_ms_it_surv = lag_weight / lag_weight_surv_t		if lag_active == 1 & active == 1 
bys year: egen avg_lag_ms_it_surv = mean(lag_ms_it_surv) if lag_active == 1 & active == 1 
	
// productivity
bys year: egen tfp_surv_t = total(TFP)				if active == 1 & lag_active == 1
bys year: egen tmp_avg_tfp_surv_t = mean(TFP)		if active == 1 & lag_active == 1
bys year: egen avg_tfp_surv_t = mean(tmp_avg_tfp_surv_t)
	
xtset vat year
gen lag_tfp = L.TFP
bys year: egen lag_tfp_surv_t = total(lag_tfp)			if active == 1 & lag_active == 1
bys year: egen tmp_avg_lag_tfp_surv_t = mean(lag_tfp)	if active == 1 & lag_active == 1
bys year: egen avg_lag_tfp_surv_t = mean(tmp_avg_lag_tfp_surv_t)
	
// covariance 
bys year: egen tmp_cov_surv_t = total((TFP - avg_tfp_surv_t) * (ms_it_surv - avg_ms_it_surv))	 					if active == 1 & lag_active == 1
bys year: egen cov_surv_t = mean(tmp_cov_surv_t)
bys year: egen tmp_lag_cov_surv_t = total((lag_tfp - avg_lag_tfp_surv_t) * (lag_ms_it_surv - avg_lag_ms_it_surv)) 	if active == 1 & lag_active == 1
bys year: egen lag_cov_surv_t = mean(tmp_lag_cov_surv_t)
	
// aggregate productivity
bys year: egen tmp_aggr_tfp_surv_t = total(TFP * ms_it_surv) if active == 1 & lag_active == 1
bys year: egen aggr_tfp_surv_t = mean(tmp_aggr_tfp_surv_t)
xtset vat year
bys year: egen tmp_lag_aggr_tfp_surv_t = total(lag_tfp * lag_ms_it_surv) if active == 1 & lag_active == 1
bys year: egen lag_aggr_tfp_surv_t = mean(tmp_lag_aggr_tfp_surv_t)

// 2.3 entering firms

// size
bys year: egen weight_entry_t = total(weight)		if active == 1 & lag_active == 0
bys year: egen avg_weight_entry_t = mean(weight)	if active == 1 & lag_active == 0
gen ms_entry_t = weight_entry_t / weight_t			if active == 1 & lag_active == 0
gen ms_it_entry = weight / weight_entry_t			if active == 1 & lag_active == 0
bys year: egen avg_ms_it_entry = mean(ms_it_entry)	if active == 1 & lag_active == 0
	
// productivity
bys year: egen tfp_entry_t = total(TFP)				if active == 1 & lag_active == 0
bys year: egen avg_tfp_entry_t = mean(TFP)			if active == 1 & lag_active == 0

// covariance
bys year: egen cov_entry_t = total((TFP - avg_tfp_entry_t) * (ms_it_entry - avg_ms_it_entry)) 	if active == 1 & lag_active == 0

// aggregate productivity
bys year: egen aggr_tfp_entry_t = total(TFP * ms_it_entry) if active == 1 & lag_active == 0
	
// 2.4 exiting firms

// size
bys year: egen weight_exit_t = total(lag_weight)	if active == 0 & lag_active == 1
bys year: egen avg_weight_exit_t = mean(lag_weight)	if active == 0 & lag_active == 1
gen ms_exit_t = weight_exit_t / lag_weight_t		if active == 0 & lag_active == 1
gen ms_it_exit = lag_weight / weight_exit_t			if active == 0 & lag_active == 1
bys year: egen avg_ms_it_exit = mean(ms_it_exit)	if active == 0 & lag_active == 1

// productivity
bys year: egen tfp_exit_t = total(lag_tfp)			if active == 0 & lag_active == 1
bys year: egen avg_tfp_exit_t = mean(lag_tfp)		if active == 0 & lag_active == 1
	
// covariance
bys year: egen cov_exit_t = total((lag_tfp - avg_tfp_exit_t) * (ms_it_exit - avg_ms_it_exit)) if active == 0 & lag_active == 1
	
// aggregate productivity
bys year: egen aggr_tfp_exit_t = total(lag_tfp * ms_it_exit) if active == 0 & lag_active == 1
	
// 2.5 construction of decomposition terms
	
// aggregate TFP growth
bys year: gen gr_aggr_tfp = aggr_tfp_t - lag_aggr_tfp_t
	
// surviving firms
bys year: gen dif_mean_tfp_surv = avg_tfp_surv_t - avg_lag_tfp_surv_t
bys year: gen dif_cov_tfp_surv  = cov_surv_t - lag_cov_surv_t
bys year: gen dif_tfp_surv = aggr_tfp_surv_t - lag_aggr_tfp_surv_t
	
// entering firms
bys year: gen dif_mean_entry_surv = ms_entry_t * (avg_tfp_entry_t - avg_tfp_surv_t)
bys year: gen dif_cov_entry_surv  = ms_entry_t * (cov_entry_t - cov_surv_t)
bys year: gen dif_tfp_entry = ms_entry_t * (aggr_tfp_entry_t - aggr_tfp_surv_t)
	
// exiting firms
bys year: gen dif_mean_surv_exit = ms_exit_t * (avg_lag_tfp_surv_t - avg_tfp_exit_t)
bys year: gen dif_cov_surv_exit  = ms_exit_t * (lag_cov_surv_t - cov_exit_t) 
bys year: gen dif_tfp_exit = ms_exit_t * (lag_aggr_tfp_surv_t - aggr_tfp_exit_t)

*----------------------------------
**# 3. yearly decomposition results
*----------------------------------
collapse(mean) gr_aggr_tfp dif_mean_tfp_surv dif_cov_tfp_surv dif_tfp_surv cov_surv_t dif_mean_entry_surv dif_cov_entry_surv cov_entry_t dif_tfp_entry 	  dif_mean_surv_exit dif_cov_surv_exit cov_exit_t dif_tfp_exit, by(year)

// do some tests on residuals to see if decomposition terms sum to zero
// in practice they are very close to zero, 10+ numbers behind the comma
gen restest = gr_aggr_tfp - (dif_mean_tfp_surv + dif_cov_tfp_surv + dif_mean_entry_surv + dif_cov_entry_surv + dif_mean_surv_exit + dif_cov_surv_exit)
gen restest2 = dif_tfp_surv - (dif_mean_tfp_surv + dif_cov_tfp_surv)
gen restest3 = dif_tfp_entry - (dif_mean_entry_surv + dif_cov_entry_surv)
gen restest4 = dif_tfp_exit - (dif_mean_surv_exit + dif_cov_surv_exit)
gen restest5 = gr_aggr_tfp -  (dif_mean_tfp_surv + dif_cov_tfp_surv + dif_tfp_entry + dif_tfp_exit)
tabstat restest restest2 restest3 restest4 restest5, by(year)

// figure 5 results, table 17
tabstat gr_aggr_tfp dif_mean_tfp_surv dif_cov_tfp_surv dif_tfp_entry dif_tfp_exit, by(year)
keep year gr_aggr_tfp dif_mean_tfp_surv dif_cov_tfp_surv dif_tfp_entry dif_tfp_exit
*export excel using "results/MP_decomposition_LP", replace firstrow(var)

clear
