
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

* Purpose: SS Table in determinants of informal/formal workers

*******************************************************************************/
*/
/*
use "$directorio\Data Created\sdemt_enoe.dta", clear
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

*Informal 
gen byte informal = (emp_ppal==1) if emp_ppal!=0 & !missing(emp_ppal)
gen byte noimss = !inlist(imssissste,1) if !inlist(imssissste,0,5,6) & !missing(imssissste)
gen byte nosat = (p4g!=3) if p4g!=9 & !missing(p4g)

*Formal/Informal/Desocupado
gen byte class_trab = informal
replace class_trab = 2 if missing(class_trab) & clase1==1



***********************************
**** 			SS	  		  *****
***********************************

gen time = .
replace time = 1 if inrange(year,2005,2010)
replace time = 2 if inrange(year,2011,2015)

iebaltab informal noimss nosat [fw=fac], grpvar(time) save("$directorio\Tables\reg_results\ss_shareinf.xlsx") total vce(robust)  pttest replace 

qui putexcel set "$directorio\Tables\reg_results\ss_shareinf.xlsx", sheet("Sheet1") modify	

local k = 5
foreach var in informal noimss nosat {
	forvalues i=1/2 {
		local Col = substr(c(ALPHA),`=-1+`i'*4',1)
		su `var' if time==`i'
		qui putexcel `Col'`k'=`r(N)'
	}
	local k = `k' + 2
}


***********************************
**** 		  CATPLOT	  	  *****
***********************************

graph hbar (mean) noimss if scian!=0, over(scian) ytitle("No IMSS %")
graph export "$directorio/Figuras/catplot_scian_enoe.pdf", replace	


***********************************
**** 			Corr  		  *****
***********************************

corr informal noimss nosat  [fw=fac] 
qui putexcel set "$directorio\Tables\corr_informal.xlsx", sheet("corr_informal") modify	
qui putexcel B6=matrix(r(C))  

collapse (mean) informal noimss nosat [fw=fac], by(year ent mun)

corr informal noimss nosat if year>2004
qui putexcel set "$directorio\Tables\corr_informal.xlsx", sheet("corr_informal_mun") modify	
qui putexcel B6=matrix(r(C))  