
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	June. 06, 2022
* Last date of modification: June. 15, 2022
* Modifications: Consider only 2005-2015 
* Files used:     
		- 
* Files created:  

* Purpose: Cleaning of COE1T module of ENOE

*******************************************************************************/
*/

*Variables to keep in the analysis
local vars p4g

clear all
set obs 1
gen year = -1
gen quarter = -1

foreach year in 05 06 07 08 09 10 11 12 13 14 15 {
	foreach qr in 1 2 3 4 {
		di "`year'" "`qr'"
		qui append using "$directorio\Data Original\ENE_ENOE\ENOE\COE1T`qr'`year'.dta", keep(cd_a ent con v_sel n_hog h_mud n_ren n_ent `vars') 
		qui replace year = 2000 + `year' if missing(year)
		qui replace quarter = `qr' if missing(quarter)
	}
}

drop if year==-1
compress
save "$directorio\Data Created\coe1t_enoe.dta", replace