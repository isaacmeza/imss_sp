
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	June. 06, 2022
* Last date of modification: Oct. 10, 2022
* Modifications: Keep INEGI NO IMSS & NO SAT definitions of informality
	Remove ENE
	- Collapse dynamic determinants to a single coefficient
* Files used:     
		- 
* Files created:  

* Purpose: Comparison of formal and informal worker's characteristics

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

***********************************
**** 		Regression		  *****
***********************************

iebaltab sex eda anios_esc t_tra casado [fw=fac], grpvar(period) save("$directorio\Tables\reg_results\meanvardeps_period.xlsx") vce(robust) replace nottest

capture erase "$directorio/Tables/reg_results/determinants_informal.xls"
capture erase "$directorio/Tables/reg_results/determinants_informal.txt"


forvalues p = 2/3 {
	reghdfe noimss i.sex eda anios_esc i.t_tra casado [fw = fac] if period==`p', absorb(i.municipio#i.date) vce(robust) 
	count if e(sample)==1
	local obs = `r(N)'
	su noimss [fw = fac] if e(sample) 	
	outreg2 using "$directorio/Tables/reg_results/determinants_informal.xls", addstat(Dep var mean, `r(mean)', Obs, `obs') addtext(Municipality $\times$ Date FE, "\checkmark") dec(2) pdec(3)
	
	reghdfe noimss i.sex eda anios_esc i.t_tra casado [fw = fac] if period==`p', absorb(i.scian i.municipio#i.date) vce(robust) 
	count if e(sample)==1
	local obs = `r(N)'
	su noimss [fw = fac] if e(sample) 	
	outreg2 using "$directorio/Tables/reg_results/determinants_informal.xls", addstat(Dep var mean, `r(mean)', Obs, `obs') addtext(Municipality $\times$ Date FE, "\checkmark", Occupation FE, "\checkmark") dec(2) pdec(3)	 
}


********************************************************************************


***********************************
****   		Determinants   	  *****
***********************************

foreach var of varlist  eda anios_esc hrsocup log_ing  {
	su `var'
	replace `var' = (`var'-`r(mean)')/`r(sd)'
}


matrix coef = J(5,3,.)
matrix coef_scian = J(5,3,.)

reghdfe noimss 2.sex eda anios_esc hrsocup log_ing 2.t_tra casado [fw = fac] if inlist(period,2,3), absorb(i.municipio) vce(robust) 
	local j = 1
foreach var of varlist sex {
	matrix coef[`j',1] = _b[2.`var']
	matrix coef[`j',2] = _b[2.`var'] - invnormal(.975)*_se[2.`var']
	matrix coef[`j',3] = _b[2.`var'] + invnormal(.975)*_se[2.`var'] 
	local j = `j' + 1
}
foreach var of varlist casado eda anios_esc hrsocup {
	matrix coef[`j',1] = _b[`var']
	matrix coef[`j',2] = _b[`var'] - invnormal(.975)*_se[`var']
	matrix coef[`j',3] = _b[`var'] + invnormal(.975)*_se[`var'] 
	local j = `j' + 1
}

reghdfe noimss 2.sex eda anios_esc hrsocup log_ing 2.t_tra casado ibn.scian [fw = fac] if inlist(period,2,3), absorb(i.municipio) vce(robust) 
	local j = 1
foreach var of varlist sex {
	matrix coef_scian[`j',1] = _b[2.`var']
	matrix coef_scian[`j',2] = _b[2.`var'] - invnormal(.975)*_se[2.`var']
	matrix coef_scian[`j',3] = _b[2.`var'] + invnormal(.975)*_se[2.`var'] 
	local j = `j' + 1
}
foreach var of varlist casado eda anios_esc hrsocup {
	matrix coef_scian[`j',1] = _b[`var']
	matrix coef_scian[`j',2] = _b[`var'] - invnormal(.975)*_se[`var']
	matrix coef_scian[`j',3] = _b[`var'] + invnormal(.975)*_se[`var'] 
	local j = `j' + 1
}


mat rownames coef =  "Woman"  "Married" "Age" "Schooling" "Weekly hours"  
mat rownames coef_scian =  "Woman"  "Married" "Age" "Schooling" "Weekly hours"  
	
	coefplot (matrix(coef[,1]), offset(0.06) ci((coef[,2] coef[,3])) msize(large) ciopts(lcolor(gs4))) ///
	(matrix(coef_scian[,1]), offset(-0.06) ci((coef_scian[,2] coef_scian[,3])) msize(large) ciopts(lcolor(gs4))) , ///
	legend(order(2 "Municipality FE" 4 "Municipality + Occupation FE") pos(6) rows(1))  xline(0)  graphregion(color(white)) 
graph export "$directorio/Figuras/beta_characteristics_noimss.pdf", replace
	
	