
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	July. 28, 2022
* Last date of modification: Oct. 10, 2022
* Modifications: Use event_plot and keep only result for e_t p_t p_1.
* Files used:     
		- 
* Files created:  

* Purpose: 

*******************************************************************************/
*/

use  "Data Created\DiD_DB.dta", clear	
drop bal_48 
merge 1:1 cvemun date using "Data Created\DiD_BC.dta", keepusing(bal_48)

keep if year<=2011
keep SP_b* cvemun ent date median_lum x_t_* lgpop pob2000 bal_48* /// treatvar & controls
		p_t p_1 p_50 p_250 p_1000m e_t e_1 e_50 e_250 e_1000m   /// emp dep var  
		lg_afiliados_imss* lg1_masa_sal_ta* /// asg
		lg_total_d* /// mortality dep var
		sexo lg_salario_promedio /* other vars */

*Quarter of implementation
bysort cvemun : gen q_SP = date if SP_b_p==0
bysort cvemun : egen q_imp = mean(q_SP)

gen date2 = date*date
gen date3 = date2*date

gen median_lum2 = median_lum*median_lum
gen median_lum3 = median_lum2*median_lum


*Period of implementation dummies
tab SP_b_p, gen(SP_b_p)


********** EVENT STUDIES ************
*************************************
*************************************


foreach var in   p_1   { 
	
	*B-C + more municpalities
	xi : xtreg `var' SP_b_p1-SP_b_p15 SP_b_p17-SP_b_p41 i.date lgpop x_t_* i.ent*date i.ent*date2 i.ent*date3 [aw=pob2000], fe robust cluster(cvemun)
	matrix event_bc_`var' = J(37,1,.)	
	matrix se_bc_`var' = J(37,1,.)		
	forvalues j = 5/41 {
		if `j'!=16 {
			matrix event_bc_`var'[`j'-4,1] = _b[SP_b_p`j']
			matrix se_bc_`var'[`j'-4,1] = (_se[SP_b_p`j'])^2
		}
	}
	mat rownames event_bc_`var' = "Pre12" "Pre11" "Pre10" "Pre9" "Pre8" "Pre7" "Pre6" "Pre5" "Pre4" "Pre3" "Pre2" "omitted" "Post0" "Post1" "Post2" "Post3" "Post4" "Post5" "Post6" "Post7" "Post8" "Post9" "Post10" "Post11" "Post12" "Post13" "Post14" "Post15" "Post16"
	mat rownames se_bc_`var' =  "Pre12" "Pre11" "Pre10" "Pre9" "Pre8" "Pre7" "Pre6" "Pre5" "Pre4" "Pre3" "Pre2" "omitted" "Post0" "Post1" "Post2" "Post3" "Post4" "Post5" "Post6" "Post7" "Post8" "Post9" "Post10" "Post11" "Post12" "Post13" "Post14" "Post15" "Post16"

	event_plot event_bc_`var'#se_bc_`var', default_look ///
		graph_opt(xtitle("Quarters since SP adoption") ytitle("Average causal effect") ///
		title("") xlabel(-12(4)16)) stub_lag(Post#) stub_lead(Pre#) together
	graph export "$directorio/Figuras/did_event_mun_`var'.pdf", replace	
}
	
	*Luminosity (+ other controls) (+ quarter of implementation)
	xi : xtreg `var' SP_b_p1-SP_b_p15 SP_b_p17-SP_b_p41 i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo c.date#i.q_imp [aw=pob2000] if bal_48==1, fe cluster(cvemun)
	matrix event_bc_`var' = J(37,1,.)	
	matrix se_bc_`var' = J(37,1,.)		
	forvalues j = 5/41 {
		if `j'!=16 {
			matrix event_bc_`var'[`j'-4,1] = _b[SP_b_p`j']
			matrix se_bc_`var'[`j'-4,1] = (_se[SP_b_p`j'])^2
		}
	}
	mat rownames event_bc_`var' = "Pre12" "Pre11" "Pre10" "Pre9" "Pre8" "Pre7" "Pre6" "Pre5" "Pre4" "Pre3" "Pre2" "omitted" "Post0" "Post1" "Post2" "Post3" "Post4" "Post5" "Post6" "Post7" "Post8" "Post9" "Post10" "Post11" "Post12" "Post13" "Post14" "Post15" "Post16"
	mat rownames se_bc_`var' =  "Pre12" "Pre11" "Pre10" "Pre9" "Pre8" "Pre7" "Pre6" "Pre5" "Pre4" "Pre3" "Pre2" "omitted" "Post0" "Post1" "Post2" "Post3" "Post4" "Post5" "Post6" "Post7" "Post8" "Post9" "Post10" "Post11" "Post12" "Post13" "Post14" "Post15" "Post16"		

	event_plot event_bc_`var'#se_bc_`var', default_look ///
		graph_opt(xtitle("Quarters since SP adoption") ytitle("Average causal effect") ///
		title("") xlabel(-12(4)16)) stub_lag(Post#) stub_lead(Pre#) together
	graph export "$directorio/Figuras/did_event_flex_`var'.pdf", replace	
}




did_multiplegt p_t cvemun date SP_b, robust_dynamic dynamic(16) placebo(12) breps(3)  controls(lgpop x_t_* median_lum* sexo) cluster(cvemun)

event_plot e(estimates)#e(variances), default_look ///
	graph_opt(xtitle("Quarters since SP adoption") ytitle("Average causal effect") ///
		title("") xlabel(-12(4)16)) stub_lag(Effect_#) stub_lead(Placebo_#) together
	
	