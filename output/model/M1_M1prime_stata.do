
clear
import delimited "../data/clean/01/panel_filtered_winsor_1_5.csv", clear

* Imported variable names are already lowercased by Stata

destring year, replace
xtset stkcd year

capture ssc install hdfe, replace
capture ssc install regife, replace
capture noisily regife lev npr m2_growth size tang growth ndts, absorb(stkcd) ife(stkcd year, 2)

capture ssc install reghdfe
capture noisily reghdfe lev npr size tang growth ndts, absorb(stkcd year) vce(cluster stkcd year)
