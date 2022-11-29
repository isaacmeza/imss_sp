
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	June. 06, 2022
* Last date of modification: Aug. 1, 2022
* Modifications: Remove ENE
* Files used:     
		- 
* Files created:  

* Purpose: Industrial concentration of informality

*******************************************************************************/
*/

use "$directorio\Data Created\sdemt_enoe.dta", clear
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren year quarter using "$directorio\Data Created\coe1t_enoe.dta", nogen


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

*Formal/Informal/Desocupado
gen byte class_trab = informal
replace class_trab = 2 if missing(class_trab) & clase1==1



***********************************
**** 		  CATPLOT	  	  *****
***********************************

graph hbar (mean) noimss if scian!=0, over(scian, sort(1) descending) ytitle("No IMSS %")
graph export "$directorio/Figuras/catplot_scian_enoe.pdf", replace	

