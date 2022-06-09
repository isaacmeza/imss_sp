use "$directorio\Data Created\sdemt_enoe.dta", clear

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

keep informal noimss noatencion_medica nosat informal_hussmann sex eda anios_esc hrsocup log_ing t_tra date municipio scian
compress
save "$directorio\_aux\reg.dta", replace

/*
*Runned in EC2
use "$directorio\_aux\reg.dta", clear
reghdfe informal 2.sex#i.date c.eda#i.date c.anios_esc#i.date c.hrsocup#i.date c.log_ing#i.date 2.t_tra#i.date [fw = fac], absorb(i.municipio#i.date i.scian) vce(robust) 

mat coeff = e(b)'
clear 
svmat coeff
mat se = J(367,1,.)
forvalues i = 1/367 {
	mat se[`i',1] = e(V)[`i',`i'] 
}
svmat se
rename (coeff1 se1) (coeff se)
save "$directorio\_aux\coeff_informal.dta", replace
*/

********************************************************************************

use "$directorio\_aux\coeff_informal.dta", replace
gen k = _n
drop if _n==_N
gen j = ceil(_n/61) 

sort j k
by j : gen qr = _n
drop k

reshape wide coeff se, i(qr) j(j)

rename (coeff1 coeff2 coeff3 coeff4 coeff5 coeff6) (sex_beta eda_beta anios_esc_beta hrsocup_beta log_ing_beta t_tra_beta)

rename (se1 se2 se3 se4 se5 se6) (sex_se eda_se anios_esc_se hrsocup_se log_ing_se t_tra_se)


replace qr = qr + 179

* Coefplot
foreach var in sex eda anios_esc hrsocup log_ing t_tra {
	
	gen `var'_hi = `var'_beta + invnormal(0.975)*`var'_se
	gen `var'_lo = `var'_beta - invnormal(0.975)*`var'_se
	
	twoway (lpolyci `var'_beta qr if qr>`=yq(2004,4)', clcolor(maroon%50) fintensity(inten70)) ///
		(scatter `var'_beta qr if qr>`=yq(2004,4)', connect(l) msymbol(Oh) msize(tiny) lcolor(navy%25)) ///
		(rcap `var'_hi `var'_lo qr, msize(medlarge) color(navy)) ///
		, legend(off) xlabel(180(12)240,format(%tq) labsize(small)) ytitle("Effect in informality : {&beta}{subscript:i}") ///
		graphregion(color(white)) yline(0, lcolor(black%90)) xline(`=yq(2005,1)', lpattern(dash) lcolor(black%75))
	graph export "$directorio/Figuras/beta_`var'_informal_int.pdf", replace
}

