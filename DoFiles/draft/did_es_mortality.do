
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	July. 28, 2022
* Last date of modification: Oct. 26, 2022
* Modifications: Estimate did for mortality overall and on certain diseases
* Files used:     
		- 
* Files created:  

* Purpose: 

*******************************************************************************/
*/ 

// Control if the flexible specification should be run
local flexible = 1

use  "Data Created\DiD_DB.dta", clear 

preserve

keep if year <= 2016
keep cvemun SP_b_col date year quarter pob2000 pobtot bal_48* SP_b bal_68*

*Epolation of population
bysort cvemun : egen pob2000_ = mean(pob2000)
replace pob2000 = pob2000_ if missing(pob2000)
drop pob2000_

gen logpop = log(pobtot)
replace logpop = . if quarter != 4

sort cvemun date
by cvemun : ipolate logpop date, gen(lgpop) epolate
drop logpop

bysort cvemun : ipolate lgpop date, gen(lgpop_) epolate
drop lgpop
rename lgpop_ lgpop

tempfile aux_vars
save `aux_vars', replace

restore

*Period of implementation dummies
tab SP_b_col, gen(SP_b_col)

collapse (sum) total_d* carcinoma-high_blood_pressure (mean) x_t_* mean_lum sexo (min) date if bal_68_d==1, by(cvemun SP_b_col*)

merge 1:1 cvemun date using `aux_vars', nogen keep(3)

keep if year <= 2016

*Imputation deaths
foreach var of varlist total_d* {
	replace `var' = 0 if missing(`var') & inrange(year, 2000, 2019) 
}
foreach var of varlist total_d* carcinoma-high_blood_pressure {
	gen lg_`var' = log(`var' + 1)
}

gen ent = floor(cvemun/1000)

keep SP_b* cvemun ent date year quarter mean_lum x_t_* lgpop pob2000 bal_48* bal_68* /// treatvar & controls
		lg_total_d* /// mortality dep var
		lg_carcinoma-lg_high_blood_pressure /// moartality on certain diseases
		sexo // other vars
		
*Year of implementation
gen years = year(dofq(date))
format years %ty

sort cvemun date
by cvemun : gen imp_yr = years if SP_b_col==0
by cvemun : replace imp_yr = imp_yr[_n-1] +1 if missing(imp_yr)
by cvemun : replace imp_yr = imp_yr[_n+1] -1 if missing(imp_yr)
by cvemun : replace imp_yr = imp_yr[_n+1] -1 if missing(imp_yr)
by cvemun : replace imp_yr = imp_yr[_n+1] -1 if missing(imp_yr)
by cvemun : replace imp_yr = imp_yr[_n+1] -1 if missing(imp_yr)
by cvemun : replace imp_yr = imp_yr[_n+1] -1 if missing(imp_yr)

gen imp_yr2 = imp_yr*imp_yr
gen imp_yr3 = imp_yr2*imp_yr
	
// Set panel
drop if missing(cvemun)
drop if missing(date)
drop if missing(imp_yr)
sort cvemun years
	
xtset cvemun imp_yr

gen mean_lum2 = mean_lum*mean_lum
gen mean_lum3 = mean_lum2*mean_lum

tab ent, gen(ent_d)
drop ent_d1


********** EVENT STUDIES ************
*************************************
*************************************


foreach var of varlist lg_total_d lg_total_d_cov_sp lg_total_d_cov_isp lg_carcinoma-lg_high_blood_pressure {

	if (`flexible' == 1) {
		
	di in red "Doing flexible specification"
	*Luminosity (+ other controls) (+ quarter of implementation)
	//xi : xtreg `var' SP_b_col1-SP_b_col4 SP_b_col6-SP_b_col13 i.ent*imp_yr i.ent*imp_yr2 i.ent*imp_yr3 i.imp_yr lgpop x_t_* if bal_68==1 [aw=pob2000] , fe cluster(cvemun)
	xi : xtreg `var' i.ent*imp_yr i.ent*imp_yr2 i.ent*imp_yr3 i.imp_yr lgpop x_t_* mean_lum* sexo c.date#i.imp_yr SP_b_col1-SP_b_col4 SP_b_col6-SP_b_col13 [aw=pob2000] if bal_68 == 1, fe cluster(cvemun)
	matrix event_bc_`var' = J(13,1,.)	
	matrix var_bc_`var' = J(13,1,.)		
	forvalues j = 1/13 {
		if `j'!=5 {
			matrix event_bc_`var'[`j',1] = _b[SP_b_col`j']
			matrix var_bc_`var'[`j',1] = (_se[SP_b_col`j'])^2
		}
	}
	mat rownames event_bc_`var' = "Pre5" "Pre4" "Pre3" "Pre2" "omitted" "Post0" "Post1" "Post2" "Post3" "Post4" "Post5" "Post6" "Post7"  
	mat rownames var_bc_`var' = "Pre5" "Pre4" "Pre3" "Pre2" "omitted" "Post0" "Post1" "Post2" "Post3" "Post4" "Post5" "Post6" "Post7" 
	
	matrix list event_bc_`var'
	matrix list var_bc_`var'

	event_plot event_bc_`var'#var_bc_`var', default_look ///
		graph_opt(xtitle("Years since SP adoption") ytitle("Average causal effect") ///
		title("") xlabel(-5(1)6)) stub_lag(Post#) stub_lead(Pre#) together
	graph export "$directorio/Figuras/did_event_flex_`var'_mort.pdf", replace	
	
	}
		di in red "Doing de Chaisemartin and D'Haultfoeuille"
	*de Chaisemartin, C and D'Haultfoeuille, X (2020b).  Difference-in-Differences Estimators of Intertemporal Treatment Effects.
	did_multiplegt `var' cvemun imp_yr SP_b if bal_68_d==1, robust_dynamic dynamic(7) placebo(5) breps(3) controls(lgpop x_t_* mean_lum* sexo) weight(pob2000) cluster(cvemun)

	event_plot e(estimates)#e(variances), default_look ///
		graph_opt(xtitle("Years since SP adoption") ytitle("Average causal effect") ///
		title("") xlabel(-5(1)7)) stub_lag(Effect_#) stub_lead(Placebo_#) together	
	graph export "$directorio/Figuras/did_event_ch_`var'_mort.pdf", replace	
	
}

