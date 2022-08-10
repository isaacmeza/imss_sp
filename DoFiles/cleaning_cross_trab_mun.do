
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: Aug. 08, 2022
* Modifications: Include heterogeneity in size, wage, and married
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

preserve
*COLLAPSE BY SIZE
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

gen sexo_cross = (sexoS1*taS1 + sexoS2*taS2 + sexoS3*taS3 + sexoS4*taS4 + sexoS5*taS5 + sexoS6*taS6 + sexoS7*taS7 + sexoS8*taS8)/ta_cross

gen sal_cierre_cross = (sal_cierreS1*taS1 + sal_cierreS2*taS2 + sal_cierreS3*taS3 + sal_cierreS4*taS4 + sal_cierreS5*taS5 + sal_cierreS6*taS6 + sal_cierreS7*taS7 + sal_cierreS8*taS8)/ta_cross

gen edad_final_cross = (edad_finalS1*taS1 + edad_finalS2*taS2 + edad_finalS3*taS3 + edad_finalS4*taS4 + edad_finalS5*taS5 + edad_finalS6*taS6 + edad_finalS7*taS7 + edad_finalS8*taS8)/ta_cross

tempfile temp_bysize
save `temp_bysize'
restore

*-------------------------------------------------------------------------------

preserve
*COLLAPSE BY LOW/HIGH WAGE 
su sal_cierre, d
gen high_wage = sal_cierre >= `r(p50)' if !missing(sal_cierre)
collapse (sum) ta te (mean) sexo sal_cierre edad_final, by(year quarter cve_mun_final cve_ent_final high_wage)

*Recoding municipality
rename cve_mun_final municipio
merge m:1 municipio using "Data Original\merge_ss_eneu_final.dta", keepusing(cvemun) keep(1 3) nogen
drop if missing(cvemun)

*ADD OVER MUNICIPALITIES THAT ARE COMPRISED IN TWO SS CODES
collapse (sum) ta te , by(cvemun year quarter high_wage)
drop if missing(cvemun)

*Reshape
drop if missing(high_wage)
tostring high_wage, replace
reshape wide ta te , i(cvemun year quarter) j(high_wage) string

*Imputation
foreach var of varlist ta* te*  {
	replace `var' = 0 if missing(`var')
}

rename (ta0 ta1 te0 te1) (ta_low_wage ta_high_wage te_low_wage te_high_wage)
tempfile temp_bywage
save `temp_bywage'
restore

*-------------------------------------------------------------------------------

preserve
*COLLAPSE BY MARRIED STATUS
rename id_pareja casado
collapse (sum) ta te (mean) sexo sal_cierre edad_final, by(year quarter cve_mun_final cve_ent_final casado)

*Recoding municipality
rename cve_mun_final municipio
merge m:1 municipio using "Data Original\merge_ss_eneu_final.dta", keepusing(cvemun) keep(1 3) nogen
drop if missing(cvemun)

*ADD OVER MUNICIPALITIES THAT ARE COMPRISED IN TWO SS CODES
collapse (sum) ta te , by(cvemun year quarter casado)
drop if missing(cvemun)

*Reshape
drop if missing(casado)
tostring casado, replace
reshape wide ta te , i(cvemun year quarter) j(casado) string

*Imputation
foreach var of varlist ta* te*  {
	replace `var' = 0 if missing(`var')
}

rename (ta0 ta1 te0 te1) (ta_soltero ta_casado te_soltero te_casado)
tempfile temp_bymarried
save `temp_bymarried'
restore

*-------------------------------------------------------------------------------

use `temp_bysize', clear
merge 1:1 cvemun year quarter using `temp_bywage', nogen
merge 1:1 cvemun year quarter using `temp_bymarried', nogen

save "$directorio/Data Created/cross_trabajadores_mun.dta", replace