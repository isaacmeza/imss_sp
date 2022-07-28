
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: July. 27, 2022
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Cleaning IMSS datasets

*******************************************************************************/
*/

************************	 Cross-section - Workers		********************
********************************************************************************

use "$directorio/Data Private/cross_trabajadores.dta", clear

*Woman dummy
replace sexo = sexo-1

*Date
tostring periodo, replace
gen year = substr(periodo,1,4)
gen mes = substr(periodo,5,2)

destring year, replace
destring mes, replace
gen quarter = mes/3

replace size_cierre = "S8" if size_cierre=="NA"
collapse (sum) ta te (mean) sexo sal_cierre edad_final, by(year quarter cve_mun_final cve_ent_final size_cierre)

*Recoding municipality
rename cve_mun_final municipio
merge m:1 municipio using "Data Original\merge_ss_eneu_final.dta", keepusing(cvemun) keep(1 3) nogen
drop if missing(cvemun)

*ADD OVER MUNICIPALITIES THAT ARE COMPRISED IN TWO SS CODES
collapse (sum) ta te (mean) sexo sal_cierre edad_final, by(cvemun year quarter size_cierre)
drop if missing(cvemun)

*Reshape
reshape wide ta te sexo sal_cierre edad_final, i(cvemun year quarter) j(size_cierre) string

*Imputation
foreach var of varlist ta* te* sexo* sal_cierre* edad_final* {
	replace `var' = 0 if missing(`var')
}
foreach var in ta te {
	egen `var'_cross = rowtotal(`var'*)
}

gen sexo_cross = (sexoS1*taS1 + sexoS2*taS2 + sexoS3*taS3 + sexoS4*taS4 + sexoS5*taS5 + sexoS6*taS6 + sexoS7*taS7 + sexoS8*taS8)/ta

gen sal_cierre_cross = (sal_cierreS1*taS1 + sal_cierreS2*taS2 + sal_cierreS3*taS3 + sal_cierreS4*taS4 + sal_cierreS5*taS5 + sal_cierreS6*taS6 + sal_cierreS7*taS7 + sal_cierreS8*taS8)/ta

gen edad_final_cross = (edad_finalS1*taS1 + edad_finalS2*taS2 + edad_finalS3*taS3 + edad_finalS4*taS4 + edad_finalS5*taS5 + edad_finalS6*taS6 + edad_finalS7*taS7 + edad_finalS8*taS8)/ta


save "$directorio/Data Created/cross_trabajadores_mun.dta", replace