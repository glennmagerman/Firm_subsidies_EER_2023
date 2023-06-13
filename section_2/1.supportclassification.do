* Project: Impact of firm-level covid rescue policies
* Authors: Glenn Magerman & Dieter Van Esbroeck
* Version: 02/06/23

*--------------------------------------------
**# Summary statistics for support allocation
*--------------------------------------------

*----------------
**# 1. By premium
*----------------
use "generated_data/VLAIO_support", clear
gen year = yofd(date_payment)
format year %ty
*collapse (sum) support, by(year) //1.7 billion in 2020
keep if year == 2020

// label premia	
bys premium: keep if _n == 1
keep premium
gen premium_label = ""
replace premium_label = "Hindrance premium" if premium == 1
replace premium_label = "Compensation premium" if premium == 2
replace premium_label = "Support premium" if premium == 3
replace premium_label = "Flemish protection mechanism" if premium == 4
replace premium_label = "New Flemish protection mechanism" if premium == 5
save "tmp/premium_labels", replace 

// make graphs
use "generated_data/VLAIO_support", clear
gen year = yofd(date_payment)
format year %ty
keep if year == 2020
keep if support > 0 & !mi(support)
gcollapse (count) nrequests = vat (sum) support, by(premium)
	
// labels	
merge m:1 premium using "tmp/premium_labels", nogen
	
// Figure 1.1 graph number of requests
graph hbar nrequests, over(premium_label, sort(nrequests) descending) ///
ylabel(2e4(2e4)1e5, format(%12.0fc)) ///
ytitle("number of requests paid out") xsize(9) ysize(5) yscale(range(0 120000)) ///
graphregion(fcolor(white))
*graph export "results/EER-D-22-01148_Figure_1a.eps", replace 	

// Figure 1.2 graph total amount of support
replace support = support/1e6
graph hbar support, over(premium_label, sort(support) descending) ///
yl(2e2(2e2)1e3) ytitle("amount paid in million euros") ///
xsize(9) ysize(5) yscale(range(0 1300)) ///
graphregion(fcolor(white))
*graph export "results/EER-D-22-01148_Figure_1b.eps", replace	

*---------------------
**# 2. by NACE 2-digit
*---------------------
use "generated_data/VLAIO_support", clear
gen year = yofd(date_payment)
format year %ty
keep if year == 2020 
collapse (sum) support (first) nace2_short, by(nace2_code)

// figure 2
// sort descending, keep top 10
gsort -support						
drop if nace2_code >= 84
graph hbar support in 1/10, over(nace2_short, sort(support) label(labsize(small)) descending) ///
ytitle("Total support in millions of euros") ///
xsize(12) ysize(5) graphregion(fcolor(white)) ///
yl(0 5e7 "50" 1e8 "100" 1.5e8 "150" 2e8 "200" 2.5e8 "250" 3e8 "300" 3.5e8 "350" 4e8 "400" 4.5e8 "450" 5e8 "500" 5.5e8 "550") 
*graph export "results/EER-D-22-01148_Figure_2.eps", replace	
	
