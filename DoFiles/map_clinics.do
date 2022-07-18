
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	June. 29, 2022
* Last date of modification: 
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Spatial maps of clinics

*******************************************************************************/
*/

use "_aux\clues_lat_lon.dta", clear	

replace totaldeconsultorios = .01 if totaldeconsultorios==0 & !missing(totaldeconsultorios)

************	MAP		************
************************************

twoway (scatter lat lon  [w=totaldeconsultorios] if date04==1, color("31 119 180"%25) ms(Oh) msize(vsmall)) ///
		(scatter lat lon  [w=totaldeconsultorios] if date04==1 & inlist(clave,6,7), ms(Oh) msize(vsmall) color(maroon%50)) ///
		(scatter lat lon if date04==1 & nivel==3, ms(X) msize(tiny)) ///
		, legend(order(1 "All clinics" 2 "IMSS" 3 "Second level") rows(1) pos(6)) xtitle("") ytitle("") yscale(lstyle(none)) xscale(lstyle(none)) xlab(none) ylab(none) 
graph export "$directorio/Figuras/map_clinics_04.pdf", replace
	
		
twoway (scatter lat lon  [w=totaldeconsultorios] if date07==1 & date04!=1, color("31 119 180"%25) ms(Oh) msize(vsmall)) ///
		(scatter lat lon  [w=totaldeconsultorios] if date07==1 & date04!=1 & inlist(clave,6,7), ms(Oh) msize(vsmall) color(maroon%50)) ///
		(scatter lat lon if date07==1 & date04!=1 & nivel==3, ms(X) msize(tiny)) ///
		, legend(order(1 "All clinics" 2 "IMSS" 3 "Second level") rows(1) pos(6)) xtitle("") ytitle("") yscale(lstyle(none)) xscale(lstyle(none)) xlab(none) ylab(none)
graph export "$directorio/Figuras/map_clinics_07.pdf", replace		