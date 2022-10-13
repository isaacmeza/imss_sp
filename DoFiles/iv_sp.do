
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	July. 04, 2022
* Last date of modification: July. 28, 2022
* Modifications: IV-LASSO and XTIVREG, Added ASG Dep vars
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

gen date1 = date
gen date2 = date*date
gen date3 = date2*date

gen median_lum2 = median_lum*median_lum
gen median_lum3 = median_lum2*median_lum
********************************************************************************

*Instruments
vl create instruments_c = (total_clues clave_institucion nivel_atencion_3 nivel_atencion_4 totaldeconsultorios totaldecamas)
vl create instruments = (dummy_gov1 dummy_gov2)


eststo clear
foreach var in p_t_ e_t_  /// imss consolidated
		 lg1_masa_sal_ta /// asg
		  {
	*Pre-time trends
	gen trend_`var' = `var' - L.`var'

	eststo : reg trend_`var' $instruments_c $instruments lgpop median_lum* sexo  x_t_* i.date if inrange(date,yq(2000,1),yq(2003,4)) & bal_48==1, vce(cluster cvemun)
	cap test $instruments_c $instruments 
	estadd scalar Fstat = `e(F)'
	estadd scalar pval = `r(p)'
	
	eststo : reghdfe trend_`var' $instruments_c $instruments lgpop median_lum* sexo  x_t_* i.date if inrange(date,yq(2000,1),yq(2003,4)) & bal_48==1, absorb(cvemun) vce(cluster cvemun) 
	cap test $instruments_c $instruments 
	estadd scalar Fstat = `e(F)'
	estadd scalar pval = `r(p)'	
	
	qui cvlasso trend_`var' $instruments $instruments_c if inrange(date,yq(2000,1),yq(2003,4)) & bal_48==1, fe
	qui lasso2 trend_`var' $instruments $instruments_c if inrange(date,yq(2000,1),yq(2003,4)) & bal_48==1, l(`lopt') fe 
	eststo : reghdfe trend_`var' `e(selected)' lgpop median_lum* sexo x_t_* i.date if inrange(date,yq(2000,1),yq(2003,4)) & bal_48==1, absorb(cvemun) vce(cluster cvemun)
	cap test `e(selected)' 
	estadd scalar Fstat = `e(F)'
	cap estadd scalar pval = `r(p)'	
}
	
esttab using "$directorio/Tables/reg_results/pretime_trends_instrument_1q.csv", se r2 ${star} b(a2)  replace keep($instruments_c $instruments lgpop median_lum* sexo ) scalars("Fstat Fstat" "pval pval")	
	
	
eststo clear
foreach var in  p_t_ e_t_  /// imss consolidated
		 lg1_masa_sal_ta /// asg
		  {
	*Pre-time trends	
	gen trend4_`var' = `var' - L4.`var'
		
	eststo : reg trend4_`var' $instruments_c $instruments lgpop median_lum* sexo  x_t_* i.date if inrange(date,yq(2000,1),yq(2003,4)) & bal_48==1, vce(cluster cvemun)
	cap test $instruments_c $instruments 
	estadd scalar Fstat = `e(F)'
	estadd scalar pval = `r(p)'
	
	eststo : reghdfe trend4_`var' $instruments_c $instruments lgpop median_lum* sexo  x_t_* i.date if inrange(date,yq(2000,1),yq(2003,4)) & bal_48==1, absorb(cvemun) vce(cluster cvemun)
	cap test $instruments_c $instruments 
	estadd scalar Fstat = `e(F)'
	estadd scalar pval = `r(p)'
	
	qui cvlasso trend4_`var' $instruments $instruments_c if inrange(date,yq(2000,1),yq(2003,4)) & bal_48==1, fe
	qui lasso2 trend4_`var' $instruments $instruments_c if inrange(date,yq(2000,1),yq(2003,4)) & bal_48==1, l(`lopt') fe 
	eststo : reghdfe trend4_`var' `e(selected)' lgpop median_lum* sexo x_t_* i.date if inrange(date,yq(2000,1),yq(2003,4)) & bal_48==1, absorb(cvemun) vce(cluster cvemun)
	cap test `e(selected)' 
	estadd scalar Fstat = `e(F)'	
	cap estadd scalar pval = `r(p)'
}
	
esttab using "$directorio/Tables/reg_results/pretime_trends_instrument_4q.csv", se r2 ${star} b(a2)  replace keep($instruments_c $instruments lgpop median_lum* sexo ) scalars("Fstat Fstat" "pval pval")	

	  

*Panel IV

eststo clear
foreach var of varlist p_t_ p_1_ e_t_ {
	eststo : xi : xtivreg2 `var' lgpop median_lum* sexo  x_t_* i.date1 (log_ind = $instruments_c $instruments) [aw=pob2000] if inrange(date,yq(2004,1),yq(2009,4)) & bal_48_imss==1, fe cluster(cvemun) 
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su `var' if (e(sample)==1)
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'		
}

esttab using "$directorio/Tables/reg_results/paneliv_sp.csv", se r2 ${star} b(a2)  replace keep(log_ind lgpop median_lum* sexo ) scalars("DepVarMean DepVarMean" "num_mun num_mun")		
	 

********************************************************************************

* FIRST STAGE	
matrix coef = J(16,4,.)

local j = 1
forvalues year = 2005/2008 {
	forvalues quarter = 1/4 {	
			
		di "`year'" "`quarter'"
			
		*Definitions of treatment 
		cap drop treat_b
		cap drop treat
				*Continuous treatment
		qui gen treat = log(ind+1) if date==yq(`year',`quarter') 

		*Instrument selection
		qui lasso linear treat (dummy_ent*) lgpop median_lum* sexo  x_t_* $instruments $instruments_c
		cap vl drop controls_`year'_`quarter'
		cap vl drop inst_`year'_`quarter'
		vl create controls_`year'_`quarter' = (`e(allvars_sel)')
		vl modify controls_`year'_`quarter' = controls_`year'_`quarter' - ($instruments $instruments_c)
		vl create inst_`year'_`quarter' = (`e(allvars_sel)')
		vl modify inst_`year'_`quarter' = inst_`year'_`quarter' - (dummy_ent* median_lum* sexo  lgpop x_t_*)

		*IV
		ivreg2 e_t_ ${controls_`year'_`quarter'} (treat = ${inst_`year'_`quarter'}) if bal_48_imss==1 , cluster(cvemun)
		cap drop esample_c
		gen esample_c = (e(sample)==1)
			
		*First stage		
		cap reg treat ${inst_`year'_`quarter'} ${controls_`year'_`quarter'} if esample_c==1, cluster(cvemun)
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

cap drop n
gen n = yq(2005,1) + _n -1 if _n<=16
format n %tq

*First stage
twoway (rarea coef2 coef3 n, color(blue%25)) (scatter coef1 n, color(black) connect(line)) ///
 (scatter coef4 n , color(maroon) connect(line) yaxis(2)) ///
	, legend(order(2 "log(# clinics)" 3 "F-stat") rows(1) pos(6)) name(first_c, replace) yline(0) ytitle("First stage", axis(1)) ytitle("F-stat", axis(2)) xtitle("") 
graph export "$directorio/Figuras/IV_FS.pdf", replace	


foreach var of varlist p_t_ p_1_ e_t_  /// B-C
		 lg1_masa_sal_ta* /// asg
		  {
	preserve
	
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

			*IV
			ivreg2 `var' ${controls_`year'_`quarter'} (treat = ${inst_`year'_`quarter'}) if bal_48_imss==1, cluster(cvemun)
			cap drop esample_c
			gen esample_c = (e(sample)==1)
			
			cap mat iv[`j',1] = _b[treat]
			cap mat iv[`j',2] = _b[treat] + invnormal(0.975)*_se[treat]
			cap mat iv[`j',3] = _b[treat] - invnormal(0.975)*_se[treat]
			

			local j = `j' + 1
		}
	}



	********************************************************************************
	********************************************************************************

	* Plot estimates over time

	svmat iv

	cap drop n
	gen n = yq(2005,1) + _n -1 if _n<=16
	format n %tq

	
	*Second stage	
	twoway (rarea iv2 iv3 n, color(blue%25)) (scatter iv1 n, color(black) connect(line)) ///
	(scatter iv4 n , color(maroon) connect(line) yaxis(2)) ///
		, legend(order(2 "SP" 3 "Share treated") rows(1) pos(6)) name(second_c, replace) yline(0) ytitle("Elasticity", axis(1)) ytitle("Share of treated", axis(2)) xtitle("")
	graph export "$directorio/Figuras/IV_SP_`var'.pdf", replace
	
	
	restore
}
