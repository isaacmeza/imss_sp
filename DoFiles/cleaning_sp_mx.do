
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	June. 15, 2022
* Last date of modification: 
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Clean spatial maps MX

*******************************************************************************/
*/


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
