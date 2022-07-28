
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	 July. 20, 2022
* Last date of modification:
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: 

*******************************************************************************/
*/

import delimited "$directorio\Data Original\IMSS\DATOS_ABIERTOS_NODUPES.csv", clear 

*Municipality
rename cve_municipio cvemun


*Date
tostring periodo, replace
gen year = substr(periodo,1,4)
destring year, replace
gen mes = substr(periodo,5,2)
destring mes, replace

keep if inlist(mes,3,6,9,12)
gen quarter = mes/3

*ADD OVER MUNICIPALITIES THAT ARE COMPRISED IN TWO SS CODES
collapse (sum) eventuales_femenino eventuales_masculino permanentes_femenino permanentes_masculino ta_femenino ta_masculino aseg_masculino aseg_femenino patrones voluntarios_masculino voluntarios_femenino regimen_voluntario (mean) salario_promedio, by(cvemun year quarter)

foreach var in eventuales permanentes ta aseg voluntarios {
	egen `var' = rowtotal(`var'*)
}

drop if year>=2020

save  "Data Created\emp_imss.dta", replace	