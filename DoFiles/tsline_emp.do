
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	July. 31, 2022
* Last date of modification: Aug. 10, 2022
* Modifications: Added individuals with SP
* Files used:     
		- 
* Files created:  

* Purpose: Time series employment-SP graph

*******************************************************************************/
*/

use  "Data Created\DiD_DB.dta", clear	
keep if year<=2015


collapse (sum) afiliados_imss ind, by(date)

replace afiliados_imss = afiliados_imss/1000000
replace ind = ind/1000000

tsset date

twoway (tsline ind, yaxis(1) ytitle("SP (millions)")) (tsline afiliados_imss, yaxis(2) ytitle("IMSS workers (millions)", axis(2))), xtitle("") legend(order(1 "SP affiliation" 2 "Employees in IMSS") rows(1) pos(6))
graph export "$directorio/Figuras/tsline_emp_sp.pdf", replace	

