* Project: Impact of firm-level covid rescue policies
* Authors: Glenn Magerman & Dieter Van Esbroeck
* Version: 02/06/23

*--------------------------------------------------------------------------
**# quarterly event study results with the Sun and Abraham (2021) estimator
*--------------------------------------------------------------------------
use "tmp/estdata_eventstudy", clear

// Install necessary package
*github install lsun20/eventstudyinteract
	
// use quarter before first quarter support as t=0 
gen t0 = firstquartersupport - 1

// Sun and Abraham (2021) estimator 
// notes: uses never-treated as control group; FE and SE same as baseline
eventstudyinteract lnsales_fte I_pre4 I_pre3 I_pre2 I_pre1 I_post1 I_post2 I_post3 I_post4 I_post5 I_post6 I_post7 , cohort(t0) control_cohort(untreated) absorb(vat indqFE) vce(cluster vat)

// prepare results of regression for graph
matrix list e(b_interact)
matrix C = e(b_iw)
mata st_matrix("A",sqrt(diagonal(st_matrix("e(V_iw)"))))
matrix C = C \ A'
matrix list C
matrix D = (.\ .)
matrix E = (C[1..2,1..4], D, C[1..2,5..11])
matrix colnames E = -4 -3 -2 -1 0 1 2 3 4 5 6 7

// figure 9
coefplot matrix(E[1]), se(E[2]) vertical drop(_cons) yline(0) grid(none) name("lnsales_fte_coef_SA", replace) ylabel(-0.10(0.05)0.10) graphregion(fcolor(white))
*graph export "results/EER-D-22-01148_Figure_9.eps", replace

clear
