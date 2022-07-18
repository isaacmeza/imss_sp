
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
replace class_trab = (tue2==5) if tue2!=0 & ene==1
replace class_trab = 2 if missing(class_trab) & clase1==1


***********************************
**** 	      Graphs		  *****
***********************************

replace informal = (class_trab==1) if !missing(class_trab)
gen formal = (class_trab==0) if !missing(class_trab)

collapse (mean) formal informal noimss nosat [fw=fac], by(date)

gen formal_m = informal + formal
gen zero = 0
gen uno = 1

twoway (rarea informal zero date if date>=`=yq(2005,1)', color(navy%20)) ///
	(rarea formal_m informal date if date>=`=yq(2005,1)', color(maroon%20)) ///
	(rarea uno formal_m date, color(dkgreen%20)) ///
	(line noimss date, lwidth(medthick) lcolor(blue)) ///
	(line nosat date, lwidth(medthick) lcolor(black)) ///
	, legend(order(1 "Informal" 2 "Formal" 3 "Unemployed" 4 "No IMSS" 5 "No SAT") size(small) rows(2) pos(6)) graphregion(color(white)) ///
	xtitle("") xlabel(160(15)223,format(%tq) labsize(small)) xline(`=yq(2005,1)', lpattern(dash) lcolor(black%75))
graph export "$directorio/Figuras/informal_time.pdf", replace	


