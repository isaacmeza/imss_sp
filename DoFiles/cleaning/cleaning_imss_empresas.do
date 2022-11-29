
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

* Purpose: Cleaning IMSS datasets

*******************************************************************************/
*/

**************************		Panel - Firms		****************************
********************************************************************************

/*
use "$directorio/Data Private/panel_empresas.dta", clear
bysort idrp : gen u = uniform()<0.01 if _n==1
bysort idrp : egen kp = max(u)
keep if kp==1
drop u kp
save "$directorio/_aux/panel_empresas.dta", replace
*/
use "$directorio/_aux/panel_empresas.dta", clear
*use "$directorio/Data Private/panel_empresas.dta", clear
duplicates drop
rename cve_mun_final municipio
merge m:1 municipio using "Data Original\merge_ss_eneu_final.dta", keepusing(cvemun) keep(1 3) nogen
replace cvemun = 0000 if missing(cvemun)
drop municipio

*Date 
tostring periodo, replace
gen year = substr(periodo,1,4)
destring year, replace
gen quarter = ""
replace quarter = substr(periodo,5,1) if length(periodo)==7
replace quarter = substr(periodo,5,2) if length(periodo)==8
destring quarter, replace
replace quarter = quarter/3
gen date = yq(year, quarter)
format date %tq
drop periodo

gen date_initial_rfc = date(inirfc,"MDY")
format date_initial_rfc %td
drop inirfc
gen tenure_firm =  (dofq(date) - date_initial_rfc)/365


*Panel
sort idrp date
xtset idrp date

*Balance panel
gen sample1 = 1
tsfill
gen sample2 = 1
tsfill, full
gen sample3 = 1

*Imputations
replace year = yofd(dofq(date))
replace quarter = quarter(dofq(date))
*We are assuming that the idrp stay at the last seen municipality in IMSS data when drops out of IMSS data.
by idrp: replace cvemun = cvemun[_n-1] if missing(cvemun) & !missing(cvemun[_n-1])
by idrp: replace cve_ent_final = cve_ent_final[_n-1] if missing(cve_ent_final) & !missing(cve_ent_final[_n-1])


*Dependent variable
gen active = !missing(ta)
gen inactive = missing(ta)
gen labor_attachment = .

save "$directorio/Data Created/panel_empresas.dta", replace