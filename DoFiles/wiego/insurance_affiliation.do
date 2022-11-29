
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Roberto González
* Machine:	Isaac M 											
* Date of creation:	Aug. 1, 2022
* Last date of modification: 
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose:  Table of social health security beneficiaries

*******************************************************************************/
*/


use "$directorio/Data Created/derechohabiencia_2000_2020.dta", clear

#delimit ;

graph hbar (mean) frac, over(nombre, label(labsize(vsmall))) legend(off)
	bar(1, color(navy)) bar(2, color(orange)) bar(3, color(black%75)) 
	bar(4, color(midgreen)) bar(5, color(gold)) bar(6, color(cranberry))
	over(year, gap(*3) label(labsize(small) angle(90))) bargap(15) 
	showyvars asyvars
	yscale(r(0 65) noline) 
	ylabel(0 (10) 65, labsize(vsmall) glcolor("224 224 224"))
	ytitle("Percentage", size(small)) 
	blabel(bar, pos(outside) size(vsmall) format(%5.1f)) 
	graphregion(fcolor(white)) ;

graph export "$directorio/Figuras/derechohabiencia.pdf", replace ;
