use "$directorio\Data Created\sdemt_enoe.dta", clear
merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren year quarter using "$directorio\Data Created\coe1t_enoe.dta", nogen

*Municipality
egen int municipio = group(ent mun)

*Time
gen int date = yq(year, quarter)
format date %tq

*Covariates
gen log_ing = log(ing_x_hrs+1)
*Informal
gen byte informal = (emp_ppal==1) if emp_ppal!=0 & !missing(emp_ppal)
gen byte imss = inlist(imssissste,1) if imssissste!=0 & imssissste!=5 & !missing(imssissste)
gen byte atencion_medica = inlist(imssissste,1,2,3) if imssissste!=0 & imssissste!=5 & !missing(imssissste)
gen byte sat = (p4g==3) if p4g!=9 & !missing(p4g)
gen byte informal_unidad = (tue_ppal==1) if tue_ppal!=0 & !missing(tue_ppal)
gen byte informal_hausman = (mh_fil2==1) if mh_fil2!=0 & !missing(mh_fil2)


***********************************
**** 		Regression		  *****
***********************************

capture erase "$directorio/Tables/reg_results/characteristics_informal.xls"
capture erase "$directorio/Tables/reg_results/characteristics_informal.txt"

foreach var of varlist informal imss atencion_medica sat informal_unidad informal_hausman {
	reghdfe `var' i.sex eda anios_esc hrsocup log_ing i.t_tra ibn.scian [fw = fac], absorb(i.municipio#i.date) vce(robust) 
	su `var' [fw = fac] if e(sample) 
	outreg2 using "$directorio/Tables/reg_results/characteristics_informal.xls", addstat(Dep var mean, `r(mean)') addtext(Municipality FE, "\checkmark")
}


***********************************
****   Dynamic determinants   *****
***********************************
matrix coef = J(61,18,.)
local i = 1
forvalues dte = `=yq(2005,1)'/`=yq(2020,1)' {
	
	di `dte'
	qui reghdfe informal 2.sex eda anios_esc hrsocup log_ing 2.t_tra ibn.scian [fw = fac] if date==`dte', absorb(i.municipio#i.date) vce(robust) 
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
svmat coef, names(col) clear
gen qr = _n + yq(2005,1) - 1 if _n + yq(2005,1) -1 <= yq(2020,1)

* Coefplot
foreach var in sex /*eda anios_esc hrsocup log_ing t_tra*/ {
	twoway (lpolyci sex_beta qr, clcolor(maroon%50) fintensity(inten70)) ///
		(scatter sex_beta qr, connect(l) msymbol(Oh) msize(tiny) lcolor(navy%25)) ///
		(rcap sex_hi sex_lo qr, msize(medlarge) color(navy)) ///
		, legend(off) xlabel(180(12)240,format(%tq) labsize(small)) ytitle("Effect in informality : {&beta}{subscript:i}") ///
		graphregion(color(white)) yline(0, lcolor(black%90))
		
}
