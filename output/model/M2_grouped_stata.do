
clear all
set more off
capture log close
log using "/Users/yijun/Desktop/hw/output/model/M2_grouped_stata.log", replace text

capture ssc install reghdfe, replace
capture ssc install estout, replace

import delimited "/Users/yijun/Desktop/hw/data/clean/01/panel_filtered_winsor_1_5.csv", clear varnames(1) encoding(utf-8)
capture destring soe, replace force
drop if missing(lev, npr, size, tang, growth, ndts, stkcd, year, soe)
sort stkcd year

di as text "===== M2 subgroup counts ====="
tab soe

di as text "===== SOE regression ====="
reghdfe lev npr size tang growth ndts if soe==1, absorb(stkcd year) vce(cluster stkcd year)
estimates store m2_soe

di as text "===== Non-SOE regression ====="
reghdfe lev npr size tang growth ndts if soe==0, absorb(stkcd year) vce(cluster stkcd year)
estimates store m2_private

esttab m2_soe m2_private using "/Users/yijun/Desktop/hw/output/model/M2_grouped_results.txt", replace ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    keep(npr size tang growth ndts) ///
    stats(N, fmt(%9.0f) labels("N")) ///
    title("M2 grouped regression results")

di as text "===== Attempt suest test ====="
capture noisily suest m2_soe m2_private
if _rc == 0 {
    di as result "suest succeeded; testing equality of npr coefficients."
    test [m2_soe_mean]npr = [m2_private_mean]npr
}
else {
    di as error "suest failed; running equivalent interaction-model test."
    reghdfe lev c.npr##i.soe size tang growth ndts, absorb(stkcd year) vce(cluster stkcd year)
    test 1.soe#c.npr = 0
}

log close
