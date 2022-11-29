
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


spmap porc_inf using "$directorio\_aux\mexmunicoord.dta" if year==2000, id(_ID) fcolor("`colors'") clnumber(24) osize(0.03 ..) ///
		polygon(data("$directorio\_aux\mexstatecoord.dta") ocolor(white) osize(0.15)) legend(size(medsmall))
graph export "$directorio/Figuras/spmap_porc_inf_2000.pdf", replace
graph export "$directorio/Figuras/spmap_porc_inf_2000.png", replace	
 