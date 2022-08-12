
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


collapse (sum) patrones afiliados_imss ind, by(date)

replace patrones = patrones/1000000
replace afiliados_imss = afiliados_imss/1000000
replace ind = ind/100000

tsset date
twoway (tsline patrones, yaxis(1) ytitle("Employers (millions)")) (tsline afiliados_imss, yaxis(2) ytitle("Employees (millions)", axis(2))), legend(order(1 "Employers" 2 "Employees") rows(1) pos(6))
graph export "$directorio/Figuras/tsline_emp.pdf", replace	


twoway (tsline ind, yaxis(1) ytitle("SP (100 thousands)")) (tsline afiliados_imss, yaxis(2) ytitle("Employees (millions)", axis(2))), legend(order(1 "SP affiliation" 2 "Employees") rows(1) pos(6))
graph export "$directorio/Figuras/tsline_emp_sp.pdf", replace	