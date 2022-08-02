
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	July. 11, 2022
* Last date of modification: July. 31, 2022
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Bosch-Campos results replication

*******************************************************************************/
*/

use  "Data Created\DiD_BC.dta", clear	

*Define lag variable previous to 4 years as 1
replace TbL16x=1 if TbL16==0
	
	
*********** REGRESSIONS *************
*************************************
*************************************	
eststo clear
	
foreach var in p_t p_1 p_50 p_250 p_1000m e_t e_1 e_50 e_250 e_1000m { 
	* Bosch-Campos specification
	eststo : xi : xtreg `var' TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16  logpop x_t_* i.ent*date i.ent*date2 i.ent*date3 i.date [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'		
}

	esttab using "$directorio/Tables/reg_results/did_bc.csv", se r2 ${star} b(a2)  replace keep(Tb*) scalars("DepVarMean DepVarMean" "num_mun num_mun")	

	
	
********************************************************************************
********************************************************************************

*Period of implementation dummies
tab SP_BC_col, gen(SP_BC_col)

********** EVENT STUDIES ************
*************************************
*************************************
foreach var in p_t p_1 p_50 p_250 p_1000m e_t e_1 e_50 e_250 e_1000m { 
	xi : xtreg `var' SP_BC_col1-SP_BC_col3 SP_BC_col5-SP_BC_col11 i.date logpop x_t_* i.ent*date i.ent*date2 i.ent*date3 [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
	matrix event_bc_`var' = J(11,5,.)	
	forvalues j = 1/11 {
		if `j'!=4 {
			matrix event_bc_`var'[`j',1] = _b[SP_BC_col`j']
			matrix event_bc_`var'[`j',2] = _b[SP_BC_col`j'] + invnormal(0.975)*_se[SP_BC_col`j']
			matrix event_bc_`var'[`j',3] = _b[SP_BC_col`j'] - invnormal(0.975)*_se[SP_BC_col`j']
			matrix event_bc_`var'[`j',4] = _b[SP_BC_col`j'] + invnormal(0.95)*_se[SP_BC_col`j']
			matrix event_bc_`var'[`j',5] = _b[SP_BC_col`j'] - invnormal(0.95)*_se[SP_BC_col`j']		
		}
	}
}


clear
svmat event_bc_p_t
foreach var in p_1 p_50 p_250 p_1000m e_t e_1 e_50 e_250 e_1000m { 
	svmat event_bc_`var'
}

gen period = _n - 5 if inrange(_n,1,11)	
			
foreach var in p_t p_1 p_50 p_250 p_1000m e_t e_1 e_50 e_250 e_1000m { 
	twoway (scatter event_bc_`var'1 period, color(black) lcolor(gs10%50) msize(medium) connect(line)) /// 
				(rcap event_bc_`var'2 event_bc_`var'3 period, color(navy%50)) /// 
				(rcap event_bc_`var'4 event_bc_`var'5 period, color(navy)) ///
				, legend(off) xline(-1) yline(0, lcolor(red)) xtitle("Period relative to treatment")
	graph export "$directorio/Figuras/did_event_bc_`var'.pdf", replace	
}


