
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: July. 20, 2022
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Cleaning of mortality dataset

*******************************************************************************/
*/

use "Data Created\mortality_refined.dta", clear

*Keep only nationals
keep if nacionalidad=="Mexicano"

*Generate quarterly date
replace anio_ocurr = anio_regis if anio_ocur==9999
replace mes_ocurr = mes_regis if mes_ocurr==99

gen date = qofd(dofm(ym(anio_ocurr, mes_ocurr)))
format date %tq

cap drop year
gen year = yofd(dofq(date))
gen quarter = quarter(dofq(date))
drop if year<2000

*Generate cvemun
gen cvemun = ent_ocurr*1000 + mun_ocurr
drop if cvemun>33000

*Generate variables of interest (to be collapsed (sum))
	*covariates : sexo edad escolaridad ocupacion edo_civil tipo_area

gen total_d = 1 if (ent_resid==ent_ocurr) & (mun_resid==mun_ocurr)
gen total_d_asist = 1 if asist_medi=="Con asistencia" & (ent_resid==ent_ocurr) & (mun_resid==mun_ocurr)
gen total_d_noasist = 1 if asist_medi=="Sin asistencia" & (ent_resid==ent_ocurr) & (mun_resid==mun_ocurr)

gen total_d_imss = 1 if strpos(derechohab,"IMSS")==1

gen total_d_cov_sp = 1 if rel_cov_sp==1 & (ent_resid==ent_ocurr) & (mun_resid==mun_ocurr)
gen total_d_cov_isp = 1 if inlist(rel_cov_sp,1,2) & (ent_resid==ent_ocurr) & (mun_resid==mun_ocurr)

gen total_d_imss_cov_sp = 1 if strpos(derechohab,"IMSS")==1 & rel_cov_sp==1


*Collapse at the municipality-quarter level
collapse (sum) total_d*, by(cvemun year quarter)

save  "Data Created\mortality_cvemundate.dta", replace


