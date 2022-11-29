
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

************************	 		ASG - IMSS 			************************
********************************************************************************

use "$directorio/Data Created/append_asg_2000_2015.dta", clear
drop _merge

drop if cve_municipio=="Y44" & cve_entidad==21
*Date
destring anio, gen(year)
keep if mes=="mar" | mes=="jun" | mes=="sep" | mes=="dic"

gen quarter = .
replace quarter = 1 if mes=="mar"
replace quarter = 2 if mes=="jun"
replace quarter = 3 if mes=="sep"
replace quarter = 4 if mes=="dic"
gen date = yq(year, quarter)
format date %tq

*Encode
replace employer_size = "A1" if employer_size=="1"
replace employer_size = "B2-5" if employer_size=="2-5"
replace employer_size = "C6-50" if employer_size=="6-50"
replace employer_size = "D51-250" if employer_size=="51-250"
replace employer_size = "E251-500" if employer_size=="251-500"
replace employer_size = "F501-1000" if employer_size=="501-1000"
replace employer_size = "G1000+" if employer_size=="1000+"
replace employer_size = "HNA" if employer_size=="NA"

encode employer_size, gen(size)
encode cve_municipio, gen(mun)

egen cve_dte = group(mun date)

*Reshape
keep sexo masa_sal_ta masa_sal_teu masa_sal_tec masa_sal_tpu masa_sal_tpc asegurados no_trabajadores afiliados_imss trab_eventual_urb trab_eventual_campo trab_perm_urb trab_perm_campo ta_sal teu_sal tec_sal tpu_sal tpc_sal cve_dte size cve_municipio year quarter

reshape wide sexo masa_sal_ta masa_sal_teu masa_sal_tec masa_sal_tpu masa_sal_tpc asegurados no_trabajadores afiliados_imss trab_eventual_urb trab_eventual_campo trab_perm_urb trab_perm_campo ta_sal teu_sal tec_sal tpu_sal tpc_sal, i(cve_dte) j(size)


*Recoding municipality
rename cve_municipio municipio
merge m:1 municipio using "Data Original\merge_ss_eneu_final.dta", keepusing(cvemun) keep(1 3) nogen
drop if missing(cvemun)

*Imputation
foreach var of varlist sexo* masa_sal_ta* masa_sal_teu* masa_sal_tec* masa_sal_tpu* masa_sal_tpc* asegurados* no_trabajadores* afiliados_imss* trab_eventual_urb* trab_eventual_campo* trab_perm_urb* trab_perm_campo* ta_sal* teu_sal* tec_sal* tpu_sal* tpc_sal* {
	replace `var' = 0 if missing(`var')
}

foreach var in asegurados no_trabajadores afiliados_imss trab_eventual_urb trab_eventual_campo trab_perm_urb trab_perm_campo ta_sal teu_sal tec_sal tpu_sal tpc_sal {
	egen `var' = rowtotal(`var'*)
}

gen sexo = (sexo1*asegurados1 + sexo2*asegurados2 + sexo3*asegurados3 + sexo4*asegurados4 + sexo5*asegurados5 + sexo6*asegurados6 + sexo7*asegurados7 + sexo8*asegurados8)/asegurados

gen masa_sal_ta = (masa_sal_ta1*ta_sal1 + masa_sal_ta2*ta_sal2 + masa_sal_ta3*ta_sal3 + masa_sal_ta4*ta_sal4 + masa_sal_ta5*ta_sal5 + masa_sal_ta6*ta_sal6 + masa_sal_ta7*ta_sal7 + masa_sal_ta8*ta_sal8)/ta_sal
replace masa_sal_ta = 0 if missing(masa_sal_ta)

gen masa_sal_teu = (masa_sal_teu1*teu_sal1 + masa_sal_teu2*teu_sal2 + masa_sal_teu3*teu_sal3 + masa_sal_teu4*teu_sal4 + masa_sal_teu5*teu_sal5 + masa_sal_teu6*teu_sal6 + masa_sal_teu7*teu_sal7 + masa_sal_teu8*teu_sal8)/teu_sal
replace masa_sal_teu = 0 if missing(masa_sal_teu)

gen masa_sal_tec = (masa_sal_tec1*tec_sal1 + masa_sal_tec2*tec_sal2 + masa_sal_tec3*tec_sal3 + masa_sal_tec4*tec_sal4 + masa_sal_tec5*tec_sal5 + masa_sal_tec6*tec_sal6 + masa_sal_tec7*tec_sal7 + masa_sal_tec8*tec_sal8)/tec_sal
replace masa_sal_tec = 0 if missing(masa_sal_tec)

gen masa_sal_tpu = (masa_sal_tpu1*tpu_sal1 + masa_sal_tpu2*tpu_sal2 + masa_sal_tpu3*tpu_sal3 + masa_sal_tpu4*tpu_sal4 + masa_sal_tpu5*tpu_sal5 + masa_sal_tpu6*tpu_sal6 + masa_sal_tpu7*tpu_sal7 + masa_sal_tpu8*tpu_sal8)/tpu_sal
replace masa_sal_tpu = 0 if missing(masa_sal_tpu)

gen masa_sal_tpc = (masa_sal_tpc1*tpc_sal1 + masa_sal_tpc2*tpc_sal2 + masa_sal_tpc3*tpc_sal3 + masa_sal_tpc4*tpc_sal4 + masa_sal_tpc5*tpc_sal5 + masa_sal_tpc6*tpc_sal6 + masa_sal_tpc7*tpc_sal7 + masa_sal_tpc8*tpc_sal8)/tpc_sal
replace masa_sal_tpc = 0 if missing(masa_sal_tpc)

*ADD OVER MUNICIPALITIES THAT ARE COMPRISED IN TWO SS CODES
collapse (sum)  asegurados* no_trabajadores* afiliados_imss* trab_eventual_urb* trab_eventual_campo* trab_perm_urb* trab_perm_campo* ta_sal* teu_sal* tec_sal* tpu_sal* tpc_sal* (mean) sexo* masa_sal_ta* masa_sal_teu* masa_sal_tec* masa_sal_tpu* masa_sal_tpc*, by(cvemun year quarter)
drop if missing(cvemun)

save "$directorio/Data Created/asg_imss.dta", replace

