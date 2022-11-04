
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
drop bal_48
merge 1:1 cvemun date using "Data Created\DiD_BC.dta", keepusing(bal_48)

preserve

keep if year <= 2018
keep cvemun SP_b_col ent date year quarter pob2000 pobtot bal_48* SP_b

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

collapse (sum) total_d* carcinoma-high_blood_pressure (mean) x_t_* mean_lum sexo (min) date, by(cvemun SP_b_col)

merge 1:1 cvemun date using `aux_vars', nogen keep(3)

keep if year <= 2018

*Imputation deaths
foreach var of varlist total_d* {
	replace `var' = 0 if missing(`var') & inrange(year, 2000, 2019) 
}
foreach var of varlist total_d* carcinoma-high_blood_pressure {
	gen lg_`var' = log(`var' + 1)
}


keep SP_b* cvemun ent date mean_lum x_t_* lgpop pob2000 bal_48* /// treatvar & controls
		lg_total_d* /// mortality dep var
		lg_carcinoma-lg_high_blood_pressure /// moartality on certain diseases
		sexo // other vars
		
*Quarter of implementation
bysort cvemun : gen y_SP = date if SP_b_col == 0
bysort cvemun : egen y_imp = mean(y_SP)

gen date2 = date*date
gen date3 = date2*date

gen mean_lum2 = mean_lum*mean_lum
gen mean_lum3 = mean_lum2*mean_lum

tab ent, gen(ent_d)
drop ent_d1

*Period of implementation dummies
tab SP_b_col, gen(SP_b_col)


********** EVENT STUDIES ************
*************************************
*************************************


foreach var of varlist lg_total_d lg_total_d_cov_sp lg_total_d_cov_isp lg_carcinoma-lg_high_blood_pressure {

	if (`flexible' == 1) {
		
	di in red "Doing flexible specification"
	*Luminosity (+ other controls) (+ quarter of implementation)
	xi : xtreg `var' SP_b_col1-SP_b_col7 SP_b_col9-SP_b_col17 i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* mean_lum* sexo c.date#i.y_imp [aw=pob2000] if bal_48==1, fe cluster(cvemun)
	matrix event_bc_`var' = J(20,1,.)	
	matrix var_bc_`var' = J(20,1,.)		
	forvalues j = 2/17 {
		if `j'!=8 {
			matrix event_bc_`var'[`j'-1,1] = _b[SP_b_col`j']
			matrix var_bc_`var'[`j'-1,1] = (_se[SP_b_col`j'])^2
		}
	}
	mat rownames event_bc_`var' = "Pre8" "Pre7" "Pre6" "Pre5" "Pre4" "Pre3" "Pre2" "omitted" "Post0" "Post1" "Post2" "Post3" "Post4" "Post5" "Post6" "Post7" "Post8" 
	mat rownames var_bc_`var' = "Pre8" "Pre7" "Pre6" "Pre5" "Pre4" "Pre3" "Pre2" "omitted" "Post0" "Post1" "Post2" "Post3" "Post4" "Post5" "Post6" "Post7" "Post8" 

	event_plot event_bc_`var'#var_bc_`var', default_look ///
		graph_opt(xtitle("Years since SP adoption") ytitle("Average causal effect") ///
		title("") xlabel(-8(1)8)) stub_lag(Post#) stub_lead(Pre#) together
	graph export "$directorio/Figuras/did_event_flex_`var'_mort.pdf", replace	
	
	}
		di in red "Doing de Chaisemartin and D'Haultfoeuille"
	*de Chaisemartin, C and D'Haultfoeuille, X (2020b).  Difference-in-Differences Estimators of Intertemporal Treatment Effects.
	did_multiplegt `var' cvemun date SP_b if bal_48==1, robust_dynamic dynamic(8) placebo(8) breps(3) controls(lgpop x_t_* mean_lum* sexo) weight(pob2000) cluster(cvemun)

	event_plot e(estimates)#e(variances), default_look ///
		graph_opt(xtitle("Years since SP adoption") ytitle("Average causal effect") ///
		title("") xlabel(-8(1)8)) stub_lag(Effect_#) stub_lead(Placebo_#) together	
	graph export "$directorio/Figuras/did_event_ch_`var'_mort.pdf", replace	
	
}

