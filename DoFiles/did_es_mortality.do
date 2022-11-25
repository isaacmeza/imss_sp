
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
keep if year <= 2018

keep SP_b* cvemun ent date year quarter median_lum x_t_* lgpop pob2000 bal_48* bal_76* /// treatvar & controls
		lg_total_d* /// mortality dep var
		lg_anemia-lg_high_blood_pressure /// moartality on certain diseases
		sexo // other vars
		
*Quarter of implementation
bysort cvemun : gen q_SP = date if SP_b_p==0
bysort cvemun : egen q_imp = mean(q_SP)

gen date2 = date*date
gen date3 = date2*date

gen median_lum2 = median_lum*median_lum
gen median_lum3 = median_lum2*median_lum

tab ent, gen(ent_d)
drop ent_d1

*Period of implementation dummies
tab SP_b_p, gen(SP_b_p)


********** EVENT STUDIES ************
*************************************
*************************************


foreach var of varlist lg_total_d lg_total_d_cov_sp lg_total_d_cov_isp lg_anemia-lg_high_blood_pressure {

	if (`flexible' == 1) {
		
	di in red "Doing flexible specification"
	*Luminosity (+ other controls) (+ quarter of implementation)
	xi : xtreg `var' SP_b_p1-SP_b_p23 SP_b_p25-SP_b_p57 i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo c.date#i.q_imp [aw=pob2000] if bal_76==1, fe cluster(cvemun)
	matrix event_bc_`var' = J(57,1,.)	
	matrix var_bc_`var' = J(57,1,.)		
	forvalues j = 1/57 {
		if `j'!=24 {
			matrix event_bc_`var'[`j',1] = _b[SP_b_p`j']
			matrix var_bc_`var'[`j',1] = (_se[SP_b_p`j'])^2
		}
	}
	mat rownames event_bc_`var' = "Pre24" " Pre23" "Pre22" "Pre21" "Pre20" "Pre19" "Pre18" " Pre17" "Pre16" "Pre15" "Pre14" "Pre13" "Pre12" "Pre11" "Pre10" "Pre9" "Pre8" "Pre7" "Pre6" "Pre5" "Pre4" "Pre3" "Pre2" "omitted" "Post0" "Post1" "Post2" "Post3" "Post4" "Post5" "Post6" "Post7" "Post8" "Post9" "Post10" "Post11" "Post12" "Post13" "Post14" "Post15" "Post16" "Post17" "Post18" "Post19" "Post20" "Post21" "Post22" "Post23" "Post24" "Post25" "Post26" "Post27" "Post28" "Post29" "Post30" "Post31"  
	mat rownames var_bc_`var' = "Pre24" " Pre23" "Pre22" "Pre21" "Pre20" "Pre19" "Pre18" " Pre17" "Pre16" "Pre15" "Pre14" "Pre13" "Pre12" "Pre11" "Pre10" "Pre9" "Pre8" "Pre7" "Pre6" "Pre5" "Pre4" "Pre3" "Pre2" "omitted" "Post0" "Post1" "Post2" "Post3" "Post4" "Post5" "Post6" "Post7" "Post8" "Post9" "Post10" "Post11" "Post12" "Post13" "Post14" "Post15" "Post16" "Post17" "Post18" "Post19" "Post20" "Post21" "Post22" "Post23" "Post24" "Post25" "Post26" "Post27" "Post28" "Post29" "Post30" "Post31" 
	
	matrix list event_bc_`var'
	matrix list var_bc_`var'

	event_plot event_bc_`var'#var_bc_`var', default_look ///
		graph_opt(xtitle("Quarters since SP adoption") ytitle("Average causal effect") ///
		title("") xlabel(-24(4)31)) stub_lag(Post#) stub_lead(Pre#) together
	graph export "$directorio/Figuras/did_event_flex_`var'_mort.pdf", replace	
	
	}
		di in red "Doing de Chaisemartin and D'Haultfoeuille"
	*de Chaisemartin, C and D'Haultfoeuille, X (2020b).  Difference-in-Differences Estimators of Intertemporal Treatment Effects.
	did_multiplegt `var' cvemun date SP_b if bal_76_d==1, robust_dynamic dynamic(24) placebo(32) breps(5) controls(lgpop x_t_* median_lum* sexo) weight(pob2000) cluster(cvemun)

	event_plot e(estimates)#e(variances), default_look ///
		graph_opt(xtitle("Years since SP adoption") ytitle("Average causal effect") ///
		title("") xlabel(-24(1)31)) stub_lag(Effect_#) stub_lead(Placebo_#) together	
	graph export "$directorio/Figuras/did_event_ch_`var'_mort.pdf", replace	
	
	di in red "Finished estimating effect on `var'"
	beep 
}

