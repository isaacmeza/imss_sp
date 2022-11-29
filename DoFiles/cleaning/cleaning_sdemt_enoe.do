
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	June. 06, 2022
* Last date of modification: June. 29, 2022
* Modifications: Consider only 2005-2015 
	Occupation labels in english.
* Files used:     
		- 
* Files created:  

* Purpose: Cleaning of SDEMT module of ENOE

*******************************************************************************/
*/

*Variables to keep in the analysis
local vars sex eda n_hij e_con anios_esc hrsocup ingocup ing_x_hrs imssissste scian t_tra emp_ppal tue_ppal mh_fil2 mh_col sec_ins clase1

clear all
set obs 1
gen year = -1
gen quarter = -1

foreach year in 05 06 07 08 09 10 11 12 13 14 15 {
	foreach qr in 1 2 3 4 {
		di "`year'" "`qr'"
		qui append using "$directorio\Data Original\ENE_ENOE\ENOE\SDEMT`qr'`year'.dta", keep(cd_a ent con v_sel n_hog h_mud n_ren n_ent mun fac `vars') 
		qui replace year = 2000 + `year' if missing(year)
		qui replace quarter = `qr' if missing(quarter)
	}
}

drop if year==-1
compress

label drop scian
label define scian 0 "NA" ///
1 "Agriculture & Livestock" ///
2 "Mining" ///
3 "Electricity" ///
4 "Construction" ///
5 "Manufacturing" ///
6 "Wholesale trade" ///
7 "Retail trade" ///
8 "Transportation, Mail & Storage" ///
9 "Mass media" ///
10 "Financial services" ///
11 "Real state" ///
12 "Professional services" ///
13 "Corporations" ///
14 "Consulting" ///
15 "Education services" ///
16 "Health services" ///
17 "Leisure" ///
18 "Tourism" ///
19 "Other services" ///
20 "Governmental activities" ///
21 "Not specified" 

label values scian scian

save "$directorio\Data Created\sdemt_enoe.dta", replace