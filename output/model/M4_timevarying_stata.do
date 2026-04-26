
clear all
set more off
capture log close
log using "/Users/yijun/Desktop/hw/output/model/M4_timevarying_stata.log", replace text

capture ssc install reghdfe, replace
capture ssc install estout, replace

import delimited "/Users/yijun/Desktop/hw/data/clean/01/panel_filtered_winsor_1_5.csv", clear varnames(1) encoding(utf-8)
capture destring soe, replace force
drop if missing(lev, npr, size, tang, growth, ndts, stkcd, year)
sort stkcd year

di as text "===== M4 time-varying regression ====="
reghdfe lev c.npr##i.year size tang growth ndts, absorb(stkcd year) vce(cluster stkcd year)
estimates store m4_timevarying

esttab m4_timevarying using "/Users/yijun/Desktop/hw/output/model/M4_timevarying_results.txt", replace ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    keep(npr *year#c.npr size tang growth ndts) ///
    stats(N, fmt(%9.0f) labels("N")) ///
    title("M4 time-varying coefficient regression results")

tempfile beta_year
postfile handle int year double beta se lb ub using "`beta_year'", replace
forvalues y = 2010/2025 {
    capture quietly lincom npr + `y'.year#c.npr
    if _rc == 0 {
        post handle (`y') (r(estimate)) (r(se)) (r(lb)) (r(ub))
    }
}
postclose handle
use "`beta_year'", clear
sort year
export delimited using "/Users/yijun/Desktop/hw/output/model/M4_beta_yearly.csv", replace
twoway ///
    (rarea ub lb year, color(gs13%55) lcolor(none)) ///
    (line beta year, lcolor(navy) lwidth(medthick)), ///
    title("M4: Annual effect of NPR on Lev") ///
    xtitle("Year") ytitle("Marginal effect of NPR") ///
    legend(off)
graph export "/Users/yijun/Desktop/hw/output/figures/M4_beta_timevarying.png", replace width(1800)

log close
