
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Roberto González
* Machine:	Isaac M 											
* Date of creation:	Aug. 01, 2022
* Last date of modification: 
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Out-of-pocket yearly expenditure graph
*******************************************************************************/
*/

// Read in data for the graph
use "$directorio\Data Created\base_hh_year_health_expenditure.dta", clear

// Collapse data at the year level
collapse (mean) p_* oop_* aten_* hosp* med* [fw = factor_hog], by(year)


// Make timeline of evolution of expenditure as percentages
twoway (line p_oop_salud year, lwidth(medthick) lcolor(navy)) ///
	   (line p_aten_pri year, lwidth(medthick) lcolor(dkgreen)) ///
	   (line p_hospital year, lwidth(medthick) lcolor(cranberry)) ///
	   (line p_med_sin_receta year, lwidth(medthick) lcolor(lavender)), ///
	   legend(off) ///
	   text(2.1 2012 "Overall", size(medsmall)) ///
	   text(1.6 2011 "Primary care", size(medsmall)) ///
	   text(0.5 2013 "Medication w/o recipe", size(medsmall)) ///
	   text(0.05 2015 "Hospitalization", size(medsmall)) ///
	   xline(2004, lwidth(vthin) lpattern("-") lcolor(black)) ///
	   xline(2018, lwidth(vthin) lpattern("-") lcolor(black)) ///
	   graphregion(color(white)) ///
	   xtitle("Year", size(medium)) xlabel(2000(2)2020, labsize(medsmall)) ///
	   ytitle("Percentage", size(medium)) ylabel(0(0.5)3.5, labs
graph export "$graphs/oop_evolution_percentages.pdf", replace	   