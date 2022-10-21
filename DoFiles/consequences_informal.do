
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation: June. 26, 2022
* Last date of modification: Oct. 18, 2022
* Modifications: Remove ENE
	- Change of specification
* Files used:     
		- 
* Files created:  

* Purpose: We estimate the difference in wage between IMSS and no-IMSS 

*******************************************************************************/
*/

/*
use "$directorio\Data Created\sdemt_enoe.dta", clear
merge m:1 year quarter ent mun using  "$directorio\Data Created\luminosity.dta", keep(1 3)
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren year quarter using "$directorio\Data Created\coe1t_enoe.dta", nogen
*/
use "$directorio\_aux\master.dta", clear

label copy scian new_scian, replace
label define new_scian 23 "Agriculture & Livestock" 24 "Mining" 25 "Manufacturing" 26 "Construction" 27 "Utilities" 28 "Retail, restaurants & hotels" 29 "Transportation, Storage & communication" 30 "Financial services" 31 "Personal & social services" 32 "Insufficiently specified", add
label values scian new_scian

*Municipality
egen int municipio = group(ent mun)

*Time
gen int date = yq(year, quarter)
format date %tq

*Covariates
gen log_ing = log(ing_x_hrs+1)
gen casado = inlist(e_con,1,5) if !missing(e_con)

*Informal 
gen byte informal = (emp_ppal==1) if emp_ppal!=0 & !missing(emp_ppal)
gen byte noimss = !inlist(imssissste,1) if !inlist(imssissste,0,5,6) & !missing(imssissste)
gen byte nosat = (p4g!=3) if p4g!=9 & !missing(p4g)

*Time intervals
gen period = .
replace period = 1 if inrange(year,2000,2004)
replace period = 2 if inrange(year,2005,2010)
replace period = 3 if inrange(year,2010,2015)

*ID
egen id_ = group(cd_a ent con v_sel n_hog h_mud n_ren)
sort id_ date
by id_ : gen id_1 = (n_ent[_n]!=n_ent[_n-1]+1 | date[_n]!=date[_n-1]+1) 
by id_ : gen id_aux = sum(id_1)
egen id = group(id_ id_aux)

***********************************
**** 		Regression		  *****
***********************************

capture erase "$directorio/Tables/reg_results/consequences_informal.xls"
capture erase "$directorio/Tables/reg_results/consequences_informal.txt"
	
	reghdfe log_ing noimss median_lum i.sex eda anios_esc casado i.scian [fw = fac] , absorb(i.municipio#i.date id) vce(robust) 
	count if e(sample)==1
	local obs = `r(N)'
	su log_ing [fw = fac] if e(sample) 	
	outreg2 using "$directorio/Tables/reg_results/consequences_informal.xls", addstat(Dep var mean, `r(mean)', Obs, `obs') addtext(Municipality $\times$ Date FE, "\checkmark", Occupation FE, "\checkmark", Individual FE, "\checkmark") dec(2) pdec(3)		
	

********************************************************************************

