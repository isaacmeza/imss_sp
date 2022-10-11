
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	July. 11, 2022
* Last date of modification: Oct. 10, 2022
* Modifications: Use event_plot and keep only result for e_t p_t p_1.
* Files used:     
		- 
* Files created:  

* Purpose: Bosch-Campos results replication

*******************************************************************************/
*/

use  "Data Created\DiD_BC.dta", clear	

*Define lag variable previous to 4 years as 1
replace TbL16x=1 if TbL16==0
	
		
********************************************************************************
********************************************************************************

*Period of implementation dummies
tab xxx, gen(xxx)

********** EVENT STUDIES ************
*************************************
*************************************
foreach var in p_t p_1 e_t { 
	xi : xtreg `var' xxx1-xxx15 xxx17-xxx41 i.date logpop x_t_* i.ent*date i.ent*date2 i.ent*date3 [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
	matrix event_bc_`var' = J(37,1,.)	
	matrix se_bc_`var' = J(37,1,.)		
	forvalues j = 5/41 {
		if `j'!=16 {
			matrix event_bc_`var'[`j'-4,1] = _b[xxx`j']
			matrix se_bc_`var'[`j'-4,1] = (_se[xxx`j'])^2
		}
	}
	mat rownames event_bc_`var' = "Pre12" "Pre11" "Pre10" "Pre9" "Pre8" "Pre7" "Pre6" "Pre5" "Pre4" "Pre3" "Pre2" "omitted" "Post0" "Post1" "Post2" "Post3" "Post4" "Post5" "Post6" "Post7" "Post8" "Post9" "Post10" "Post11" "Post12" "Post13" "Post14" "Post15" "Post16"
	mat rownames se_bc_`var' =  "Pre12" "Pre11" "Pre10" "Pre9" "Pre8" "Pre7" "Pre6" "Pre5" "Pre4" "Pre3" "Pre2" "omitted" "Post0" "Post1" "Post2" "Post3" "Post4" "Post5" "Post6" "Post7" "Post8" "Post9" "Post10" "Post11" "Post12" "Post13" "Post14" "Post15" "Post16"

	event_plot event_bc_`var'#se_bc_`var', default_look ///
		graph_opt(xtitle("Quarters since SP adoption") ytitle("Average causal effect") ///
		title("") xlabel(-12(4)16)) stub_lag(Post#) stub_lead(Pre#) together
	graph export "$directorio/Figuras/did_event_bc_`var'.pdf", replace	
}


