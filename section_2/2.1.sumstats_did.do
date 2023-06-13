* Project: Impact of firm-level covid rescue policies
* Authors: Glenn Magerman & Dieter Van Esbroeck
* Version: 02/06/23

*-----------------------------
**# Summary statistics for DID
*-----------------------------
use "generated_data/data_didyearly", clear

*-------------------------------------------
**# 1. Summary statistics, Treated/Untreated
*-------------------------------------------
// for year = 2019
keep if year == 2019

// prepare productivity variables
gen prod_fte = nav/fte
gen sales_fte = turnover/fte

// check groups
tab year eversupport

// table 2
foreach var in fte nav turnover prod_fte sales_fte {
bys eversupport: su `var', detail
}

*---------------------------------------------------------------
**# 2. Summary statistics, Treated/Untreated, demeaned by sector
*---------------------------------------------------------------
// prepare variables
foreach var in nav turnover sales_fte emp {
gen ln`var' = ln(`var')
}

// prepare sector as a numerical variable
drop nacerev2_recoded
tostring nacerev2, gen(nacerev2_recoded)
replace nacerev2_recoded = "5009" if nacerev2 == 5 | nacerev2 == 6 | nacerev2 == 7 | nacerev2 == 8 | nacerev2 == 9 //mining and quarrying
replace nacerev2_recoded = "110012" if nacerev2 == 11 | nacerev2 == 12 //manufacture of tobacco products added to manufacture of beverages
replace nacerev2_recoded = "190021" if nacerev2 == 19 | nacerev2 == 20 | nacerev2 == 21  //manufacture of coke and refined petroleum products added to manufacture of chemicals and chemical products
replace nacerev2_recoded = "360039" if nacerev2 == 36 | nacerev2 == 37 |nacerev2 == 38 | nacerev2 == 39 //water collection, treatment and supply added to sewerage
replace nacerev2_recoded = "640066" if nacerev2 == 64 | nacerev2 == 65 | nacerev2 == 66 // insurance activities added to financial service activities
destring nacerev2_recoded, replace

// demean by sector
foreach var in fte emp nav turnover prod_fte sales_fte {
qui reg ln`var' i.nacerev2_recoded
predict r_ln`var', resid
}

// table 14
foreach var in fte emp nav turnover prod_fte sales_fte {
bys eversupport: su r_ln`var', detail
}

*-----------------------------------------------------
**# 3. Distribution of growth rates, Treated/Untreated
*-----------------------------------------------------
use "generated_data/data_eventstudyquarterly", clear

// prepare growth rates
xtset vat quarter
foreach var in lnsales lnfte lnemp lnsales_fte {
gen gr_`var' = `var' - l3.`var'
}

// look at evolution in 2019
keep if quarter == 239

// figure 14
gen gr_lnsales_t = gr_lnsales if eversupport == 1
gen gr_lnsales_ut = gr_lnsales if eversupport == 0
twoway kdensity gr_lnsales_t || kdensity gr_lnsales_ut, graphregion(fcolor(white)) legend(label(1 "treated")  label(2 "never treated")) xtitle("dln(sales)")
*graph export "results/EER-D-22-01148_Figure_14a.eps", replace
gen gr_lnfte_t = gr_lnfte if eversupport == 1
gen gr_lnfte_ut = gr_lnfte if eversupport == 0
twoway kdensity gr_lnfte_t || kdensity gr_lnfte_ut, graphregion(fcolor(white)) legend(label(1 "treated")  label(2 "never treated")) xtitle("dln(FTE)")
*graph export "results/EER-D-22-01148_Figure_14b.eps", replace
gen gr_emp_t = gr_lnemp if eversupport == 1
gen gr_emp_ut = gr_lnemp if eversupport == 0
twoway kdensity gr_emp_t  || kdensity gr_emp_ut, graphregion(fcolor(white)) legend(label(1 "treated")  label(2 "never treated")) xtitle("dln(head count)")
*graph export "results/EER-D-22-01148_Figure_14c.eps", replace
gen gr_sales_fte_t = gr_lnsales_fte if eversupport == 1
gen gr_sales_fte_ut = gr_lnsales_fte if eversupport == 0
twoway kdensity gr_sales_fte_t  || kdensity gr_sales_fte_ut, graphregion(fcolor(white)) legend(label(1 "treated")  label(2 "never treated")) xtitle("dln(sales/FTE)")
*graph export "results/EER-D-22-01148_Figure_14d.eps", replace

clear
