
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	July. 31, 2022
* Last date of modification: 
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Geographical coverage of SP

*******************************************************************************/
*/

use  "Data Created\DiD_DB.dta", clear	
keep if SP_b_p==0
gen mun = cvemun - ent*1000
keep ent mun cvemun date 
merge m:1 ent mun using "$directorio\_aux\mexmunidb.dta", keep(3)


***********************************
**** 		   SPMAP	  	  *****
***********************************

colorpalette HCL blues, select(1/24) nograph 
local colors `r(p)'

spmap date using "$directorio\_aux\mexmunicoord.dta", id(_ID) fcolor("`colors'") clnumber(24) osize(0.03 ..) ///
	polygon(data("$directorio\_aux\mexstatecoord.dta") ocolor(white) osize(0.15)) legend(size(medsmall))
graph export "$directorio/Figuras/sp_geo_coverage.pdf", replace
graph export "$directorio/Figuras/sp_geo_coverage.png", replace
