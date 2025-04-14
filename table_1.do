*code to reproduce the results in Table 1
*"An AI-based analysis of zoning reforms in US cities"

*---------------------------------------------------------*
					* Set global paths *
*---------------------------------------------------------*
global rep_path "" /*"/path/to/replication_package" */

global data_path "$rep_path/data"
global tables_path "$rep_path/tables"

* -------------------------------------------------------- * 
	   * Clean fips codes for drei or nu documents *
* -------------------------------------------------------- * 
use "$data_path/descriptive_nu_zoning.dta", clear


* -------------------------------------------------------- * 
					*** Log Population ***
* -------------------------------------------------------- * 

local var l_pope

file open myfile1 using "$rep_path/tables/table_sum1_`var'.tex", write replace
file open myfile2 using "$rep_path/tables/table_sum2_`var'.tex", write replace
file write myfile1 "\multirow{2}{7cm}{Population (Log)\dotfill}&"
file write myfile2 "&"


*Full Sample*
sum `var' if fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " & "
file write myfile2 " [" %9.3f (r(sd)) "] & "

*High FBC*
sum `var' if fbc_similarity_d == 1 & fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " & "
file write myfile2 " [" %9.3f (r(sd)) "] & "

*Low FBC*
sum `var' if fbc_similarity_d == 0 & fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " \\  "
file write myfile2 " [" %9.3f (r(sd)) ") \\ "

file close myfile1 
file close myfile2


* -------------------------------------------------------- * 
					*** Median Income ***
* -------------------------------------------------------- * 

local var medincome

file open myfile1 using "$rep_path/tables/table_sum1_`var'.tex", write replace
file open myfile2 using "$rep_path/tables/table_sum2_`var'.tex", write replace
file write myfile1 "\multirow{2}{7cm}{Median Income\dotfill}&"
file write myfile2 "&"


*Full Sample*
sum `var' if fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " & "
file write myfile2 " [" %9.3f (r(sd)) "] & "

*High FBC*
sum `var' if fbc_similarity_d == 1 & fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " & "
file write myfile2 " [" %9.3f (r(sd)) "] & "

*Low FBC*
sum `var' if fbc_similarity_d == 0 & fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " \\  "
file write myfile2 " [" %9.3f (r(sd)) ") \\ "

file close myfile1 
file close myfile2


* -------------------------------------------------------- * 
		*** Percentage with College Degree ***
* -------------------------------------------------------- * 

local var perc_collegee

file open myfile1 using "$rep_path/tables/table_sum1_`var'.tex", write replace
file open myfile2 using "$rep_path/tables/table_sum2_`var'.tex", write replace
file write myfile1 "\multirow{2}{7cm}{\% College Degree\dotfill}&"
file write myfile2 "&"


*Full Sample*
sum `var' if fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " & "
file write myfile2 " [" %9.3f (r(sd)) "] & "

*High FBC*
sum `var' if fbc_similarity_d == 1 & fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " & "
file write myfile2 " [" %9.3f (r(sd)) "] & "

*Low FBC*
sum `var' if fbc_similarity_d == 0 & fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " \\  "
file write myfile2 " [" %9.3f (r(sd)) ") \\ "

file close myfile1 
file close myfile2

* -------------------------------------------------------- * 
		   	*** Percentage Foreign Born ***
* -------------------------------------------------------- * 

local var perc_foreignborne

file open myfile1 using "$rep_path/tables/table_sum1_`var'.tex", write replace
file open myfile2 using "$rep_path/tables/table_sum2_`var'.tex", write replace
file write myfile1 "\multirow{2}{7cm}{\% Foreign Born\dotfill}&"
file write myfile2 "&"


*Full Sample*
sum `var' if fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " & "
file write myfile2 " [" %9.3f (r(sd)) "] & "

*High FBC*
sum `var' if fbc_similarity_d == 1 & fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " & "
file write myfile2 " [" %9.3f (r(sd)) "] & "

*Low FBC*
sum `var' if fbc_similarity_d == 0 & fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " \\  "
file write myfile2 " [" %9.3f (r(sd)) ") \\ "


file close myfile1 
file close myfile2

* -------------------------------------------------------- * 
		   	*** Percentage Over 65 ***
* -------------------------------------------------------- * 

local var perc_over65e

file open myfile1 using "$rep_path/tables/table_sum1_`var'.tex", write replace
file open myfile2 using "$rep_path/tables/table_sum2_`var'.tex", write replace
file write myfile1 "\multirow{2}{7cm}{\% Over 65 Years\dotfill}&"
file write myfile2 "&"


*Full Sample*
sum `var' if fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " & "
file write myfile2 " [" %9.3f (r(sd)) "] & "

*High FBC*
sum `var' if fbc_similarity_d == 1 & fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " & "
file write myfile2 " [" %9.3f (r(sd)) "] & "

*Low FBC*
sum `var' if fbc_similarity_d == 0 & fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " \\  "
file write myfile2 " [" %9.3f (r(sd)) ") \\ "

file close myfile1 
file close myfile2

* -------------------------------------------------------- * 
			*** Percentage Owner Occupied ***
* -------------------------------------------------------- * 

local var perc_own_occe

file open myfile1 using "$rep_path/tables/table_sum1_`var'.tex", write replace
file open myfile2 using "$rep_path/tables/table_sum2_`var'.tex", write replace
file write myfile1 "\multirow{2}{7cm}{\% Owner Occupied Housing\dotfill}&"
file write myfile2 "&"


*Full Sample*
sum `var' if fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " & "
file write myfile2 " [" %9.3f (r(sd)) "] & "

*High FBC*
sum `var' if fbc_similarity_d == 1 & fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " & "
file write myfile2 " [" %9.3f (r(sd)) "] & "

*Low FBC*
sum `var' if fbc_similarity_d == 0 & fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " \\  "
file write myfile2 " [" %9.3f (r(sd)) ") \\ "



file close myfile1 
file close myfile2


* -------------------------------------------------------- * 
			*** Percentage White ***
* -------------------------------------------------------- * 

local var perc_whte

file open myfile1 using "$rep_path/tables/table_sum1_`var'.tex", write replace
file open myfile2 using "$rep_path/tables/table_sum2_`var'.tex", write replace
file write myfile1 "\multirow{2}{7cm}{\% White\dotfill}&"
file write myfile2 "&"


*Full Sample*
sum `var' if fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " & "
file write myfile2 " [" %9.3f (r(sd)) "] & "

*High FBC*
sum `var' if fbc_similarity_d == 1 & fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " & "
file write myfile2 " [" %9.3f (r(sd)) "] & "

*Low FBC*
sum `var' if fbc_similarity_d == 0 & fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " \\  "
file write myfile2 " [" %9.3f (r(sd)) ") \\ "


file close myfile1 
file close myfile2


* -------------------------------------------------------- * 
		     	*** Unemploynment Rate ***
* -------------------------------------------------------- * 

local var ue_ratee

file open myfile1 using "$rep_path/tables/table_sum1_`var'.tex", write replace
file open myfile2 using "$rep_path/tables/table_sum2_`var'.tex", write replace
file write myfile1 "\multirow{2}{7cm}{Unemployment Rate\dotfill}&"
file write myfile2 "&"


*Full Sample*
sum `var' if fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " & "
file write myfile2 " [" %9.3f (r(sd)) "] & "

*High FBC*
sum `var' if fbc_similarity_d == 1 & fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " & "
file write myfile2 " [" %9.3f (r(sd)) "] & "

*Low FBC*
sum `var' if fbc_similarity_d == 0 & fbc_similarity_d != .
file write myfile1 %9.3f (r(mean)) " \\  "
file write myfile2 " [" %9.3f (r(sd)) ") \\ "


file close myfile1 
file close myfile2
