*code to reproduce the results in Table S1
*"An AI-based analysis of zoning reforms in US cities"

*---------------------------------------------------------*
					* Set global paths *
*---------------------------------------------------------*
global rep_path "" /*"/path/to/replication_package" */

global data_path "$rep_path/data"
global tables_path "$rep_path/tables"

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
rename log_place_min_plot_mts plotsize_1950
rename log_place_avg_far_alt_mts_w far_1950
rename multi_family_housing_census mhousing_1950
rename mean_natwalkind_2010 walkscore_1950
rename log_commute_distance_km_med commute_1950
keep setbacks_1950 setbacks_sd_1950 plotsize_1950 far_1950 walkscore_1950 commute_1950 mhousing_1950 place_geoid10

gen sample_1950 = 1
tempfile 1950_sample
save `1950_sample'
restore


merge 1:1 place_geoid10 using `1950_sample', keep(3) nogenerate

*---------------------------------------------------------*
				* Variable cleaning *
*---------------------------------------------------------*

*setbacks
rename median_setback_diff_street_alt setbacks
rename sd_setback_diff_street_alt setbacks_sd

*minimum plot size
rename log_place_min_plot_mts plotsize

*far 
rename log_place_avg_far_alt_mts_w far

*housing
rename multi_family_housing_census mhousing

*commute
rename log_commute_distance_km_med commute

*walkscore
rename mean_natwalkind_2010 walkscore

* -------------------------------------------------------- * 
	  * Regressions (using continuous variable)  *
* -------------------------------------------------------- * 


* -------------------------------------------------------- * 
						* Commuting  *
* -------------------------------------------------------- * 


* location *
reg commute log_similaritytonucentroid latitude longitude i.state_enc, r
estimates store e1


* city area *
reg commute log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10, r
estimates store e2

* type of place *
reg commute log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc, r
estimates store e3

* Year of zoning *
reg commute log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e4

* 1950 subset *
reg commute_1950 log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e5


estout e1 e2 e3 e4 e5 using "$tables_path/ols_commute.tex", style(tex) ///
varlabels(log_similaritytonucentroid "Log(FBC zoning similarity)" 2.type_area_enc "city" 3.type_area_enc "county" 4.type_area_enc "town" 5.type_area_enc "village") ///
cells(b(star fmt(%9.3f)) se(par)) stats(N r2, fmt(%7.0f %7.2f) labels("Observations" "R-squared")) ///
nolabel replace mlabels(none) collabels(none) starlevels(\$^{*}\$ .1 \$^{**}\$ .05 \$^{***}\$ .01) ///
keep(log_similaritytonucentroid) ///
order(log_similaritytonucentroid)


* -------------------------------------------------------- * 
						* Setbacks  *
* -------------------------------------------------------- * 

* location *
reg setbacks log_similaritytonucentroid latitude longitude i.state_enc, r
estimates store e1

* city area *
reg setbacks log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10, r
estimates store e2

* type of place *
reg setbacks log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc, r
estimates store e3

* Year of zoning *
reg setbacks log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e4

* subset 1950 *
reg setbacks_1950 log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e5


estout e1 e2 e3 e4 e5 using "$tables_path/ols_setbacks.tex", style(tex) ///
varlabels(log_similaritytonucentroid "Log(FBC zoning similarity)" 2.type_area_enc "city" 3.type_area_enc "county" 4.type_area_enc "town" 5.type_area_enc "village") ///
cells(b(star fmt(%9.3f)) se(par)) stats(N r2, fmt(%7.0f %7.2f) labels("Observations" "R-squared")) ///
nolabel replace mlabels(none) collabels(none) starlevels(\$^{*}\$ .1 \$^{**}\$ .05 \$^{***}\$ .01) ///
keep(log_similaritytonucentroid) ///
order(log_similaritytonucentroid)


* -------------------------------------------------------- * 
						* Setbacks SD *
* -------------------------------------------------------- * 

* location *
reg setbacks_sd log_similaritytonucentroid latitude longitude i.state_enc, r
estimates store e1

* city area *
reg setbacks_sd log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10, r
estimates store e2

* type of place *
reg setbacks_sd log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc, r
estimates store e3

* Year of zoning *
reg setbacks_sd log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e4

* subset 1950 *
reg setbacks_sd_1950 log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e5


estout e1 e2 e3 e4 e5 using "$tables_path/ols_setbacks_sd.tex", style(tex) ///
varlabels(log_similaritytonucentroid "Log(FBC zoning similarity)" 2.type_area_enc "city" 3.type_area_enc "county" 4.type_area_enc "town" 5.type_area_enc "village") ///
cells(b(star fmt(%9.3f)) se(par)) stats(N r2, fmt(%7.0f %7.2f) labels("Observations" "R-squared")) ///
nolabel replace mlabels(none) collabels(none) starlevels(\$^{*}\$ .1 \$^{**}\$ .05 \$^{***}\$ .01) ///
keep(log_similaritytonucentroid) ///
order(log_similaritytonucentroid)


* -------------------------------------------------------- * 
						* FAR  *
* -------------------------------------------------------- * 

* location *
reg far log_similaritytonucentroid latitude longitude i.state_enc, r
estimates store e1

* city area *
reg far log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10, r
estimates store e2

* type of place *
reg far log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc, r
estimates store e3

* Year of zoning *
reg far log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e4

* subset 1950 *
reg far_1950 log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e5

estout e1 e2 e3 e4 e5 using "$tables_path/ols_far.tex", style(tex) ///
varlabels(log_similaritytonucentroid "Log(FBC zoning similarity)" 2.type_area_enc "city" 3.type_area_enc "county" 4.type_area_enc "town" 5.type_area_enc "village") ///
cells(b(star fmt(%9.3f)) se(par)) stats(N r2, fmt(%7.0f %7.2f) labels("Observations" "R-squared")) ///
nolabel replace mlabels(none) collabels(none) starlevels(\$^{*}\$ .1 \$^{**}\$ .05 \$^{***}\$ .01) ///
keep(log_similaritytonucentroid) ///
order(log_similaritytonucentroid)

 
* -------------------------------------------------------- * 
						* Walkscore  *
* -------------------------------------------------------- * 

* location *
reg walkscore log_similaritytonucentroid latitude longitude i.state_enc, r
estimates store e1

* city area *
reg walkscore log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10, r
estimates store e2

* type of place *
reg walkscore log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc, r
estimates store e3

* Year of zoning *
reg walkscore log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e4

* subset 1950 *
reg walkscore_1950 log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e5


estout e1 e2 e3 e4 e5 using "$tables_path/ols_walkscore.tex", style(tex) ///
varlabels(log_similaritytonucentroid "Log(FBC zoning similarity)" 2.type_area_enc "city" 3.type_area_enc "county" 4.type_area_enc "town" 5.type_area_enc "village") ///
cells(b(star fmt(%9.3f)) se(par)) stats(N r2, fmt(%7.0f %7.2f) labels("Observations" "R-squared")) ///
nolabel replace mlabels(none) collabels(none) starlevels(\$^{*}\$ .1 \$^{**}\$ .05 \$^{***}\$ .01) ///
keep(log_similaritytonucentroid) ///
order(log_similaritytonucentroid)


* -------------------------------------------------------- * 
						* Min plot size  *
* -------------------------------------------------------- * 

* location *
reg plotsize log_similaritytonucentroid latitude longitude i.state_enc, r
estimates store e1

* city area *
reg plotsize log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10, r
estimates store e2

* type of place *
reg plotsize log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc, r
estimates store e3

* Year of zoning *
reg plotsize log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e4

* subset 1950 *
reg plotsize_1950 log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e5


estout e1 e2 e3 e4 e5 using "$tables_path/ols_minplot.tex", style(tex) ///
varlabels(log_similaritytonucentroid "Log(FBC zoning similarity)" 2.type_area_enc "city" 3.type_area_enc "county" 4.type_area_enc "town" 5.type_area_enc "village") ///
cells(b(star fmt(%9.3f)) se(par)) stats(N r2, fmt(%7.0f %7.2f) labels("Observations" "R-squared")) ///
nolabel replace mlabels(none) collabels(none) starlevels(\$^{*}\$ .1 \$^{**}\$ .05 \$^{***}\$ .01) ///
keep(log_similaritytonucentroid) ///
order(log_similaritytonucentroid)


* -------------------------------------------------------- * 
				* Multi-Family Housing  *
* -------------------------------------------------------- * 

* location *
reg mhousing log_similaritytonucentroid latitude longitude i.state_enc, r
estimates store e1

* city area *
reg mhousing log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10, r
estimates store e2

* type of place *
reg mhousing log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc, r
estimates store e3

* Year of zoning *
reg mhousing log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e4

* Year of zoning *
reg mhousing_1950 log_similaritytonucentroid latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e5


estout e1 e2 e3 e4 e5 using "$tables_path/ols_multi-family.tex", style(tex) ///
varlabels(log_similaritytonucentroid "Log(FBC zoning similarity)" 2.type_area_enc "city" 3.type_area_enc "county" 4.type_area_enc "town" 5.type_area_enc "village") ///
cells(b(star fmt(%9.3f)) se(par)) stats(N r2, fmt(%7.0f %7.2f) labels("Observations" "R-squared")) ///
nolabel replace mlabels(none) collabels(none) starlevels(\$^{*}\$ .1 \$^{**}\$ .05 \$^{***}\$ .01) ///
keep(log_similaritytonucentroid) ///
order(log_similaritytonucentroid)



* -------------------------------------------------------- * 
				* Using dummy of top 20% *
* -------------------------------------------------------- * 


* -------------------------------------------------------- * 
						* Commuting  *
* -------------------------------------------------------- * 


* location *
reg commute fbc_similarity_d latitude longitude i.state_enc, r
estimates store e1

* city area *
reg commute fbc_similarity_d latitude longitude i.state_enc log_area_km_10, r
estimates store e2

* type of place *
reg commute fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc, r
estimates store e3

* Year of zoning *
reg commute fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e4

* subset 1950 *
reg commute_1950 fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e5

estout e1 e2 e3 e4 e5 using "$tables_path/ols_commute_dummy.tex", style(tex) ///
varlabels(fbc_similarity_d "High-FBC (top 20\%)" 2.type_area_enc "city" 3.type_area_enc "county" 4.type_area_enc "town" 5.type_area_enc "village") ///
cells(b(star fmt(%9.3f)) se(par)) stats(N r2, fmt(%7.0f %7.2f) labels("Observations" "R-squared")) ///
nolabel replace mlabels(none) collabels(none) starlevels(\$^{*}\$ .1 \$^{**}\$ .05 \$^{***}\$ .01) ///
keep(fbc_similarity_d) ///
order(fbc_similarity_d)



* -------------------------------------------------------- * 
						* Setbacks  *
* -------------------------------------------------------- * 

* location *
reg setbacks fbc_similarity_d latitude longitude i.state_enc, r
estimates store e1

* city area *
reg setbacks fbc_similarity_d latitude longitude i.state_enc log_area_km_10, r
estimates store e2

* type of place *
reg setbacks fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc, r
estimates store e3

* Year of zoning *
reg setbacks fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e4

* subset 1950 *
reg setbacks_1950 fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e5


estout e1 e2 e3 e4 e5 using "$tables_path/ols_setbacks_dummy.tex", style(tex) ///
varlabels(fbc_similarity_d "High-FBC (top 20\%)" 2.type_area_enc "city" 3.type_area_enc "county" 4.type_area_enc "town" 5.type_area_enc "village") ///
cells(b(star fmt(%9.3f)) se(par)) stats(N r2, fmt(%7.0f %7.2f) labels("Observations" "R-squared")) ///
nolabel replace mlabels(none) collabels(none) starlevels(\$^{*}\$ .1 \$^{**}\$ .05 \$^{***}\$ .01) ///
keep(fbc_similarity_d) ///
order(fbc_similarity_d)


* -------------------------------------------------------- * 
						* Setbacks SD *
* -------------------------------------------------------- * 

* location *
reg setbacks_sd fbc_similarity_d latitude longitude i.state_enc, r
estimates store e1

* city area *
reg setbacks_sd fbc_similarity_d latitude longitude i.state_enc log_area_km_10, r
estimates store e2

* type of place *
reg setbacks_sd fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc, r
estimates store e3

* Year of zoning *
reg setbacks_sd fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e4

* subset 1950 *
reg setbacks_sd_1950 fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e5


estout e1 e2 e3 e4 e5 using "$tables_path/ols_setbacks_sd_dummy.tex", style(tex) ///
varlabels(fbc_similarity_d "High-FBC (top 20\%)" 2.type_area_enc "city" 3.type_area_enc "county" 4.type_area_enc "town" 5.type_area_enc "village") ///
cells(b(star fmt(%9.3f)) se(par)) stats(N r2, fmt(%7.0f %7.2f) labels("Observations" "R-squared")) ///
nolabel replace mlabels(none) collabels(none) starlevels(\$^{*}\$ .1 \$^{**}\$ .05 \$^{***}\$ .01) ///
keep(fbc_similarity_d) ///
order(fbc_similarity_d)


* -------------------------------------------------------- * 
						* FAR  *
* -------------------------------------------------------- * 

* location *
reg far fbc_similarity_d latitude longitude i.state_enc, r
estimates store e1

* city area *
reg far fbc_similarity_d latitude longitude i.state_enc log_area_km_10, r
estimates store e2

* type of place *
reg far fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc, r
estimates store e3

* Year of zoning *
reg far fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e4

* subset 1950 *
reg far_1950 fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e5



estout e1 e2 e3 e4 e5 using "$tables_path/ols_far_dummy.tex", style(tex) ///
varlabels(fbc_similarity_d "High-FBC (top 20\%)" 2.type_area_enc "city" 3.type_area_enc "county" 4.type_area_enc "town" 5.type_area_enc "village") ///
cells(b(star fmt(%9.3f)) se(par)) stats(N r2, fmt(%7.0f %7.2f) labels("Observations" "R-squared")) ///
nolabel replace mlabels(none) collabels(none) starlevels(\$^{*}\$ .1 \$^{**}\$ .05 \$^{***}\$ .01) ///
keep(fbc_similarity_d) ///
order(fbc_similarity_d)

 
* -------------------------------------------------------- * 
						* Walkscore  *
* -------------------------------------------------------- * 

* location *
reg walkscore fbc_similarity_d latitude longitude i.state_enc, r
estimates store e1

* city area *
reg walkscore fbc_similarity_d latitude longitude i.state_enc log_area_km_10, r
estimates store e2

* type of place *
reg walkscore fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc, r
estimates store e3


* Year of zoning *
reg walkscore fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e4

* subset 1950 *
reg walkscore_1950 fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e5


estout e1 e2 e3 e4 e5 using "$tables_path/ols_walkscore_dummy.tex", style(tex) ///
varlabels(fbc_similarity_d "High-FBC (top 20\%)" 2.type_area_enc "city" 3.type_area_enc "county" 4.type_area_enc "town" 5.type_area_enc "village") ///
cells(b(star fmt(%9.3f)) se(par)) stats(N r2, fmt(%7.0f %7.2f) labels("Observations" "R-squared")) ///
nolabel replace mlabels(none) collabels(none) starlevels(\$^{*}\$ .1 \$^{**}\$ .05 \$^{***}\$ .01) ///
keep(fbc_similarity_d) ///
order(fbc_similarity_d)



* -------------------------------------------------------- * 
						* Minimum plot size  *
* -------------------------------------------------------- * 

* location *
reg plotsize fbc_similarity_d latitude longitude i.state_enc, r
estimates store e1

* city area *
reg plotsize fbc_similarity_d latitude longitude i.state_enc log_area_km_10, r
estimates store e2

* type of place *
reg plotsize fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc, r
estimates store e3

* Year of zoning *
reg plotsize fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e4

* subset 1950 *
reg plotsize_1950 fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e5


estout e1 e2 e3 e4 e5 using "$tables_path/ols_minplot_dummy.tex", style(tex) ///
varlabels(fbc_similarity_d "High-FBC (top 20\%)" 2.type_area_enc "city" 3.type_area_enc "county" 4.type_area_enc "town" 5.type_area_enc "village") ///
cells(b(star fmt(%9.3f)) se(par)) stats(N r2, fmt(%7.0f %7.2f) labels("Observations" "R-squared")) ///
nolabel replace mlabels(none) collabels(none) starlevels(\$^{*}\$ .1 \$^{**}\$ .05 \$^{***}\$ .01) ///
keep(fbc_similarity_d) ///
order(fbc_similarity_d)



* -------------------------------------------------------- * 
		     	* Multi-Family Housing  *
* -------------------------------------------------------- * 

* location *
reg mhousing fbc_similarity_d latitude longitude i.state_enc, r
estimates store e1

* city area *
reg mhousing fbc_similarity_d latitude longitude i.state_enc log_area_km_10, r
estimates store e2

* type of place *
reg mhousing fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc, r
estimates store e3

* Year of zoning *
reg mhousing fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e4

* subset 1950 *
reg mhousing_1950 fbc_similarity_d latitude longitude i.state_enc log_area_km_10 i.type_area_enc zoning_1982_1996 zoning_1996_2008 zoning_2008_2016 zoning_2016_2021, r
estimates store e5


estout e1 e2 e3 e4 e5 using "$tables_path/ols_multi-family_dummy.tex", style(tex) ///
varlabels(fbc_similarity_d "High-FBC (top 20\%)" 2.type_area_enc "city" 3.type_area_enc "county" 4.type_area_enc "town" 5.type_area_enc "village") ///
cells(b(star fmt(%9.3f)) se(par)) stats(N r2, fmt(%7.0f %7.2f) labels("Observations" "R-squared")) ///
nolabel replace mlabels(none) collabels(none) starlevels(\$^{*}\$ .1 \$^{**}\$ .05 \$^{***}\$ .01) ///
keep(fbc_similarity_d) ///
order(fbc_similarity_d)
