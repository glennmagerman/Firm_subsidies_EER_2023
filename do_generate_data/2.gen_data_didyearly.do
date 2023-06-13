* Project: Impact of firm-level covid rescue policies
* Authors: Glenn Magerman & Dieter Van Esbroeck
* Version: 02/06/23

*--------------------------------------------------
**# generate random data for the yearly did results
*--------------------------------------------------
// choose amount of firms
global nfirms = 20000
set seed 111765

// create datasets by year
forvalues t = 2019/2021 {
	clear
	set obs $nfirms	
	gen year = `t'
	
	// balanced panel (for unbalanced draw unif)
	gen vat = _n				
	
	// firm chars
	foreach x in nav turnover {			// firm chars
		gen `x' = floor(exp(rnormal()*5) + 1) + 2000
	}
	foreach x in fte emp {
		gen `x' = floor(exp(rnormal()) + 1) + 1
	}
	
	// firm chars in logarithms
	gen lnprod_fte_norm = ln(nav/fte)	
	gen lnsales_fte_norm = ln(turnover/fte)
	gen lnfte = ln(fte)
	gen lnva = ln(nav)
	gen lnsales = ln(turnover)
	
	//industry
	gen nacerev2 = 1 + int((82)*runiform()) 
	
	//dummy indicating a firm got support
	gen random = runiform()
	sort random
	gen dummy_support = _n <= 15000
	drop random
	
	save "tmp/firms_`t'", replace						
}

// append datasets and create support variables
use "tmp/firms_2019", clear
forvalues t = 2020/2021 {
	append using  "tmp/firms_`t'"
}
	
// support variables
replace dummy_support = 0 if year == 2019 | year == 2021 
bys vat (year): gen sum_support = sum(dummy_support)
replace dummy_support = 1 if sum_support >= 1
egen temp = max(sum_support), by(vat)
gen eversupport=1 if temp!=0
replace eversupport=0 if eversupport==.
drop sum_support temp
	
// premium variables
foreach x in premium1 premium2 premium3 premium4 premium5 { //premium variables
	gen `x' = 0
	gen random = runiform()
	sort random
	replace `x' = (_n >= 45000 & dummy_support == 1)
	drop random
}
replace premium1 = 1 if (dummy_support == 1 & premium1 == 0 & premium2 == 0 & premium3 == 0 & premium4 == 0 & premium5 == 0)
	
// avoid firms switching industries
sort vat year
gen tmp_remove = 1 if vat == vat[_n-1] & nacerev2 != nacerev2[_n-1] 
bys vat: egen tmp_remove1 = total(tmp_remove)
gen dec_outlier_ind_switch = (tmp_remove1 > 0)
drop tmp*
by vat (year), sort: replace nacerev2 = nacerev2[1] if dec_outlier_ind_switch == 1
drop dec_outlier_ind_switch
	
// reclassification of industries
tostring nacerev2, gen(nacerev2_recoded)
replace nacerev2_recoded = "5t9" if nacerev2 == 5 | nacerev2 == 6 | nacerev2 == 7 | nacerev2 == 8 | nacerev2 == 9 //mining and quarrying
replace nacerev2_recoded = "11t12" if nacerev2 == 11 | nacerev2 == 12 //manufacture of tobacco products added to manufacture of beverages
replace nacerev2_recoded = "19t21" if nacerev2 == 19 | nacerev2 == 20 | nacerev2 == 21  //manufacture of coke and refined petroleum products added to manufacture of chemicals and chemical products
replace nacerev2_recoded = "36t39" if nacerev2 == 36 | nacerev2 == 37 |nacerev2 == 38 | nacerev2 == 39 //water collection, treatment and supply added to sewerage
replace nacerev2_recoded = "64t66" if nacerev2 == 64 | nacerev2 == 65 | nacerev2 == 66 // insurance activities added to financial service
	
save  "generated_data/data_didyearly", replace

clear
