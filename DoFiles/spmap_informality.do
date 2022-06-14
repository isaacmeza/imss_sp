
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

* Purpose: Spatial maps of informality

*******************************************************************************/
*/

/*
shp2dta using "$directorio\Data Original\SHP\muni_2018gw.shp", database("$directorio\_aux\mexmunidb.dta") coordinates("$directorio\_aux\mexmunicoord.dta") replace

use "$directorio\_aux\mexmunidb.dta", clear	
destring CVE_ENT, gen(ent)	
destring CVE_MUN, gen(mun)	
save "$directorio\_aux\mexmunidb.dta", replace	

*Mercator projection
use "$directorio\_aux\mexmunicoord.dta", clear
geo2xy _Y _X, proj(web_mercator) replace
save "$directorio\_aux\mexmunicoord.dta", replace


shp2dta using "$directorio\Data Original\SHP\MEX_adm1.shp", database("$directorio\_aux\mexstatedb.dta") coordinates("$directorio\_aux\mexstatecoord.dta") replace

use "$directorio\_aux\mexstatedb.dta", clear	
gen ent = _ID
save "$directorio\_aux\mexstatedb.dta", replace	

*Mercator projection
use "$directorio\_aux\mexstatecoord.dta", clear
geo2xy _Y _X, proj(web_mercator) replace
save "$directorio\_aux\mexstatecoord.dta", replace
*/

use "$directorio\Data Created\sdemt_enoe.dta", clear
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren year quarter using "$directorio\Data Created\coe1t_enoe.dta", nogen
append using "$directorio\Data Created\ene.dta", gen(ene)
merge m:1 ent mun using "$directorio\_aux\mexmunidb.dta", keep(3)


*Informal 
gen byte informal = (emp_ppal==1) if emp_ppal!=0 & !missing(emp_ppal)
gen byte noimss = !inlist(imssissste,1) if !inlist(imssissste,0,5,6) & !missing(imssissste)
gen byte noatencion_medica = !inlist(imssissste,1,2,3) if !inlist(imssissste,0,5,6) & !missing(imssissste)
gen byte nosat = (p4g!=3) if p4g!=9 & !missing(p4g)
gen byte informal_hussmann = (mh_fil2==1) if mh_fil2!=0 & !missing(mh_fil2)
replace informal_hussmann = (tue2==5) if tue2!=0 & ene==1


***********************************
**** 		   SPMAP	  	  *****
***********************************

collapse (mean) informal noimss noatencion_medica nosat informal_hussmann [fw=fac], by(year ent mun _ID)
foreach var of varlist informal noimss noatencion_medica nosat informal_hussmann {
	 format `var' %4.2f
}


colorpalette plasma, n(22) nograph reverse 
local colors `r(p)'

forvalues yr = 2000/2004 {
	spmap informal_hussmann using "$directorio\_aux\mexmunicoord.dta" if year==`yr', id(_ID) fcolor("`colors'")  ocolor(gs6 ..) osize(0.03 ..) ///
	polygon(data("$directorio\_aux\mexstatecoord.dta") ocolor(white) osize(0.15)) ///
	 ndfcolor(white) ndocolor(gs6 ..) ndsize(0.03 ..)  /// 
	 clm(custom) clb(0(.05)1)  legend(size(2.5)) 
	 graph export "$directorio/Figuras/spmap_informal_`yr'.pdf", replace
	 graph export "$directorio/Figuras/spmap_informal_`yr'.png", replace
}

forvalues yr = 2005/2020 {
	spmap informal using "$directorio\_aux\mexmunicoord.dta" if year==`yr', id(_ID) fcolor("`colors'")  ocolor(gs6 ..) osize(0.03 ..) ///
	polygon(data("$directorio\_aux\mexstatecoord.dta") ocolor(white) osize(0.15)) ///
	 ndfcolor(white) ndocolor(gs6 ..) ndsize(0.03 ..)  /// 
	 clm(custom) clb(0(.05)1)  legend(size(2.5)) 
	 graph export "$directorio/Figuras/spmap_informal_`yr'.pdf", replace
	 graph export "$directorio/Figuras/spmap_informal_`yr'.png", replace
}