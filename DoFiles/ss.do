
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: June. 06, 2022
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: SS Table in determinants of informal/formal workers

*******************************************************************************/
*/
/*
use "$directorio\Data Created\sdemt_enoe.dta", clear
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren year quarter using "$directorio\Data Created\coe1t_enoe.dta", nogen
append using "$directorio\Data Created\ene.dta", gen(ene)
*/
use "$directorio\_aux\master.dta", clear

label copy scian new_scian, replace
label define new_scian 23 "Agropecuario" 24 "Mineria" 25 "Industria Manufacturera" 26 "Construccion" 27 "Electricidad, Gas y Agua" 28 "Comercio, Restaurantes y Hoteles" 29 "Transporte Almacenamiento y Comunicaciones" 30 "Servicios Financieros" 31 "Servicios Comunales, Sociales y Personales" 32 "Insuficientemente Especificado", add
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
replace informal = (tue2==5) if tue2!=0 & ene==1
gen byte noimss = !inlist(imssissste,1) if !inlist(imssissste,0,5,6) & !missing(imssissste)
gen byte noatencion_medica = !inlist(imssissste,1,2,3) if !inlist(imssissste,0,5,6) & !missing(imssissste)
gen byte nosat = (p4g!=3) if p4g!=9 & !missing(p4g)
gen byte informal_hussmann = (mh_fil2==1) if mh_fil2!=0 & !missing(mh_fil2)

*Formal/Informal/Desocupado
gen byte class_trab = informal
replace class_trab = 2 if missing(informal) & clase1==1

***********************************
**** 			SS	  		  *****
***********************************

tab scian, gen (scian_dummy)
gen mujer = (sex==2) if !missing(sex)
gen dos_t = (t_tra==2) if !missing(t_tra) & t_tra!=0

iebaltab noimss noatencion_medica mujer eda anios_esc hrsocup log_ing dos_t scian_dummy* if ene==1 [fw=fac], grpvar(class_trab) save("$directorio\Tables\reg_results\ss_ene.xlsx") total vce(robust)  pttest replace 

iebaltab  noimss noatencion_medica nosat informal_hussmann mujer eda anios_esc hrsocup log_ing dos_t scian_dummy* if ene==0 [fw=fac], grpvar(class_trab) save("$directorio\Tables\reg_results\ss_enoe.xlsx") total vce(robust)  pttest replace balmiss(zero)


***********************************
**** 		  CATPLOT	  	  *****
***********************************

graph hbar (mean) informal if scian!=0 & ene==1, over(scian) ytitle("Informal %")
graph export "$directorio/Figuras/catplot_scian_ene.pdf", replace	

graph hbar (mean) informal if scian!=0 & ene==0, over(scian) ytitle("Informal %")
graph export "$directorio/Figuras/catplot_scian_enoe.pdf", replace	


***********************************
**** 			Corr  		  *****
***********************************

corr informal noimss noatencion_medica [fw=fac]  if ene==1
qui putexcel set "$directorio\Tables\corr_informal.xlsx", sheet("corr_informal") modify	
qui putexcel B2=matrix(r(C))  

corr informal noimss noatencion_medica nosat informal_hussmann [fw=fac] if ene==0
qui putexcel B6=matrix(r(C))  


collapse (mean) informal noimss noatencion_medica nosat informal_hussmann [fw=fac], by(year ent mun)

corr informal noimss noatencion_medica if year<=2004
qui putexcel set "$directorio\Tables\corr_informal.xlsx", sheet("corr_informal_mun") modify	
qui putexcel B2=matrix(r(C))  

corr informal noimss noatencion_medica nosat informal_hussmann if year>2004
qui putexcel B6=matrix(r(C))  