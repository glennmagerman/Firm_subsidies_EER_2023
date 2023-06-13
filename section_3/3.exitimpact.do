* Project: Impact of firm-level covid rescue policies
* Authors: Glenn Magerman & Dieter Van Esbroeck
* Version: 02/06/23

*-----------------------------
**# Propensity to exit results
*-----------------------------
use "generated_data/data_exitimpact", clear

// create variables for regression
label var dummy_support "Steun (dummy 0/1)"
label var exiting "Exit"
xtset vat quarter

// table 6: probability of exit, quarterly
logit exiting dummy_support lnprod_fte lnfte debt_asset2019 lnage i.quarter i.nacerev2_recoded, vce(cluster nacerev2_recoded)
*outreg2 using "results/exit_logit.xlsx", replace keep(dummy_support lnprod_fte lnfte debt_asset2019 lnage) addtext(Sector FE, yes, Quarter FE, yes) label
logit exiting dummy_support lnprod_fte lnfte debt_asset2019 i.quarter i.nacerev2_recoded if e(sample), vce(cluster nacerev2_recoded)
*outreg2 using "results/exit_logit.xlsx", append keep(dummy_support lnprod_fte lnfte debt_asset2019) addtext(Sector FE, yes, Quarter FE, yes) label
logit exiting dummy_support lnprod_fte lnfte i.quarter i.nacerev2_recoded if e(sample), vce(cluster nacerev2_recoded)
*outreg2 using "results/exit_logit.xlsx", append keep(dummy_support lnprod_fte lnfte) addtext(Sector FE, yes, Quarter FE, yes) label
tab exiting if e(sample)

// table 7: decomposition of exit probabilities
// use i.dummy_steun for margins command, doesn't change anything for standard logit output
logit exiting i.dummy_support lnprod_fte lnfte debt_asset2019 lnage i.quarter i.nacerev2_recoded, vce(cluster nacerev2_recoded)
margins
margins dummy_support
margins, dydx(dummy_support)
margins if dummy_support == 1, at(dummy_support=(0 1))
margins if dummy_support == 0, at(dummy_support=(0 1))

// for robustness section, check results with control group of only firms that asked for support but got rejected
bys vat (quarter): gen sum_support = sum(dummy_support)
egen temp=max(sum_support), by(vat)
gen eversupport=1 if temp!=0
replace eversupport=0 if eversupport==.
drop temp
keep if eversupport == 1 | declinedsupport == 1 //drops firms that didn't get support and were not in dataset
drop if dummy_support == 0 & eversupport == 1 // keep only never-treated as a control group

// table 9: probability of exit, quarterly
logit exiting dummy_support lnprod_fte lnfte debt_asset2019 lnage i.quarter i.nacerev2_recoded, vce(cluster nacerev2_recoded)
*outreg2 using "results/exit_logit_2.xlsx", replace keep(dummy_support lnprod_fte lnfte debt_asset2019 lnage) addtext(Sector FE, yes, Quarter FE, yes) label
logit exiting dummy_support lnprod_fte lnfte debt_asset2019 i.quarter i.nacerev2_recoded if e(sample), vce(cluster nacerev2_recoded)
*outreg2 using "results/exit_logit_2.xlsx", append keep(dummy_support lnprod_fte lnfte debt_asset2019) addtext(Sector FE, yes, Quarter FE, yes) label
logit exiting dummy_support lnprod_fte lnfte i.quarter i.nacerev2_recoded if e(sample), vce(cluster nacerev2_recoded)
*outreg2 using "results/exit_logit_2.xlsx", append keep(dummy_support lnprod_fte lnfte) addtext(Sector FE, yes, Quarter FE, yes) label

// decomposition of exit probabilities
// use i.dummy_steun for margins command, doesn't change anything for standard logit output
logit exiting i.dummy_support lnprod_fte lnfte debt_asset2019 lnage i.quarter i.nacerev2_recoded, vce(cluster nacerev2_recoded)
margins, dydx(dummy_support)

// get rid of all the txt files created by outreg2
/*
local txtfiles: dir "results/" files "*.txt"
foreach txt in `txtfiles' {
    erase `"results/`txt'"'
}
*/

clear
