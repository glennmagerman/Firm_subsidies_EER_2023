* Project: Impact of firm-level covid rescue policies
* Authors: Glenn Magerman & Dieter Van Esbroeck
* Version: 02/06/23

// project folder
cd "~/Dropbox/EER Covid/journal/EER/final_submit/EER-D-22-01148_dofiles/"

// graphs in black and white
set scheme s2mono

// install necessary ado files
foreach package in reghdfe a2reg coefplot ultimatch unique outreg2 gtools regsave carryforward {
	cap which `package'
	if _rc == 111 ssc install `package'
}
net cd "http://www.stata-journal.com/software/sj14-2"
net install st0085_2
net cd "http://www.stata-journal.com/software/sj16-4"
net install st0460
net install github, from("https://haghish.github.io/github/")
github install lsun20/eventstudyinteract // version 02/06/23

// generate datasets:
do "do_generate_data/1.gen_data_treatment.do"
do "do_generate_data/2.gen_data_didyearly.do"
do "do_generate_data/3.gen_data_eventstudyquarterly.do"
do "do_generate_data/4.gen_data_exitimpact.do"
do "do_generate_data/5.gen_data_aggregate.do"

// section 2: data and summary statistics
do "section_2/1.supportclassification.do"
do "section_2/2.1.sumstats_did.do"
do "section_2/2.2.sumstats_aggregate.do"

// section 3: the impact of covid support measures on firm performance
do "section_3/1.didyearly.do"
do "section_3/2.1.eventstudyquarterly.do"
do "section_3/2.2.eventstudyquarterly_placebo.do"
do "section_3/2.3.eventstudyquarterly_matched.do"
do "section_3/2.4.eventstudyquarterly_SA.do"
do "section_3/3.exitimpact.do"

// section 4: aggregate productivity growth, covid support and reallocation
do "section_4/1.1.MP_decomp_LP.do"
do "section_4/1.2.MP_decomp_TFP.do"
do "section_4/1.3.MP_decomp_manuf.do"
do "section_4/1.4.MP_decomp_serv.do"
do "section_4/2.1.MP_decomp_LP_treatment.do"
do "section_4/2.2.MP_decomp_TFP_treatment.do"
do "section_4/3.reallocation.do"
