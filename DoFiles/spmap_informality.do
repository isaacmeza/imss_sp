
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
* Modifications: Only years 2005, 2015
* Files used:     
		- 
* Files created:  

* Purpose: Spatial maps of informality

*******************************************************************************/
*/

use "$directorio\Data Created\sdemt_enoe.dta", clear
merge m:1 ent mun using "$directorio\_aux\mexmunidb.dta", keep(3)

*Informal 
gen byte informal = (emp_ppal==1) if emp_ppal!=0 & !missing(emp_ppal)
gen byte noimss = !inlist(imssissste,1) if !inlist(imssissste,0,5,6) & !missing(imssissste)


***********************************
**** 		   SPMAP	  	  *****
***********************************

collapse (mean) informal noimss  [fw=fac], by(year ent mun _ID)
foreach var of varlist informal noimss  {
	 format `var' %4.2f
}


colorpalette plasma, n(22) nograph reverse 
local colors `r(p)'

foreach yr in 2005 2015 {
	spmap informal using "$directorio\_aux\mexmunicoord.dta" if year==`yr', id(_ID) fcolor("`colors'")  ocolor(gs6 ..) osize(0.03 ..) ///
	polygon(data("$directorio\_aux\mexstatecoord.dta") ocolor(white) osize(0.15)) ///
	 ndfcolor(white) ndocolor(gs6 ..) ndsize(0.03 ..)  /// 
	 clm(custom) clb(0(.05)1)  legend(size(2.5)) 
	 graph export "$directorio/Figuras/spmap_informal_`yr'.pdf", replace
	 graph export "$directorio/Figuras/spmap_informal_`yr'.png", replace
	 
	 spmap noimss using "$directorio\_aux\mexmunicoord.dta" if year==`yr', id(_ID) fcolor("`colors'")  ocolor(gs6 ..) osize(0.03 ..) ///
	polygon(data("$directorio\_aux\mexstatecoord.dta") ocolor(white) osize(0.15)) ///
	 ndfcolor(white) ndocolor(gs6 ..) ndsize(0.03 ..)  /// 
	 clm(custom) clb(0(.05)1)  legend(size(2.5)) 
	 graph export "$directorio/Figuras/spmap_noimss_`yr'.pdf", replace
	 graph export "$directorio/Figuras/spmap_noimss_`yr'.png", replace
}