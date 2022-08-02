
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	July. 31, 2022
* Last date of modification: 
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Time series employment graph

*******************************************************************************/
*/

use  "Data Created\DiD_DB.dta", clear	
keep if year<=2015


collapse (sum) patrones afiliados_imss, by(date)

replace patrones = patrones/1000000
replace afiliados_imss = afiliados_imss/1000000

tsset date
twoway (tsline patrones, yaxis(1) ytitle("Employers (millions)")) (tsline afiliados_imss, yaxis(2) ytitle("Employees (millions)", axis(2))), legend(order(1 "Employers" 2 "Employees") rows(1) pos(6))
graph export "$directorio/Figuras/tsline_emp.pdf", replace	
