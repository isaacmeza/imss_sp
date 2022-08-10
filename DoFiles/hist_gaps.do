
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: July. 07, 2022
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Count gaps in employment with IMSS and frequency of 'attrition'

*******************************************************************************/
*/

use "$directorio/Data Created/panel_trabajadores.dta", clear


*******************************************************************************
*******************************************************************************
tab nm_gap
su num_active_periods porc_gaps mn_timegaps times_switch

*Histogram % gaps
twoway (hist porc_gaps, percent xtitle("% gaps"))
graph export "$directorio/Figuras/hist_gaps.pdf", replace	

*Histogram time span
twoway (hist mn_timegaps, percent xtitle("Avg time span not in IMSS (quarters)"))
graph export "$directorio/Figuras/hist_timespan.pdf", replace

*Histogram times switched
twoway (hist times_switch, discrete percent xtitle("# switches")) 
graph export "$directorio/Figuras/hist_timeswitch.pdf", replace