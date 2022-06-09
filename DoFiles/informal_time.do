
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

* Purpose: 

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
**** 	      Graphs		  *****
***********************************

replace informal = (class_trab==1) if !missing(class_trab)
gen formal = (class_trab==0) if !missing(class_trab)

collapse (mean) formal informal noimss noatencion_medica nosat informal_hussmann [fw=fac], by(date)

gen formal_m = informal + formal
gen zero = 0
gen uno = 1

twoway (rarea informal zero date, color(navy%20)) ///
	(rarea formal_m informal date, color(maroon%20)) ///
	(rarea uno formal_m date, color(dkgreen%20)) ///
	(line noimss date, lwidth(medthick) lcolor(blue)) ///
	(line noatencion_medica date, lwidth(medthick) lcolor(red)) ///
	(line nosat date, lwidth(medthick) lcolor(black)) ///
	(line informal_hussmann date, lwidth(medthick) lcolor(purple)) ///
	, legend(order(1 "Informal" 2 "Formal" 3 "Unemployed" 4 "No IMSS" 5 "No social security" 6 "No SAT" 7 "Informal Husmann") size(small) rows(2) pos(6)) graphregion(color(white)) ///
	xtitle("") xlabel(160(15)240,format(%tq) labsize(small)) xline(`=yq(2005,1)', lpattern(dash) lcolor(black%75))
graph export "$directorio/Figuras/informal_time.pdf", replace	


