
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

* Purpose: Comparison of formal and informal worker's characteristics

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
gen byte noimss = !inlist(imssissste,1) if !inlist(imssissste,0,5,6) & !missing(imssissste)
gen byte noatencion_medica = !inlist(imssissste,1,2,3) if !inlist(imssissste,0,5,6) & !missing(imssissste)
gen byte nosat = (p4g!=3) if p4g!=9 & !missing(p4g)
gen byte informal_hussmann = (mh_fil2==1) if mh_fil2!=0 & !missing(mh_fil2)
replace informal_hussmann = (tue2==5) if tue2!=0 & ene==1



***********************************
**** 		Regression		  *****
***********************************

capture erase "$directorio/Tables/reg_results/characteristics_informal.xls"
capture erase "$directorio/Tables/reg_results/characteristics_informal.txt"

foreach var of varlist informal noimss noatencion_medica  {
	reghdfe `var' i.sex eda anios_esc hrsocup log_ing i.t_tra ibn.scian [fw = fac] if ene==1, absorb(i.municipio#i.date) vce(robust) 
	su `var' [fw = fac] if e(sample) 
	outreg2 using "$directorio/Tables/reg_results/characteristics_informal.xls", addstat(Dep var mean, `r(mean)') addtext(Municipality $\times$ Date FE, "\checkmark")
	
	reghdfe `var' i.sex eda anios_esc hrsocup log_ing i.t_tra ibn.scian [fw = fac] if ene==0, absorb(i.municipio#i.date) vce(robust) 
	su `var' [fw = fac] if e(sample) 
	outreg2 using "$directorio/Tables/reg_results/characteristics_informal.xls", addstat(Dep var mean, `r(mean)') addtext(Municipality $\times$ Date FE, "\checkmark")	
}
foreach var of varlist nosat  informal_hussmann {
	reghdfe `var' i.sex eda anios_esc hrsocup log_ing i.t_tra ibn.scian [fw = fac] if ene==0, absorb(i.municipio#i.date) vce(robust) 
	su `var' [fw = fac] if e(sample) 
	outreg2 using "$directorio/Tables/reg_results/characteristics_informal.xls", addstat(Dep var mean, `r(mean)') addtext(Municipality $\times$ Date FE, "\checkmark")
}


***********************************
****   Dynamic determinants   *****
***********************************
foreach infvar in informal noimss noatencion_medica {
matrix coef = J(80,18,.)
local i = 1
forvalues dte = `=yq(2000,2)'/`=yq(2020,1)' {
	
	di `dte'
	qui reghdfe `infvar' 2.sex eda anios_esc hrsocup log_ing 2.t_tra ibn.scian [fw = fac] if date==`dte', absorb(i.municipio) vce(robust) 
	matrix coef[`i',1] = _b[2.sex]
	matrix coef[`i',2] = _b[2.sex] + invnormal(0.975)*_se[2.sex]
	matrix coef[`i',3] = _b[2.sex] - invnormal(0.975)*_se[2.sex]
	
	local j = 4
	foreach var in eda anios_esc hrsocup log_ing {
		matrix coef[`i',`j'] = _b[`var']
		matrix coef[`i',`=`j'+1'] = _b[`var'] + invnormal(0.975)*_se[`var']
		matrix coef[`i',`=`j'+2'] = _b[`var'] - invnormal(0.975)*_se[`var']
		local j = `j' + 3
	}
	matrix coef[`i',`j'] = _b[2.t_tra]
	matrix coef[`i',`=`j'+1'] = _b[2.t_tra] + invnormal(0.975)*_se[2.t_tra]
	matrix coef[`i',`=`j'+2'] = _b[2.t_tra] - invnormal(0.975)*_se[2.t_tra]
	
	local i = `i' + 1
}

local nmes = ""
foreach var in sex eda anios_esc hrsocup log_ing t_tra {
	local nmes  `nmes' `var'_beta `var'_hi `var'_lo
}

matrix colnames coef = `nmes'
preserve
clear
svmat coef, names(col) 
gen qr = _n + yq(2000,2) - 1 if _n + yq(2000,2) -1 <= yq(2020,1)
save "$directorio\_aux\beta_characteristics_`infvar'.dta", replace

* Coefplot
foreach var in sex eda anios_esc hrsocup log_ing t_tra {
	twoway (lpolyci `var'_beta qr if qr<=`=yq(2004,4)', clcolor(maroon%50) fintensity(inten70)) ///
		(scatter `var'_beta qr if qr<=`=yq(2004,4)', connect(l) msymbol(Oh) msize(tiny) lcolor(navy%25)) ///
		(lpolyci `var'_beta qr if qr>`=yq(2004,4)', clcolor(maroon%50) fintensity(inten70)) ///
		(scatter `var'_beta qr if qr>`=yq(2004,4)', connect(l) msymbol(Oh) msize(tiny) lcolor(navy%25)) ///
		(rcap `var'_hi `var'_lo qr, msize(medlarge) color(navy)) ///
		, legend(off) xlabel(160(15)240,format(%tq) labsize(small)) ytitle("Effect in informality : {&beta}{subscript:i}") ///
		graphregion(color(white)) yline(0, lcolor(black%90)) xline(`=yq(2005,1)', lpattern(dash) lcolor(black%75))
	graph export "$directorio/Figuras/beta_`var'_`infvar'.pdf", replace
}
restore
}

drop if ene==1
foreach infvar in nosat informal_hussmann {
matrix coef = J(61,18,.)
local i = 1
forvalues dte = `=yq(2005,1)'/`=yq(2020,1)' {
	
	di `dte'
	qui reghdfe `infvar' 2.sex eda anios_esc hrsocup log_ing 2.t_tra ibn.scian [fw = fac] if date==`dte', absorb(i.municipio) vce(robust) 
	matrix coef[`i',1] = _b[2.sex]
	matrix coef[`i',2] = _b[2.sex] + invnormal(0.975)*_se[2.sex]
	matrix coef[`i',3] = _b[2.sex] - invnormal(0.975)*_se[2.sex]
	
	local j = 4
	foreach var in eda anios_esc hrsocup log_ing {
		matrix coef[`i',`j'] = _b[`var']
		matrix coef[`i',`=`j'+1'] = _b[`var'] + invnormal(0.975)*_se[`var']
		matrix coef[`i',`=`j'+2'] = _b[`var'] - invnormal(0.975)*_se[`var']
		local j = `j' + 3
	}
	matrix coef[`i',`j'] = _b[2.t_tra]
	matrix coef[`i',`=`j'+1'] = _b[2.t_tra] + invnormal(0.975)*_se[2.t_tra]
	matrix coef[`i',`=`j'+2'] = _b[2.t_tra] - invnormal(0.975)*_se[2.t_tra]
	
	local i = `i' + 1
}

local nmes = ""
foreach var in sex eda anios_esc hrsocup log_ing t_tra {
	local nmes  `nmes' `var'_beta `var'_hi `var'_lo
}

matrix colnames coef = `nmes'
preserve
clear
svmat coef, names(col) 
gen qr = _n + yq(2005,1) - 1 if _n + yq(2005,1) -1 <= yq(2020,1)
save "$directorio\_aux\beta_characteristics_`infvar'.dta", replace

* Coefplot
foreach var in sex eda anios_esc hrsocup log_ing t_tra {
	twoway (lpolyci `var'_beta qr if qr>`=yq(2004,4)', clcolor(maroon%50) fintensity(inten70)) ///
		(scatter `var'_beta qr if qr>`=yq(2004,4)', connect(l) msymbol(Oh) msize(tiny) lcolor(navy%25)) ///
		(rcap `var'_hi `var'_lo qr, msize(medlarge) color(navy)) ///
		, legend(off) xlabel(180(15)240,format(%tq) labsize(small)) ytitle("Effect in informality : {&beta}{subscript:i}") ///
		graphregion(color(white)) yline(0, lcolor(black%90)) xline(`=yq(2005,1)', lpattern(dash) lcolor(black%75))
	graph export "$directorio/Figuras/beta_`var'_`infvar'.pdf", replace
}
restore
}

