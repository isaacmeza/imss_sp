
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	July. 04, 2022
* Last date of modification: 
* Modifications: IV-LASSO and XTIVREG
* Files used:     
		- 
* Files created:  

* Purpose: Instrumental variable estimation for SP and employment
*******************************************************************************/
*/


use  "Data Created\DiD_DB.dta", clear	
merge 1:1 cvemun date using "Data Created\clues.dta", keep(1 3) nogen

gen log_ind = log(ind+1)
gen clave_institucion = clave_institucion_1 + clave_institucion_2 
foreach var of varlist clave_institucion clave_institucion_1  clave_institucion_2  clave_institucion_3 clave_institucion_4 clave_institucion_5 tipo_establecimiento_1 tipo_establecimiento_2 tipo_establecimiento_3 tipo_establecimiento_4 nivel_atencion_1 nivel_atencion_2 nivel_atencion_3 nivel_atencion_4 totaldeconsultorios totaldecamas total_clues {
	replace `var' = 0 if missing(`var')
	replace `var' = log(`var'+1)
}

tab ent, gen(dummy_ent)
drop dummy_ent32
tab government, gen(dummy_gov)

********************************************************************************

*Instruments
vl create instruments_c = (total_clues clave_institucion nivel_atencion_3 nivel_atencion_4 totaldeconsultorios totaldecamas)
vl create instruments = (dummy_gov1 dummy_gov2)


*Pre-time trends
gen trend_e9 = e9 - L.e9

eststo clear
eststo : reg trend_e9 $instruments_c $instruments lgpop median_lum if inrange(date,yq(2000,1),yq(2004,4)), r
estadd scalar Fstat = `e(F)'
eststo : reg trend_e9 $instruments_c $instruments lgpop median_lum x_t_* if inrange(date,yq(2000,1),yq(2004,4)), r
estadd scalar Fstat = `e(F)'
qui cvlasso trend_e9 $instruments $instruments_c if inrange(date,yq(2000,1),yq(2004,4))
qui lasso2 trend_e9 $instruments $instruments_c if inrange(date,yq(2000,1),yq(2004,4)), l(`lopt') adaptive
eststo : reg trend_e9 `e(selected)' median_lum lgpop if inrange(date,yq(2000,1),yq(2004,4)), r
estadd scalar Fstat = `e(F)'

eststo : reghdfe trend_e9 $instruments_c $instruments lgpop median_lum if inrange(date,yq(2000,1),yq(2004,4)), absorb(cvemun) vce(robust) 
estadd scalar Fstat = `e(F)'
eststo : reghdfe trend_e9 $instruments_c $instruments lgpop median_lum x_t_* if inrange(date,yq(2000,1),yq(2004,4)), absorb(cvemun) vce(robust) 
estadd scalar Fstat = `e(F)'
qui cvlasso trend_e9 $instruments $instruments_c if inrange(date,yq(2000,1),yq(2004,4)), fe
qui lasso2 trend_e9 $instruments $instruments_c if inrange(date,yq(2000,1),yq(2004,4)), l(`lopt') fe 
eststo : reghdfe trend_e9 `e(selected)' median_lum lgpop if inrange(date,yq(2000,1),yq(2004,4)), absorb(cvemun) vce(robust)
estadd scalar Fstat = `e(F)'
			  
			  
esttab using "$directorio/Tables/reg_results/pretime_trends_instrument.csv", se r2 ${star} b(a2)  replace keep($instruments_c $instruments lgpop median_lum) scalars("Fstat Fstat")		
	  

*Panel IV
eststo clear

eststo : xtivreg e9 median_lum lgpop x_t_* (log_ind = $instruments_c $instruments) if inrange(date,yq(2005,1),yq(2008,4)), fe vce(cluster cvemun) first
cap drop esample 
gen esample = (e(sample)==1)
su e9 if esample==1
estadd scalar DepVarMean = `r(mean)'

eststo : xtreg log_ind $instruments_c $instruments median_lum lgpop x_t_* if esample==1 & inrange(date,yq(2005,1),yq(2008,4)), fe vce(cluster cvemun) 
local fstat = `e(F)'
su log_ind if e(sample)==1
estadd scalar DepVarMean = `r(mean)'
estadd scalar Fstat = `fstat'

esttab using "$directorio/Tables/reg_results/paneliv_sp.csv", se r2 ${star} b(a2)  replace scalars("DepVarMean DepVarMean" "Fstat Fstat")		
	 

********************************************************************************
matrix coef = J(16,4,.)
matrix iv = J(16,4,.)

local j = 1
forvalues year = 2005/2008 {
	forvalues quarter = 1/4 {	
		
		di "`year'" "`quarter'"
		
		*Definitions of treatment 
		cap drop treat_b
		cap drop treat
			*Continuous treatment
		qui gen treat = log(ind+1) if date==yq(`year',`quarter') 
			*Binary treatment
		qui gen treat_b = (SP_b_p>=0) if date==yq(`year',`quarter')
		
		*Proportion of treated
		su treat_b
		mat iv[`j',4] = `r(mean)'
		mat iv_b[`j',4] = `r(mean)'

		*Instrument selection
		qui lasso linear treat (dummy_ent*) median_lum lgpop x_t_* $instruments $instruments_c 	  
		cap vl drop controls
		cap vl drop inst
		vl create controls = (`e(allvars_sel)')
		vl modify controls = controls - ($instruments $instruments_c)
		vl create inst = (`e(allvars_sel)')
		vl modify inst = inst - (dummy_ent* median_lum lgpop x_t_*)

		*IV
		ivreg2 e9 $controls (treat = $inst), robust
		cap drop esample_c
		gen esample_c = (e(sample)==1)
		
		cap mat iv[`j',1] = _b[treat]
		cap mat iv[`j',2] = _b[treat] + invnormal(0.975)*_se[treat]
		cap mat iv[`j',3] = _b[treat] - invnormal(0.975)*_se[treat]
					
		*First stage		
		cap reg treat $inst $controls if esample_c==1, robust
		local k = 1
		foreach var of varlist total_clues {
			cap mat coef[`j',`k'] = _b[`var']
			cap mat coef[`j',`=`k'+1'] = _b[`var'] + invnormal(0.975)*_se[`var']
			cap mat coef[`j',`=`k'+2'] = _b[`var'] - invnormal(0.975)*_se[`var']
			cap mat coef[`j',`=`k'+3'] = e(F)
			local k = `k' + 3
		}

		local j = `j' + 1
	}
}



********************************************************************************
********************************************************************************

* Plot estimates over time

svmat coef
svmat iv


cap drop n
gen n = yq(2005,1) + _n -1 if _n<=16
format n %tq

*First stage
twoway (rarea coef2 coef3 n, color(blue%25)) (scatter coef1 n, color(black) connect(line)) ///
 (scatter coef4 n , color(maroon) connect(line) yaxis(2)) ///
	, legend(order(2 "log(# clinics)" 3 "F-stat") rows(1) pos(6)) name(first_c, replace) yline(0) ytitle("First stage", axis(1)) ytitle("F-stat", axis(2)) xtitle("") 

*Second stage	
twoway (rarea iv2 iv3 n, color(blue%25)) (scatter iv1 n, color(black) connect(line)) ///
(scatter iv4 n , color(maroon) connect(line) yaxis(2)) ///
	, legend(order(2 "SP" 3 "Share treated") rows(1) pos(6)) name(second_c, replace) yline(0) ytitle("Elasticity", axis(1)) ytitle("Share of treated", axis(2)) xtitle("")

graph combine first_c second_c, xcommon cols(1)
graph export "$directorio/Figuras/IV_SP_c.pdf", replace
