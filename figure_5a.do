*code to reproduce the results in Figure 5a
*"An AI-based analysis of zoning reforms in US cities"

*---------------------------------------------------------*
					* Set global paths *
*---------------------------------------------------------*
global rep_path "" /*"/path/to/replication_package" */

global data_path "$rep_path/data"
global figures_path "$rep_path/figures"

*---------------------------------------------------------*
				* Import regression data *
*---------------------------------------------------------*

* Full sample 
use "$data_path/regression_data_all.dta", clear 


* After 1950 sample
preserve
use "$data_path/regression_data_subset.dta", clear 

rename median_setback_diff_street_alt setbacks_1950
rename sd_setback_diff_street_alt setbacks_sd_1950
rename log_place_min_plot_mts log_place_min_plot_mts_1950
rename log_place_avg_far_alt_mts_w far_1950
rename multi_family_housing_census mhousing_1950

keep setbacks_1950 setbacks_sd_1950 log_place_min_plot_mts_1950 far_1950 place_geoid10

gen sample_1950 = 1
tempfile 1950_sample
save `1950_sample'
restore


merge 1:1 place_geoid10 using `1950_sample', keep(3) nogenerate


*---------------------------------------------------------*
				* Variable cleaning *
*---------------------------------------------------------*

rename median_setback_diff_street_alt setbacks 
rename sd_setback_diff_street_alt setbacks_sd
rename log_place_avg_far_alt_mts_w far
rename multi_family_housing_census mhousing



*---------------------------------------------------------*
					* Regressions *
*---------------------------------------------------------*

*run regressions and store estimates: specification 1
foreach outcome in  setbacks setbacks_sd far log_place_min_plot_mts {

reg `outcome' fbc_similarity_d latitude longitude i.state_enc, r
	  
	  local spec1_b_`outcome'=_b[fbc_similarity_d]
	  local spec1_se_`outcome'=_se[fbc_similarity_d]
	  local spec1_df_`outcome' = e(df_r)

}



*run regressions and store estimates: specification 2 
foreach outcome in  setbacks setbacks_sd far log_place_min_plot_mts {

reg `outcome' fbc_similarity_d latitude longitude i.state_enc log_area_km_10, r
	  
	  local spec2_b_`outcome'=_b[fbc_similarity_d]
	  local spec2_se_`outcome'=_se[fbc_similarity_d]
	  local spec2_df_`outcome' = e(df_r)

}


*run regressions and store estimates: specification 3
foreach outcome in setbacks setbacks_sd far log_place_min_plot_mts {

reg `outcome' fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc, r
	  
	  local spec3_b_`outcome'=_b[fbc_similarity_d]
	  local spec3_se_`outcome'=_se[fbc_similarity_d]
	  local spec3_df_`outcome' = e(df_r)

}

*run regressions and store estimates: specification 4
foreach outcome in  setbacks setbacks_sd far log_place_min_plot_mts {

reg `outcome' fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
	  
	  local spec4_b_`outcome'=_b[fbc_similarity_d]
	  local spec4_se_`outcome'=_se[fbc_similarity_d]
	  local spec4_df_`outcome' = e(df_r)

}

*run regressions and store estimates: specification 5 for subset after 1950
foreach outcome in  setbacks setbacks_sd far log_place_min_plot_mts {


reg `outcome'_1950 fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
	  
	  local spec5_b_`outcome'=_b[fbc_similarity_d]
	  local spec5_se_`outcome'=_se[fbc_similarity_d]
	  local spec5_df_`outcome' = e(df_r)

}





*create new dataset
clear
set obs 5 /* number of variables */
gen spec1_b_ = .
gen spec1_se_ = .
gen spec2_b_ = .
gen spec2_se_ = .
gen spec3_b_ = .
gen spec3_se_ = .
gen spec4_b_ = .
gen spec4_se_ = .
gen spec5_b_ = .
gen spec5_se_ = .
gen outcome = ""
local i = 1


*create variable for the outcome and the grade
foreach outcome in setbacks setbacks_sd far log_place_min_plot_mts {
		replace outcome="`outcome'" in `i'
		local i=`i'+1

}




*store coefficients and se as variables
foreach outcome in setbacks setbacks_sd far log_place_min_plot_mts {
    replace spec1_b_ = `spec1_b_`outcome'' if outcome == "`outcome'"
    replace spec1_se_ = `spec1_se_`outcome'' if outcome == "`outcome'"
	
    replace spec2_b_ = `spec2_b_`outcome'' if outcome == "`outcome'"
    replace spec2_se_ = `spec2_se_`outcome'' if outcome == "`outcome'"

    replace spec3_b_ = `spec3_b_`outcome'' if outcome == "`outcome'"
    replace spec3_se_ = `spec3_se_`outcome'' if outcome == "`outcome'"

    replace spec4_b_ = `spec4_b_`outcome'' if outcome == "`outcome'"
    replace spec4_se_ = `spec4_se_`outcome'' if outcome == "`outcome'"

    replace spec5_b_ = `spec5_b_`outcome'' if outcome == "`outcome'"
    replace spec5_se_ = `spec5_se_`outcome'' if outcome == "`outcome'"
}




*create confidence intervals
gen ciup_1=spec1_b_+1.96*spec1_se_
gen cidown_1=spec1_b_-1.96*spec1_se_

gen ciup_2=spec2_b_+1.96*spec2_se_
gen cidown_2=spec2_b_-1.96*spec2_se_

gen ciup_3=spec3_b_+1.96*spec3_se_
gen cidown_3=spec3_b_-1.96*spec3_se_

gen ciup_4=spec4_b_+1.96*spec4_se_
gen cidown_4=spec4_b_-1.96*spec4_se_

gen ciup_5=spec5_b_+1.96*spec5_se_
gen cidown_5=spec5_b_-1.96*spec5_se_

gen pos1 = . 
replace pos1 = 0 if outcome=="setbacks" & spec1_b_

gen pos2 = .
replace pos2 = 0.25 if outcome=="setbacks" & spec2_b_

gen pos3 = .
replace pos3 = 0.5 if outcome=="setbacks" & spec3_b_

gen pos4 = .
replace pos4 = 0.75 if outcome=="setbacks" & spec4_b_

gen pos5 = .
replace pos5 = 1 if outcome=="setbacks" & spec5_b_



* Calculate p-values using ttail() and store them in separate variables
gen pval1 = .
gen pval2 = .
gen pval3 = .
gen pval4 = .
gen pval5 = .



foreach outcome in setbacks setbacks_sd far log_place_min_plot_mts {
    replace pval1 = 2 * ttail(`spec1_df_`outcome'', abs(spec1_b_ / spec1_se_)) if outcome == "`outcome'"
    replace pval2 = 2 * ttail(`spec2_df_`outcome'', abs(spec2_b_ / spec2_se_)) if outcome == "`outcome'"
    replace pval3 = 2 * ttail(`spec3_df_`outcome'', abs(spec3_b_ / spec3_se_)) if outcome == "`outcome'"
    replace pval4 = 2 * ttail(`spec4_df_`outcome'', abs(spec4_b_ / spec4_se_)) if outcome == "`outcome'"
    replace pval5 = 2 * ttail(`spec5_df_`outcome'', abs(spec5_b_ / spec5_se_)) if outcome == "`outcome'"
}

* Generate labels for coefficients and p-values
gen label_coef1 = string(spec1_b_, "%9.3f")
gen label_pval1 = ""
replace label_pval1 = "p<0.01" if pval1 < 0.01
replace label_pval1 = "p<0.05" if pval1 >= 0.01 & pval1 < 0.05
replace label_pval1 = "p<0.1" if pval1 >= 0.05 & pval1 < 0.1
replace label_pval1 = "p>=0.1" if pval1 >= 0.1

gen label_coef2 = string(spec2_b_, "%9.3f")
gen label_pval2 = ""
replace label_pval2 = "p<0.01" if pval2 < 0.01
replace label_pval2 = "p<0.05" if pval2 >= 0.01 & pval2 < 0.05
replace label_pval2 = "p<0.1" if pval2 >= 0.05 & pval2 < 0.1
replace label_pval2 = "p>=0.1" if pval2 >= 0.1

gen label_coef3 = string(spec3_b_, "%9.3f")
gen label_pval3 = ""
replace label_pval3 = "p<0.01" if pval3 < 0.01
replace label_pval3 = "p<0.05" if pval3 >= 0.01 & pval3 < 0.05
replace label_pval3 = "p<0.1" if pval3 >= 0.05 & pval3 < 0.1
replace label_pval3 = "p>=0.1" if pval3 >= 0.1

gen label_coef4 = string(spec4_b_, "%9.3f")
gen label_pval4 = ""
replace label_pval4 = "p<0.01" if pval4 < 0.01
replace label_pval4 = "p<0.05" if pval4 >= 0.01 & pval4 < 0.05
replace label_pval4 = "p<0.1" if pval4 >= 0.05 & pval4 < 0.1
replace label_pval4 = "p>=0.1" if pval4 >= 0.1

gen label_coef5 = string(spec5_b_, "%9.3f")
gen label_pval5 = ""
replace label_pval5 = "p<0.01" if pval5 < 0.01
replace label_pval5 = "p<0.05" if pval5 >= 0.01 & pval5 < 0.05
replace label_pval5 = "p<0.1" if pval5 >= 0.05 & pval5 < 0.1
replace label_pval5 = "p>=0.1" if pval5 >= 0.1




* First graph for setbacks
twoway (rcap ciup_1 cidown_1 pos1 if outcome == "setbacks", color(blue*.3) lwidth(medthick)) ///
    (rcap ciup_2 cidown_2 pos2 if outcome == "setbacks", color(orange*.3) lwidth(medthick)) ///
    (rcap ciup_3 cidown_3 pos3 if outcome == "setbacks", color(red*.3) lwidth(medthick)) ///
    (rcap ciup_4 cidown_4 pos4 if outcome == "setbacks", color(green*.3) lwidth(medthick)) ///
    (rcap ciup_5 cidown_5 pos5 if outcome == "setbacks", color(purple*.3) lwidth(medthick)) ///
    (scatter spec1_b_ pos1 if outcome == "setbacks", mcolor(blue*.9) msize(medium) ///
     mlab(label_coef1) mlabpos(6) mlabcolor(blue) mlabsize(vsmall) mlabgap(7)) ///
    (scatter spec1_b_ pos1 if outcome == "setbacks", mcolor(blue*.9) msize(medium) ///
     mlab(label_pval1) mlabpos(6) mlabcolor(blue) mlabsize(vsmall) mlabgap(10)) ///
    (scatter spec2_b_ pos2 if outcome == "setbacks", mcolor(orange*0.9) msize(medium) ///
     mlab(label_coef2) mlabpos(6) mlabcolor(orange) mlabsize(vsmall) mlabgap(7)) ///
    (scatter spec2_b_ pos2 if outcome == "setbacks", mcolor(orange*0.9) msize(medium) ///
     mlab(label_pval2) mlabpos(6) mlabcolor(orange) mlabsize(vsmall) mlabgap(10)) ///
    (scatter spec3_b_ pos3 if outcome == "setbacks", mcolor(red*.9) msize(medium) ///
     mlab(label_coef3) mlabpos(6) mlabcolor(red) mlabsize(vsmall) mlabgap(7)) ///
    (scatter spec3_b_ pos3 if outcome == "setbacks", mcolor(red*.9) msize(medium) ///
     mlab(label_pval3) mlabpos(6) mlabcolor(red) mlabsize(vsmall) mlabgap(10)) ///
    (scatter spec4_b_ pos4 if outcome == "setbacks", mcolor(green*.9) msize(medium) ///
     mlab(label_coef4) mlabpos(6) mlabcolor(green) mlabsize(vsmall) mlabgap(7)) ///
    (scatter spec4_b_ pos4 if outcome == "setbacks", mcolor(green*.9) msize(medium) ///
     mlab(label_pval4) mlabpos(6) mlabcolor(green) mlabsize(vsmall) mlabgap(10)) ///
    (scatter spec5_b_ pos5 if outcome == "setbacks", mcolor(purple*.9) msize(medium) ///
     mlab(label_coef5) mlabpos(6) mlabcolor(purple) mlabsize(vsmall) mlabgap(7)) ///
    (scatter spec5_b_ pos5 if outcome == "setbacks", mcolor(purple*.9) msize(medium) ///
     mlab(label_pval5) mlabpos(6) mlabcolor(purple) mlabsize(vsmall) mlabgap(10)), ///
    yline(0, lcolor(black)) ylabel(-3(1.5)3, labsize(medium)) ///
    xtitle("", size(large)) ///
    ytitle("", size(small)) subtitle("") ///
    title("{bf:a.} Median Street Setback", size(medium)) ///
    legend(order(7 "spec I." 9 "spec II." 11 "spec III." 12 "spec IV." 14 "spec V.") ring(0) position(11) rows(2) size(vsmall)) ///
    xlabel("", labsize(small)) ///
    xscale(lstyle(none)) ///
    ysize(2) xsize(6) aspect(0.5) ///
    name(p1, replace)
	
	
	


* Adjust positions for street setback deviation
replace pos1 = 0 if outcome == "setbacks_sd" & spec1_b_
replace pos2 = 0.25 if outcome == "setbacks_sd" & spec2_b_
replace pos3 = 0.5 if outcome == "setbacks_sd" & spec3_b_
replace pos4 = 0.75 if outcome == "setbacks_sd" & spec4_b_
replace pos5 = 1 if outcome == "setbacks_sd" & spec5_b_

* Second graph for street setback deviation
twoway (rcap ciup_1 cidown_1 pos1 if outcome == "setbacks_sd", color(blue*.3) lwidth(medthick)) ///
    (rcap ciup_2 cidown_2 pos2 if outcome == "setbacks_sd", color(orange*.3) lwidth(medthick)) ///
    (rcap ciup_3 cidown_3 pos3 if outcome == "setbacks_sd", color(red*.3) lwidth(medthick)) ///
    (rcap ciup_4 cidown_4 pos4 if outcome == "setbacks_sd", color(green*.3) lwidth(medthick)) ///
    (rcap ciup_5 cidown_5 pos5 if outcome == "setbacks_sd", color(purple*.3) lwidth(medthick)) ///
    (scatter spec1_b_ pos1 if outcome == "setbacks_sd", mcolor(blue*.9) msize(medium) ///
     mlab(label_coef1) mlabpos(6) mlabcolor(blue) mlabsize(vsmall) mlabgap(6)) ///
    (scatter spec1_b_ pos1 if outcome == "setbacks_sd", mcolor(blue*.9) msize(medium) ///
     mlab(label_pval1) mlabpos(6) mlabcolor(blue) mlabsize(vsmall) mlabgap(9)) ///
    (scatter spec2_b_ pos2 if outcome == "setbacks_sd", mcolor(orange*0.9) msize(medium) ///
     mlab(label_coef2) mlabpos(6) mlabcolor(orange) mlabsize(vsmall) mlabgap(6)) ///
    (scatter spec2_b_ pos2 if outcome == "setbacks_sd", mcolor(orange*0.9) msize(medium) ///
     mlab(label_pval2) mlabpos(6) mlabcolor(orange) mlabsize(vsmall) mlabgap(9)) ///
    (scatter spec3_b_ pos3 if outcome == "setbacks_sd", mcolor(red*.9) msize(medium) ///
     mlab(label_coef3) mlabpos(6) mlabcolor(red) mlabsize(vsmall) mlabgap(6)) ///
    (scatter spec3_b_ pos3 if outcome == "setbacks_sd", mcolor(red*.9) msize(medium) ///
     mlab(label_pval3) mlabpos(6) mlabcolor(red) mlabsize(vsmall) mlabgap(9)) ///
    (scatter spec4_b_ pos4 if outcome == "setbacks_sd", mcolor(green*.9) msize(medium) ///
     mlab(label_coef4) mlabpos(6) mlabcolor(green) mlabsize(vsmall) mlabgap(6)) ///
    (scatter spec4_b_ pos4 if outcome == "setbacks_sd", mcolor(green*.9) msize(medium) ///
     mlab(label_pval4) mlabpos(6) mlabcolor(green) mlabsize(vsmall) mlabgap(9)) ///
    (scatter spec5_b_ pos5 if outcome == "setbacks_sd", mcolor(purple*.9) msize(medium) ///
     mlab(label_coef5) mlabpos(6) mlabcolor(purple) mlabsize(vsmall) mlabgap(8)) ///
    (scatter spec5_b_ pos5 if outcome == "setbacks_sd", mcolor(purple*.9) msize(medium) ///
     mlab(label_pval5) mlabpos(6) mlabcolor(purple) mlabsize(vsmall) mlabgap(11)), ///
    yline(0, lcolor(black)) ylabel(-2(1)2, labsize(medium)) ///
    xtitle("", size(large)) ///
    ytitle("", size(large)) subtitle("") ///
    title("{bf:b.} Street Setback Deviation", size(medium)) ///
    legend(off) ///
    xlabel("", labsize(medium)) ///
    xscale(lstyle(none)) ///
    ysize(2) xsize(6) aspect(0.5) ///
    name(p2, replace)


* Adjust positions for FAR
replace pos1 = 0 if outcome == "far" & spec1_b_
replace pos2 = 0.25 if outcome == "far" & spec2_b_
replace pos3 = 0.5 if outcome == "far" & spec3_b_
replace pos4 = 0.75 if outcome == "far" & spec4_b_
replace pos5 = 1 if outcome == "far" & spec5_b_

* Third graph for FAR
twoway (rcap ciup_1 cidown_1 pos1 if outcome == "far", color(blue*.3) lwidth(medthick)) ///
    (rcap ciup_2 cidown_2 pos2 if outcome == "far", color(orange*.3) lwidth(medthick)) ///
    (rcap ciup_3 cidown_3 pos3 if outcome == "far", color(red*.3) lwidth(medthick)) ///
    (rcap ciup_4 cidown_4 pos4 if outcome == "far", color(green*.3) lwidth(medthick)) ///
    (rcap ciup_5 cidown_5 pos5 if outcome == "far", color(purple*.3) lwidth(medthick)) ///
    (scatter spec1_b_ pos1 if outcome == "far", mcolor(blue*.9) msize(medium) ///
     mlab(label_coef1) mlabpos(6) mlabcolor(blue) mlabsize(vsmall) mlabgap(5)) ///
    (scatter spec1_b_ pos1 if outcome == "far", mcolor(blue*.9) msize(medium) ///
     mlab(label_pval1) mlabpos(6) mlabcolor(blue) mlabsize(vsmall) mlabgap(8)) ///
    (scatter spec2_b_ pos2 if outcome == "far", mcolor(orange*0.9) msize(medium) ///
     mlab(label_coef2) mlabpos(6) mlabcolor(orange) mlabsize(vsmall) mlabgap(5)) ///
    (scatter spec2_b_ pos2 if outcome == "far", mcolor(orange*0.9) msize(medium) ///
     mlab(label_pval2) mlabpos(6) mlabcolor(orange) mlabsize(vsmall) mlabgap(8)) ///
    (scatter spec3_b_ pos3 if outcome == "far", mcolor(red*.9) msize(medium) ///
     mlab(label_coef3) mlabpos(6) mlabcolor(red) mlabsize(vsmall) mlabgap(5)) ///
    (scatter spec3_b_ pos3 if outcome == "far", mcolor(red*.9) msize(medium) ///
     mlab(label_pval3) mlabpos(6) mlabcolor(red) mlabsize(vsmall) mlabgap(8)) ///
    (scatter spec4_b_ pos4 if outcome == "far", mcolor(green*.9) msize(medium) ///
     mlab(label_coef4) mlabpos(6) mlabcolor(green) mlabsize(vsmall) mlabgap(5)) ///
    (scatter spec4_b_ pos4 if outcome == "far", mcolor(green*.9) msize(medium) ///
     mlab(label_pval4) mlabpos(6) mlabcolor(green) mlabsize(vsmall) mlabgap(8)) ///
    (scatter spec5_b_ pos5 if outcome == "far", mcolor(purple*.9) msize(medium) ///
     mlab(label_coef5) mlabpos(6) mlabcolor(purple) mlabsize(vsmall) mlabgap(5)) ///
    (scatter spec5_b_ pos5 if outcome == "far", mcolor(purple*.9) msize(medium) ///
     mlab(label_pval5) mlabpos(6) mlabcolor(purple) mlabsize(vsmall) mlabgap(8)), ///
    yline(0, lcolor(black)) ylabel(-0.5(0.25)0.5, labsize(medium)) ///
    xtitle("", size(large)) ///
    ytitle("", size(large)) subtitle("") ///
    title("{bf:c.} Log Floor-to-Area Ratio", size(medium)) ///
    legend(off) ///
    xlabel("", labsize(medium)) ///
    xscale(lstyle(none)) ///
    ysize(1) xsize(6) aspect(0.5) ///
    name(p3, replace)

	
* Adjust positions for minimum plot size 
replace pos1 = 0 if outcome == "log_place_min_plot_mts" & spec1_b_
replace pos2 = 0.25 if outcome == "log_place_min_plot_mts" & spec2_b_
replace pos3 = 0.5 if outcome == "log_place_min_plot_mts" & spec3_b_
replace pos4 = 0.75 if outcome == "log_place_min_plot_mts" & spec4_b_
replace pos5 = 1 if outcome == "log_place_min_plot_mts" & spec5_b_

* Fourth graph for Minimum plot size 
twoway (rcap ciup_1 cidown_1 pos1 if outcome == "log_place_min_plot_mts", color(blue*.3) lwidth(medthick)) ///
    (rcap ciup_2 cidown_2 pos2 if outcome == "log_place_min_plot_mts", color(orange*.3) lwidth(medthick)) ///
    (rcap ciup_3 cidown_3 pos3 if outcome == "log_place_min_plot_mts", color(red*.3) lwidth(medthick)) ///
    (rcap ciup_4 cidown_4 pos4 if outcome == "log_place_min_plot_mts", color(green*.3) lwidth(medthick)) ///
    (rcap ciup_5 cidown_5 pos5 if outcome == "log_place_min_plot_mts", color(purple*.3) lwidth(medthick)) ///
    (scatter spec1_b_ pos1 if outcome == "log_place_min_plot_mts", mcolor(blue*.9) msize(medium) ///
     mlab(label_coef1) mlabpos(6) mlabcolor(blue) mlabsize(vsmall) mlabgap(5)) ///
    (scatter spec1_b_ pos1 if outcome == "log_place_min_plot_mts", mcolor(blue*.9) msize(medium) ///
     mlab(label_pval1) mlabpos(6) mlabcolor(blue) mlabsize(vsmall) mlabgap(8)) ///
    (scatter spec2_b_ pos2 if outcome == "log_place_min_plot_mts", mcolor(orange*0.9) msize(medium) ///
     mlab(label_coef2) mlabpos(6) mlabcolor(orange) mlabsize(vsmall) mlabgap(5)) ///
    (scatter spec2_b_ pos2 if outcome == "log_place_min_plot_mts", mcolor(orange*0.9) msize(medium) ///
     mlab(label_pval2) mlabpos(6) mlabcolor(orange) mlabsize(vsmall) mlabgap(8)) ///
    (scatter spec3_b_ pos3 if outcome == "log_place_min_plot_mts", mcolor(red*.9) msize(medium) ///
     mlab(label_coef3) mlabpos(6) mlabcolor(red) mlabsize(vsmall) mlabgap(5)) ///
    (scatter spec3_b_ pos3 if outcome == "log_place_min_plot_mts", mcolor(red*.9) msize(medium) ///
     mlab(label_pval3) mlabpos(6) mlabcolor(red) mlabsize(vsmall) mlabgap(8)) ///
    (scatter spec4_b_ pos4 if outcome == "log_place_min_plot_mts", mcolor(green*.9) msize(medium) ///
     mlab(label_coef4) mlabpos(6) mlabcolor(green) mlabsize(vsmall) mlabgap(5)) ///
    (scatter spec4_b_ pos4 if outcome == "log_place_min_plot_mts", mcolor(green*.9) msize(medium) ///
     mlab(label_pval4) mlabpos(6) mlabcolor(green) mlabsize(vsmall) mlabgap(8)) ///
    (scatter spec5_b_ pos5 if outcome == "log_place_min_plot_mts", mcolor(purple*.9) msize(medium) ///
     mlab(label_coef5) mlabpos(6) mlabcolor(purple) mlabsize(vsmall) mlabgap(5)) ///
    (scatter spec5_b_ pos5 if outcome == "log_place_min_plot_mts", mcolor(purple*.9) msize(medium) ///
     mlab(label_pval5) mlabpos(6) mlabcolor(purple) mlabsize(vsmall) mlabgap(8)), ///
    yline(0, lcolor(black)) ylabel(-0.5(0.25)0.5, labsize(medium)) ///
    xtitle("", size(large)) ///
    ytitle("", size(large)) subtitle("") ///
    title("{bf:d.} Log Minimum Plot Size", size(medium)) ///
    legend(off) ///
    xlabel("", labsize(medium)) ///
    xscale(lstyle(none)) ///
    ysize(2) xsize(6) aspect(0.5) ///
    name(p4, replace)
	
	

	
	
* Combine graphs with improved proportions
gr combine p1 p2 p3 p4, plotregion(fcolor(white)) graphregion(color(white)) xsize(8) ysize(7) 

graph export "$figures_path/fig5_a.png", as(png) replace
