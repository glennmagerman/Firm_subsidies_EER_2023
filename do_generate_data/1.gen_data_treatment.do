* Project: Impact of firm-level covid rescue policies
* Authors: Glenn Magerman & Dieter Van Esbroeck
* Version: 02/06/23

*------------------------------------------------------
**# generate random data for support allocated to firms
*------------------------------------------------------
set seed 111765
clear

// choose amount of firms
set obs 50000	

// create firms
gen vat = _n

// create support variable
gen support = 1 + int((200000)*runiform()) 

// create premium variable
gen premium = 1 + int((5)*runiform()) 

// create industry
gen nace2_code = 1 + int((82)*runiform()) 

// create industry description
gen nace2_short = char(runiformint(65,90)) + ///
char(runiformint(65,90)) + ///
char(runiformint(65,90)) + ///
char(runiformint(65,90))
bys nace2_code: replace nace2_short = nace2_short[1]

// create payment date
gen date_payment = floor((mdy(12,31,2020)-mdy(01,01,2020))*runiform()+ mdy(01,01,2020)) 

save  "generated_data/VLAIO_support", replace

clear
