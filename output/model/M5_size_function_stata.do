
clear all
set more off
capture log close
log using "/Users/yijun/Desktop/hw/output/model/M5_size_function_stata.log", replace text

capture ssc install reghdfe, replace
capture ssc install estout, replace

import delimited "/Users/yijun/Desktop/hw/data/clean/01/panel_filtered_winsor_1_5.csv", clear varnames(1) encoding(utf-8)
capture destring soe, replace force
drop if missing(lev, npr, size, tang, growth, ndts, stkcd, year)
sort stkcd year

gen npr_size  = npr * size
gen npr_size2 = npr * size^2

di as text "===== M5 polynomial interaction regression ====="
reghdfe lev npr npr_size npr_size2 size tang growth ndts, absorb(stkcd year) vce(cluster stkcd year)
estimates store m5_poly

esttab m5_poly using "/Users/yijun/Desktop/hw/output/model/M5_size_function_results.txt", replace ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    keep(npr npr_size npr_size2 size tang growth ndts) ///
    stats(N, fmt(%9.0f) labels("N")) ///
    title("M5 size-moderated regression results")

quietly summarize size, detail
local p10 = r(p10)
local p25 = r(p25)
local p50 = r(p50)
local p75 = r(p75)
local p90 = r(p90)
local minx = max(r(min), `p10' - 0.5)
local maxx = min(r(max), `p90' + 0.5)
local gridstep = (`maxx' - `minx')/40

tempfile beta_curve
postfile handle double size beta se lb ub using "`beta_curve'", replace
forvalues j = 0/40 {
    local s = `minx' + `j' * `gridstep'
    capture quietly lincom npr + `s' * npr_size + (`s'^2) * npr_size2
    if _rc == 0 {
        post handle (`s') (r(estimate)) (r(se)) (r(lb)) (r(ub))
    }
}
postclose handle
use "`beta_curve'", clear
sort size
export delimited using "/Users/yijun/Desktop/hw/output/model/M5_beta_size_curve.csv", replace
twoway ///
    (rarea ub lb size, color(gs13%55) lcolor(none)) ///
    (line beta size, lcolor(navy) lwidth(medthick)), ///
    xline(`p10' `p25' `p50' `p75' `p90', lpattern(dash) lcolor(gs8)) ///
    title("M5: β(Size) - marginal effect of NPR on Lev") ///
    xtitle("Size") ytitle("Marginal effect of NPR") ///
    legend(off)
graph export "/Users/yijun/Desktop/hw/output/figures/M5_beta_size_curve.png", replace width(1800)

log close
