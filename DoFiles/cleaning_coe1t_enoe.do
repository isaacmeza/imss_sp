
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: June. 06, 2022
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Cleaning of COE1T module of ENOE

*******************************************************************************/
*/

*Variables to keep in the analysis
local vars p4g


use "$directorio\Data Original\ENE_ENOE\ENOE\coe1t319.dta", clear
rename *, lower
keep cd_a ent con v_sel n_hog h_mud n_ren n_ent `vars'
gen int year = 2019
gen int quarter = 3
tempfile temp319
save `temp319'

use "$directorio\Data Original\ENE_ENOE\ENOE\coe1t419.dta", clear
rename *, lower
keep cd_a ent con v_sel n_hog h_mud n_ren n_ent `vars'
gen int year = 2019
gen int quarter = 4
tempfile temp419
save `temp419'

use "$directorio\Data Original\ENE_ENOE\ENOE\ENOEN_COE1T120.dta", clear
keep cd_a ent con v_sel n_hog h_mud n_ren n_ent `vars'
gen int year = 2020
gen int quarter = 1
append using `temp319'
append using `temp419'

foreach year in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {
	foreach qr in 1 2 3 4 {
		di "`year'" "`qr'"
		qui append using "$directorio\Data Original\ENE_ENOE\ENOE\COE1T`qr'`year'.dta", keep(cd_a ent con v_sel n_hog h_mud n_ren n_ent `vars') 
		qui replace year = 2000 + `year' if missing(year)
		qui replace quarter = `qr' if missing(quarter)
	}
}

foreach qr in 1 2 {
	di "`qr'"
	qui append using "$directorio\Data Original\ENE_ENOE\ENOE\coe1t`qr'19.dta", keep(cd_a ent con v_sel n_hog h_mud n_ren n_ent `vars')
	qui replace year = 2019 if missing(year)
	qui replace quarter = `qr' if missing(quarter)
}

compress
save "$directorio\Data Created\coe1t_enoe.dta", replace