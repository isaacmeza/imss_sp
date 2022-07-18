
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	June. 06, 2022
* Last date of modification: June. 15, 2022
* Modifications: Keep INEGI NO IMSS & NO SAT definitions of informality
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

*Time intervals
gen period = .
replace period = 1 if inrange(year,2000,2004)
replace period = 2 if inrange(year,2005,2010)
replace period = 3 if inrange(year,2010,2015)

***********************************
**** 		Regression		  *****
***********************************

iebaltab sex eda anios_esc t_tra [fw=fac], grpvar(period) save("$directorio\Tables\reg_results\meanvardeps_period.xlsx") vce(robust) replace nottest

capture erase "$directorio/Tables/reg_results/determinants_informal.xls"
capture erase "$directorio/Tables/reg_results/determinants_informal.txt"


forvalues p = 1/3 {
	reghdfe noimss i.sex eda anios_esc i.t_tra [fw = fac] if period==`p', absorb(i.municipio#i.date) vce(robust) 
	count if e(sample)==1
	local obs = `r(N)'
	su noimss [fw = fac] if e(sample) 	
	outreg2 using "$directorio/Tables/reg_results/determinants_informal.xls", addstat(Dep var mean, `r(mean)', Obs, `obs') addtext(Municipality $\times$ Date FE, "\checkmark") dec(2) pdec(3)
	
	reghdfe noimss i.sex eda anios_esc i.t_tra [fw = fac] if period==`p', absorb(i.scian i.municipio#i.date) vce(robust) 
	count if e(sample)==1
	local obs = `r(N)'
	su noimss [fw = fac] if e(sample) 	
	outreg2 using "$directorio/Tables/reg_results/determinants_informal.xls", addstat(Dep var mean, `r(mean)', Obs, `obs') addtext(Municipality $\times$ Date FE, "\checkmark", Occupation FE, "\checkmark") dec(2) pdec(3)	 
}


********************************************************************************


***********************************
****   Dynamic determinants   *****
***********************************

foreach var of varlist  eda anios_esc hrsocup log_ing  {
	su `var'
	replace `var' = (`var'-`r(mean)')/`r(sd)'
}


foreach infvar in noimss {
matrix coef = J(80,18,.)
local i = 1
forvalues dte = `=yq(2000,2)'/`=yq(2015,4)' {
	
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
gen qr = _n + yq(2000,2) - 1 if _n + yq(2000,2) -1 <= yq(2015,4)
save "$directorio\_aux\beta_characteristics_`infvar'.dta", replace
restore
}

drop if ene==1
foreach infvar in informal nosat {
matrix coef = J(61,18,.)
local i = 1
forvalues dte = `=yq(2005,1)'/`=yq(2015,4)' {
	
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
gen qr = _n + yq(2005,1) - 1 if _n + yq(2005,1) -1 <= yq(2015,4)
save "$directorio\_aux\beta_characteristics_`infvar'.dta", replace
restore
}

********************************************************************************

foreach infvar in noimss nosat informal {
	use "$directorio\_aux\beta_characteristics_`infvar'.dta", clear
	foreach var in sex eda anios_esc hrsocup log_ing t_tra {
		rename (`var'_beta `var'_hi `var'_lo) (`var'_`infvar'_beta `var'_`infvar'_hi `var'_`infvar'_lo)
	}
	save "$directorio\_aux\beta_characteristics_`infvar'.dta", replace
}

clear 
set obs 1
foreach infvar in noimss nosat informal {
	append using "$directorio\_aux\beta_characteristics_`infvar'.dta"
}
save "$directorio\_aux\beta_characteristics.dta", replace

********************************************************************************

use "$directorio\_aux\beta_characteristics.dta", clear

* Coefplot
foreach var in sex eda anios_esc hrsocup log_ing t_tra {
	twoway (lpolyci `var'_noimss_beta qr if qr<=`=yq(2004,4)', clcolor(maroon%75) fintensity(inten70)) ///
		(scatter `var'_noimss_beta qr if qr<=`=yq(2004,4)', connect(l) msymbol(Oh) msize(tiny) lcolor(navy%20) mcolor(navy%40)) ///
		(lpolyci `var'_noimss_beta qr if qr>`=yq(2004,4)', clcolor(maroon%75) fintensity(inten70)) ///
		(scatter `var'_noimss_beta qr if qr>`=yq(2004,4)', connect(l) msymbol(Oh) msize(tiny) lcolor(navy%20) mcolor(navy%40)) ///
		, legend(off) xlabel(160(15)223,format(%tq) labsize(small)) ytitle("Effect in informality : z-score") title("No IMSS") ///
		graphregion(color(white)) yline(0, lcolor(black%90)) xline(`=yq(2005,1)', lpattern(dash) lcolor(black%75)) name(noimss, replace)
	graph export "$directorio/Figuras/beta_`var'_noimss.pdf", replace
		
	twoway (lpolyci `var'_informal_beta qr if qr>`=yq(2004,4)', clcolor(maroon%75) fintensity(inten70)) ///
		(scatter `var'_informal_beta qr if qr>`=yq(2004,4)', connect(l) msymbol(Oh) msize(tiny) lcolor(navy%20) mcolor(navy%40)) ///
		, legend(off) xlabel(180(15)223,format(%tq) labsize(small)) title("Informality (INEGI)") ///
		graphregion(color(white)) yline(0, lcolor(black%90)) name(informal, replace)
	graph export "$directorio/Figuras/beta_`var'_informal.pdf", replace
		
	graph combine noimss informal , ycommon rows(1) 	
	graph export "$directorio/Figuras/beta_`var'.pdf", replace
}
