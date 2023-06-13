* Project: Impact of firm-level covid rescue policies
* Authors: Glenn Magerman & Dieter Van Esbroeck
* Version: 02/06/23

*---------------------
**# yearly DID Results
*---------------------
use "generated_data/data_didyearly", clear

// create variables for regression
gen w = dummy_support
label var w "Support (dummy 0/1)"
egen indyFE=group(year nacerev2_recoded)

xtset vat year

// table 4: estimate TE
areg lnsales_fte_norm w i.indyFE, absorb(vat) vce(cluster vat)
areg lnprod_fte_norm w i.indyFE, absorb(vat) vce(cluster vat)

// table 10: estimate effects on seperate variables
areg lnsales w i.indyFE, absorb(vat) vce(cluster vat)
areg lnva w i.indyFE, absorb(vat) vce(cluster vat)
areg lnfte w i.indyFE, absorb(vat) vce(cluster vat)

// table 5: estimate TE by premium
// prepare premium variables
bys vat (year): gen sum_premium1 = sum(premium1)
egen temp = max(sum_premium1), by(vat)
gen everpremium1=1 if temp!=0
replace everpremium1=0 if everpremium1==.
drop temp
bys vat (year): gen sum_premium4_5 = sum(premium4+premium5)
egen temp = max(sum_premium4_5), by(vat)
gen everpremium4_5=1 if temp!=0
replace everpremium4_5=0 if everpremium4_5==.
drop temp
bys vat (year): gen sum_premium2_3 = sum(premium2+premium3)
egen temp = max(sum_premium2_3), by(vat)
gen everpremium2_3=1 if temp!=0
replace everpremium2_3=0 if everpremium2_3==.
drop temp

// everpremium variable states that firm gets the premium in 2020 and remains treated afterwards
replace everpremium1 = 0 if year == 2019
replace everpremium2_3 = 0 if year == 2019
replace everpremium4_5 = 0 if year == 2019

// estimate treatment effects
areg lnsales_fte_norm i.w i.(everpremium1 everpremium2_3 everpremium4_5) i.indyFE, absorb(vat) vce(cluster vat)
lincom 1.w + 1.everpremium1
lincom 1.w + 1.everpremium2_3
lincom 1.w + 1.everpremium4_5
areg lnprod_fte_norm  i.w i.(everpremium1 everpremium2_3 everpremium4_5) i.indyFE, absorb(vat) vce(cluster vat)
lincom 1.w + 1.everpremium1
lincom 1.w + 1.everpremium2_3
lincom 1.w + 1.everpremium4_5

clear
