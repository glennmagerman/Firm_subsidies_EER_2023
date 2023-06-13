# Data and Program Guide
to “The Impact of Firm-level Covid Rescue Policies on Productivity Growth and Reallocation”
Jozef Konings, Glenn Magerman and Dieter Van Esbroeck

Date: June 2, 2023


## 1. Overview
This file contains the necessary information to replicate all results in the paper.

The analysis uses confidential firm-level data, which we have acquired through a confidentiality agreement with Flanders innovation and Entrepreneurship Agency (VLAIO), so we are unable to disclose these datasets.

A detailed description of the data sources and construction is given in Section 2 and Appendix A and C of the paper.

We provide the full coding pipeline for the results (graphs, tables) in the paper. We also provide code to generate random data with the same variables as present in the real data. This allows for the code to run properly, although the results will be based on random draws from distributions instead of the real data.

Codes are organized according to sections. Each section has its folder. Results from the robustness section and appendix can be found in the folder of the section to which the results belong as specified below.

Results have been obtained using Stata 16. The program installs the necessary ado-files to run the codes in Stata.

## 2. Description per section
2.0 _master
Copy the folder to some location on your machine.

0_master.do: change the absolute path under “project folder” to this location. This do-file installs all necessary ado-files and executes all do-files of the project in sequential order.

###2.1 do_generate_data
This folder contains all do-files to generate random datasets with the same variable names as the real datasets. While the distribution of the variables are roughly comparable to the real data, there is no correlation across variables nor over time. This random data is for code debugging and replication purposes.

1.gen_data_treatment.do: creates a dataset containing amount of support allocated to firms for descriptives regarding allocation of support. Output: VLAIO_support.dta. 

2.gen_data_didyearly.do: creates a dataset containing a yearly balanced panel of firms for 2019-2021, whether they got support or not and control and outcome variables for the yearly DID regressions. Output: data_didyearly.dta.

3.gen_data_eventstudyquarterly.do: creates a dataset containing a quarterly balanced panel of firms for 2019q1-2021q4, whether they got support or not and control and outcome variables for the quarterly event-study regressions. Output: data_eventstudyquarterly.dta. 

4.gen_data_exitimpact.do: creates a dataset containing a quarterly unbalanced panel of firms for 2020, whether they got support or not, exited or not and control and variables for the exit impact regressions. Output: data_exitimpact.dta.

5.gen_data_aggregate: creates a dataset containing a yearly unbalanced panel of firms for 2005-2021, whether they got support or not and all necessary variables for the aggregate analysis of decompositions and reallocation. Output: data_aggregate.dta.

### 2.2 generated_data
Contains all generated data-files from folder ‘do_generate_data’

### 2.3 tmp
Contains the temporary intermediate datafiles created in all do-files.

### 2.4 section_2
These do-files generate results for section 2, data and summary statistics.

1.supportclassification.do: makes descriptives of support allocation, by premium and by sector. Input: VLAIO_support.dta. Output: figure 1a, figure 1b and figure 2.

2.1.sumstats_did.do: makes descriptives for the sample of the event-study regressions. Input: data_didyearly.dta and data_eventstudyquarterly. Output: table 2, table 14 and figure 14.

2.2.sumstats_aggregate.do: makes descriptives for the sample of the aggregate analysis. Input: data_aggregate.dta. Output: table 3, figure 4, table 13 and table 15.

### 2.5 section_3
These do-files generate results for section 3, the impact of Covid support measures on firm performance. 

1.didyearly.do: estimates the yearly diff-in-diff regressions, Y_{it}=\beta D_{it}+\alpha_i+\lambda_{jt}+\varepsilon_{it}, and tabulates results. Input: data_didyearly. Output: table 4, table 5 and table 10.

2.1.eventstudyquarterly.do: estimates the quarterly event-study regressions, Y_{it}=\sum_{k=-4}^{-1}{\beta_kD_{ik}}+\sum_{k=1}^{7}{\beta_kD_{ik}}+\alpha_i+\lambda_{jt}+\varepsilon_{it},\ and creates figures with results. Input: data_eventstudyquarterly.dta. Output: figure 3 and figure 7.

2.2.eventstudyquarterly_placebo.do: estimates the placebo quarterly event-study regression of section 5.1. Input: data_eventstudyquarterly.dta. Output: figure 6.

2.3.eventstudyquarterly_matched.do: estimates the nearest neighbor matching quarterly event-study regression of section 5.3. Input: data_eventstudyquarterly.dta. Output: figure 8.

2.4.eventstudyquarterly_SA.do: estimates the quarterly event-study regression according to the methodology of Sun and Abraham (2021) of section 5.4. Input: data_eventstudyquarterly.dta. Output: figure 9.

3.exitimpact.do: estimates the regressions on the impact of the VLAIO support measures on the propensity to exit.  Input: data_exitimpact.dta. Output: table 6, table 7 and table 9.

### 2.6 section_4
These do-files generate results for section 4, aggregate productivity growth, covid support and reallocation.

1.1.MP_decomp_LP.do: implements the Melitz Polanec decomposition (2015) for the total sample of firms using labour productivity. Input: data_aggregate.dta. Output: figure 5 results, table 17.

1.2.MP_decomp_TFP.do: implements the Melitz Polanec decomposition (2015) for the total sample of firms using total factor productivity. Input: data_aggregate.dta. Output: figure 10 results, table 18.

1.3.MP_decomp_manuf.do: implements the Melitz Polanec decomposition (2015) for the manufacturing sample of firms using labour productivity (appendix E). Input: data_aggregate.dta. Output: table 19.

1.4.MP_decomp_serv.do: implements the Melitz Polanec decomposition (2015) for the services sample of firms using labour productivity (appendix E). Input: data_aggregate.dta. Output: table 20.

2.1.MP_decomp_LP_treatment.do: implements the Melitz Polanec decomposition (2015) for multiple groups of firms (treated and untreated, with reallocation term between groups) using labour productivity. Input: data_aggregate.dta. Output: table 8.

2.2.MP_decomp_TFP_treatment.do: implements the Melitz Polanec decomposition (2015) for multiple groups of firms (treated and untreated, with reallocation term between groups) using total factor productivity. Input: data_aggregate.dta. Output: table 11.

3.reallocation.do: implements the job and value added reallocation terms by Davis and Haltiwanger (1992) for section 5.7. Input: data_aggregate.dta. Output: figure 11 and figure 12.












