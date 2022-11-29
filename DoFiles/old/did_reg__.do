
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	June. 20, 2022
* Last date of modification: Aug. 08, 2022
* Modifications: Added mortality outcomes
	Added cross-IMSS outcomes
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
		lg_ta_femenino lg_ta_masculino lg1_voluntarios /// imss consolidated
		lg_afiliados_imss* lg_trab_eventual lg_trab_perm lg_trab_campo lg_trab_urb lg_ta_sal ///
		lg1_masa_sal_ta* lg1_masa_sal_te lg1_masa_sal_tp lg1_masa_sal_tc lg1_masa_sal_tu /// asg
		lg1_emp_cross* lg1_ta_low_wage lg1_ta_high_wage lg1_ta_soltero  lg1_ta_casado /// Cross-IMSS
		lg_total_d* /// mortality dep var
		sexo lg_salario_promedio /* other vars */

*Quarter of implementation
bysort cvemun : gen q_SP = date if SP_b_p==0
bysort cvemun : egen q_imp = mean(q_SP)

gen date2 = date*date
gen date3 = date2*date

gen median_lum2 = median_lum*median_lum
gen median_lum3 = median_lum2*median_lum



*********** REGRESSIONS *************
*************************************
*************************************

******************************** B - C *****************************************
eststo clear
foreach var of varlist p_t p_1 p_50 p_250 p_1000m { 	
	*B-C specification
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48==1, fe  cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
		
	*Luminosity (+ quarter of implementation)
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo c.date#i.q_imp SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48==1, fe cluster(cvemun)
		testparm i(161/200).q_imp#c.date
		local pval = `r(p)'
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		estadd scalar pval_alpha = `pval'
}	
	esttab using "$directorio/Tables/reg_results/did_reg_pat.csv", se r2 ${star} b(a2)  replace keep(SP*) scalars("DepVarMean DepVarMean" "num_mun num_mun" "pval_alpha pval_alpha")		
	
	
eststo clear
foreach var of varlist e_t e_1 e_50 e_250 e_1000m { 	
	*B-C specification
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48==1, fe  cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
		
	*Luminosity (+ quarter of implementation)
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo c.date#i.q_imp SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48==1, fe cluster(cvemun)
		testparm i(161/200).q_imp#c.date
		local pval = `r(p)'
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		estadd scalar pval_alpha = `pval'
}	
	esttab using "$directorio/Tables/reg_results/did_reg_emp.csv", se r2 ${star} b(a2)  replace keep(SP*) scalars("DepVarMean DepVarMean" "num_mun num_mun" "pval_alpha pval_alpha")			
	
	

******************************** IMSS ******************************************
eststo clear
foreach var of varlist lg_ta_femenino lg_ta_masculino  /// imss consolidated
		 lg_trab_eventual lg_trab_perm lg_trab_campo lg_trab_urb lg_ta_sal lg1_voluntarios /// asg
		 { 	
	*B-C specification
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48==1, fe  cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'			 	
			
			
	*Luminosity (+ quarter of implementation)
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo c.date#i.q_imp SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_imss==1, fe cluster(cvemun)
		testparm i(161/200).q_imp#c.date
		local pval = `r(p)'
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		estadd scalar pval_alpha = `pval'
}		

	esttab using "$directorio/Tables/reg_results/did_reg_het.csv", se r2 ${star} b(a2)  replace keep(SP*) scalars("DepVarMean DepVarMean" "num_mun num_mun" "pval_alpha pval_alpha")			
	
	
	

******************************** IMSS ASG **************************************
eststo clear
foreach var of varlist lg1_masa_sal_ta* {
	*B-C specification
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48==1, fe  cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
		
	*Luminosity (+ quarter of implementation)
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo c.date#i.q_imp SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_imss==1, fe cluster(cvemun)
		testparm i(161/200).q_imp#c.date
		local pval = `r(p)'
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		estadd scalar pval_alpha = `pval'	
}		

	esttab using "$directorio/Tables/reg_results/did_reg_sal.csv", se r2 ${star} b(a2)  replace keep(SP*) scalars("DepVarMean DepVarMean" "num_mun num_mun" "pval_alpha pval_alpha")					
			

			