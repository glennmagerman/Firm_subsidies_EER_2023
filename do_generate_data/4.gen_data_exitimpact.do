* Project: Impact of firm-level covid rescue policies
* Authors: Glenn Magerman & Dieter Van Esbroeck
* Version: 02/06/23

*-------------------------------------------------------------
**# generate random data for the quarterly event study results
*-------------------------------------------------------------
global nfirms = 20000
set seed 111765

forvalues t = 241/243 {
	clear
	set obs $nfirms	
	gen quarter = `t'
	format quarter %tq
	
	// balanced panel (for unbalanced draw unif)
	gen vat = _n				
	
	// firm chars
	foreach x in k nav {			// firm chars
		gen `x' = floor(exp(rnormal()*5) + 1) + 2000
	}
	foreach x in fte emp {
		gen `x' = floor(exp(rnormal()) + 1) + 1
	}
	gen debt_asset2019 = runiform() + 0.01
	gen age = 100*runiform() + 0.01
	
	// firm chars in logarithms	
	gen lnprod_fte = ln(nav/fte)
	gen lnfte = ln(fte)
	gen lnage = ln(age)
	drop nav fte age
	
	// industry
	gen nacerev2 = 1 + int((82)*runiform()) 
	
	// dummy indicating a firm got support or got rejected
	gen random = runiform()
	sort random
	gen dummy_support = _n >= 15000
	gen declinedsupport = _n <= 5000
	
	// dummy indicating a firm exited the market
	gen random2 = runiform()
	sort random2
	gen exiting = _n <= 1000
	
	drop random*
	
	save "tmp/firms_`t'", replace						
}

// append datasets and create support variables
use "tmp/firms_241", clear
forvalues t = 242/243 {
	append using  "tmp/firms_`t'"
}
	
// drop firms that exited the previous quarter
xtset vat quarter
drop if l.exiting == 1 | l.l.exiting == 1
	
// avoid firms switching industries
sort vat quarter
gen tmp_remove = 1 if vat == vat[_n-1] & nacerev2 != nacerev2[_n-1] 
bys vat: egen tmp_remove1 = total(tmp_remove)
gen dec_outlier_ind_switch = (tmp_remove1 > 0)
drop tmp*
by vat (quarter), sort: replace nacerev2 = nacerev2[1] if dec_outlier_ind_switch == 1
drop dec_outlier_ind_switch
	
// reclassification of industries
tostring nacerev2, gen(nacerev2_recoded)
replace nacerev2_recoded = "5009" if nacerev2 == 5 | nacerev2 == 6 | nacerev2 == 7 | nacerev2 == 8 | nacerev2 == 9 //mining and quarrying
replace nacerev2_recoded = "110012" if nacerev2 == 11 | nacerev2 == 12 //manufacture of tobacco products added to manufacture of beverages
replace nacerev2_recoded = "190021" if nacerev2 == 19 | nacerev2 == 20 | nacerev2 == 21  //manufacture of coke and refined petroleum products added to manufacture of chemicals and chemical products
replace nacerev2_recoded = "360039" if nacerev2 == 36 | nacerev2 == 37 |nacerev2 == 38 | nacerev2 == 39 //water collection, treatment and supply added to sewerage
replace nacerev2_recoded = "640066" if nacerev2 == 64 | nacerev2 == 65 | nacerev2 == 66 // insurance activities added to financial service activities
destring nacerev2_recoded, replace
drop nacerev2
	
save  "generated_data/data_exitimpact", replace

clear
