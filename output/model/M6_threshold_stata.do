
clear all
set more off
capture log close
log using "/Users/yijun/Desktop/hw/output/model/M6_threshold_stata.log", replace text

capture ssc install reghdfe, replace
capture ssc install estout, replace

import delimited "/Users/yijun/Desktop/hw/data/clean/01/panel_filtered_winsor_1_5.csv", clear varnames(1) encoding(utf-8)
capture destring soe, replace force
drop if missing(lev, npr, size, tang, growth, ndts, stkcd, year)
keep if inrange(year, 2011, 2025)
sort stkcd year

* Construct a balanced panel: keep firms observed in all 15 years (2011-2025)
bys stkcd: egen n_years = count(year)
keep if n_years == 15
drop n_years

quietly summarize size, detail
local p10 = r(p10)
local p25 = r(p25)
local p50 = r(p50)
local p75 = r(p75)
local p90 = r(p90)
local minx = `p10'
local maxx = `p90'
local gridstep = (`maxx' - `minx')/30

di as text "===== M6 threshold search on balanced panel ====="
di as result "Balanced sample: " _N " observations"

tempfile threshold_grid
postfile handle double gamma rss b_low se_low b_high se_high using "`threshold_grid'", replace
forvalues j = 0/30 {
    local g = `minx' + `j' * `gridstep'
    capture drop low high npr_low npr_high resid resid2
    gen byte low = size <= `g'
    gen byte high = size > `g'
    gen double npr_low = npr * low
    gen double npr_high = npr * high
    quietly reghdfe lev npr_low npr_high size tang growth ndts, absorb(stkcd year) vce(cluster stkcd year)
    capture quietly predict double resid, residuals
    gen double resid2 = resid^2
    quietly summarize resid2, meanonly
    local rss = r(sum)
    capture quietly lincom npr_low
    local b_low = r(estimate)
    local se_low = r(se)
    capture quietly lincom npr_high
    local b_high = r(estimate)
    local se_high = r(se)
    post handle (`g') (`rss') (`b_low') (`se_low') (`b_high') (`se_high')
}
postclose handle

use "`threshold_grid'", clear
sort rss
gen rank = _n
save "/Users/yijun/Desktop/hw/output/model/M6_threshold_profile.dta", replace
export delimited using "/Users/yijun/Desktop/hw/output/model/M6_threshold_profile.csv", replace

quietly summarize gamma in 1/1, meanonly
local gamma_hat = r(mean)
quietly summarize rss in 1/1, meanonly
local rss_min = r(mean)

di as text "===== Estimated threshold ====="
di as result "gamma_hat = " `gamma_hat'
di as result "rss_min   = " `rss_min'

gen byte low_hat = size <= `gamma_hat'
gen byte high_hat = size > `gamma_hat'
gen double npr_low_hat = npr * low_hat
gen double npr_high_hat = npr * high_hat
reghdfe lev npr_low_hat npr_high_hat size tang growth ndts, absorb(stkcd year) vce(cluster stkcd year)
estimates store m6_threshold

esttab m6_threshold using "/Users/yijun/Desktop/hw/output/model/M6_threshold_results.txt", replace ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.1 ** 0.05 *** 0.01) ///
    keep(npr_low_hat npr_high_hat size tang growth ndts) ///
    stats(N, fmt(%9.0f) labels("N")) ///
    title("M6 threshold regression results")

lincom npr_low_hat
lincom npr_high_hat
test npr_low_hat = npr_high_hat

twoway ///
    (line rss gamma, lcolor(navy) lwidth(medthick)) ///
    (scatter rss gamma if rank==1, mcolor(maroon) msymbol(D) msize(medlarge)), ///
    xline(`gamma_hat', lpattern(dash) lcolor(maroon)) ///
    title("M6: Threshold profile over Size") ///
    xtitle("Threshold candidate (gamma)") ytitle("Residual sum of squares") ///
    legend(off)
graph export "/Users/yijun/Desktop/hw/output/figures/M6_threshold_profile.png", replace width(1800)

log close
