
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	June. 06, 2022
* Last date of modification: Aug. 05, 2022
* Modifications: Only years 2005, 2015
	Use IMSS data
* Files used:     
		- 
* Files created:  

* Purpose: Spatial maps of informality

*******************************************************************************/
*/

********************************	ENOE DATA		****************************


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

colorpalette HCL heat2, select(1/16) reverse nograph 
local colors `r(p)'

foreach yr in 2005 2015 {
	if `yr'==2005 {
		local legnd "legend(size(medsmall))"
	}
	else {
		local legnd "legend(off)"
	}
	
	spmap informal using "$directorio\_aux\mexmunicoord.dta" if year==`yr', id(_ID) fcolor("`colors'") clnumber(16) osize(0.03 ..) ///
		polygon(data("$directorio\_aux\mexstatecoord.dta") ocolor(white) osize(0.15)) `legnd'
	 graph export "$directorio/Figuras/spmap_informal_`yr'.pdf", replace
	 graph export "$directorio/Figuras/spmap_informal_`yr'.png", replace
	 
	 spmap noimss using "$directorio\_aux\mexmunicoord.dta" if year==`yr', id(_ID) fcolor("`colors'") clnumber(16) osize(0.03 ..) ///
		polygon(data("$directorio\_aux\mexstatecoord.dta") ocolor(white) osize(0.15)) `legnd'
	 graph export "$directorio/Figuras/spmap_noimss_`yr'.pdf", replace
	 graph export "$directorio/Figuras/spmap_noimss_`yr'.png", replace
}


********************************	IMSS DATA		****************************


use "$directorio\Data Created\DiD_DB.dta", clear
gen mun = cvemun - ent*1000
gen pobla = exp(lgpop)
gen porc_for = asegurados/pobla
replace porc_for = 1 if porc_for >1 & !missing(porc_for)
gen porc_inf = 1-porc_for

collapse porc_inf, by(year ent mun)

merge m:1 ent mun using "$directorio\_aux\mexmunidb.dta", keep(1 3)
replace porc_inf = 1 if _merge==1

drop if missing(porc_inf)

***********************************
**** 		   SPMAP	  	  *****
***********************************

format %5.3f porc_inf

colorpalette HCL heat2, select(1/24) reverse nograph 
local colors `r(p)'

foreach yr in 2000 2005 2015 {
	if `yr'==2000 {
		local legnd "legend(size(medsmall))"
	}
	else {
		local legnd "legend(off)"
	}
	
	spmap porc_inf using "$directorio\_aux\mexmunicoord.dta" if year==`yr', id(_ID) fcolor("`colors'") clnumber(24) osize(0.03 ..) ///
		polygon(data("$directorio\_aux\mexstatecoord.dta") ocolor(white) osize(0.15)) `legnd'
	graph export "$directorio/Figuras/spmap_porc_inf_`yr'.pdf", replace
	graph export "$directorio/Figuras/spmap_porc_inf_`yr'.png", replace	
} 