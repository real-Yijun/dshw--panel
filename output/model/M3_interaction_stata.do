
clear all
set more off
capture log close
log using "/Users/yijun/Desktop/hw/output/model/M3_interaction_stata.log", replace text

capture ssc install reghdfe, replace
capture ssc install estout, replace

import delimited "/Users/yijun/Desktop/hw/data/clean/01/panel_filtered_winsor_1_5.csv", clear varnames(1) encoding(utf-8)
capture destring soe, replace force
drop if missing(lev, npr, size, tang, growth, ndts, stkcd, year, soe)
sort stkcd year

di as text "===== M3 interaction regression ====="
reghdfe lev c.npr##i.soe size tang growth ndts, absorb(stkcd year) vce(cluster stkcd year)
estimates store m3_interaction

esttab m3_interaction using "/Users/yijun/Desktop/hw/output/model/M3_interaction_results.txt", replace ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    keep(npr 1.soe#c.npr size tang growth ndts) ///
    stats(N, fmt(%9.0f) labels("N")) ///
    title("M3 interaction regression results")

di as text "===== Marginal effect calculations ====="
lincom npr
lincom npr + 1.soe#c.npr
lincom 1.soe#c.npr

quietly summarize npr, detail
local npr_lo = r(p10)
local npr_hi = r(p90)
local npr_step = (`npr_hi' - `npr_lo')/20
margins soe, at(npr=(`npr_lo'(`npr_step')`npr_hi')) predict(xb)
marginsplot, noci title("M3: Marginal effect of NPR by SOE") ///
    xtitle("NPR") ytitle("Predicted Lev") legend(order(1 "Non-SOE" 2 "SOE"))
graph export "/Users/yijun/Desktop/hw/output/figures/M3_marginsplot.png", replace width(1800)

log close
