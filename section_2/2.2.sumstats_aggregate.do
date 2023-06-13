* Project: Impact of firm-level covid rescue policies
* Authors: Glenn Magerman & Dieter Van Esbroeck
* Version: 02/06/23

*--------------------------------------------
**# Summary statistics for aggregate analysis
*--------------------------------------------
use  "generated_data/data_aggregate", clear

// temove firms that have gaps (years missing) in their data (creates artificial entry and exit)
su year
bys vat: egen minyear = min(year)
bys vat: egen maxyear = max(year)
label var minyear "First year firm occurs in the dataset"
label var maxyear "Last year firm occurs in the dataset"
bys vat: gen n_years_shouldbe = maxyear - minyear + 1
bys vat: gen n_years = _N
drop if n_years != n_years_shouldbe

*------------------------
**# 1. Summary statistics
*------------------------
// number of observations and firms
unique vat

// prepare variables
gen prod_fte = nav/fte

// table 3
sum fte nav prod_fte tfa, detail

*-----------------------------------
**# 1. Aggregate productivity growth
*-----------------------------------
// select productivity measure and weight measure for decompositions
gen LP = lnprod_fte_norm
gen weight = fte

// create market shares
bys year: egen weight_t = total(weight)
gen ms_it = weight / weight_t

// create aggregate productivity variable
bys year: egen aggr_lp_t = total(LP * ms_it)

// create growth variable
xtset vat year
gen lag_aggr_lp_t = l.aggr_lp_t
bys year: gen gr_aggr_lp = aggr_lp_t - lag_aggr_lp_t

// collapse to yearly data
preserve
collapse (sum) nav fte (mean) gr_aggr_lp, by(year)

//create aggregate logarithms
gen lnfte = ln(fte)
gen lnva = ln(nav)

// create growth variables
tsset year
gen gr_lnfte = d.lnfte
gen gr_lnva = d.lnva

// label variables
label var gr_aggr_lp "value added/FTE"
label var gr_lnva "value added"
label var gr_lnfte "FTE"

// figure 4
twoway line gr_aggr_lp gr_lnva gr_lnfte  year, graphregion(fcolor(white)) ytitle(Log-growth)
*graph export "results/EER-D-22-01148_Figure_4.eps", replace
restore
*-----------------------------------
**# 3. Summary statistics, by sector
*-----------------------------------
// prepare broad sectors
gen sector = "1-9" if nacerev2 >= 1 & nacerev2 <= 9 //primary and extraction
replace sector = "10-33" if nacerev2 >= 10 & nacerev2 <= 33 //manufacturing
replace sector = "35-39" if nacerev2 >= 35 & nacerev2 <= 39 //utilities
replace sector = "41-43" if nacerev2 >= 41 & nacerev2 <= 43 //construction
replace sector = "45-82" if nacerev2 >= 45 & nacerev2 <= 82 //market services

// table 13
preserve
keep if year == 2019
bys sector: su fte, detail
egen total_fte = total(fte), by(sector)
keep vat sector total_fte
duplicates drop
collapse (count) vat (mean) total_fte, by(sector) 
list
restore

// table 15
preserve
egen mean_lnprod_fte_ACF = mean(lnprod_fte_ACF), by(nacerev2_recoded)
egen mean_lnprod_fte = mean(lnprod_fte), by(nacerev2_recoded)
keep nacerev2_recoded mean_lnprod_fte*
duplicates drop
sort nacerev2_recoded
list
*export excel "results/avg_prod_industry.xlsx", firstrow(var) replace
restore
