
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	June. 20, 2022
* Last date of modification: July. 20, 2022
* Modifications: Added mortality outcomes
* Files used:     
		- 
* Files created:  

* Purpose: 

*******************************************************************************/
*/

use  "Data Created\DiD_DB.dta", clear	
keep if year<=2011
keep SP_b* cvemun ent date median_lum x_t_* lgpop pob2000 bal_48* /// treatvar & controls
		p_t p_50 p_250 p_1000m e_t e_50 e_250 e_1000m   /// emp dep var  
		lg_eventuales* lg_permanentes* lg_ta_femenino lg_ta_masculino /// imss consolidated
		lg_afiliados_imss* lg_trab_eventual_urb* lg_trab_eventual_campo* lg_trab_perm_urb* lg_trab_perm_campo* lg_ta_sal* lg_teu_sal* lg_tec_sal* lg_tpu_sal* lg_tpc_sal* lg_masa_sal_* /// asg dep var  
		lg_total_d* /// mortality dep var
		sexo salario_promedio /// other vars

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
foreach var of varlist p_t p_50 p_250 p_1000m e_t e_50 e_250 e_1000m { 

	eststo clear
	
	*TWFE 
	eststo : xi : xtreg `var' i.date lgpop x_t_* SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48==1, fe  cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*B-C specification
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48==1, fe  cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*Luminosity
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48==1, fe cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*Luminosity (+ other controls)
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo salario_promedio SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48==1, fe cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*Luminosity (+ quarter of implementation)
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* c.date#i.q_imp SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48==1, fe cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*Luminosity (+ other controls) (+ quarter of implementation)
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo salario_promedio c.date#i.q_imp SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48==1, fe cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'
		

	esttab using "$directorio/Tables/reg_results/did_reg_`var'.csv", se r2 ${star} b(a2)  replace keep(SP*) scalars("DepVarMean DepVarMean" "num_mun num_mun")	

}	
	
	
******************************** IMSS ******************************************
foreach var of varlist lg_eventuales* lg_permanentes* lg_ta_femenino lg_ta_masculino /// imss consolidated
		lg_afiliados_imss* lg_trab_eventual_urb* lg_trab_eventual_campo* lg_trab_perm_urb* lg_trab_perm_campo* lg_ta_sal* lg_teu_sal* lg_tec_sal* lg_tpu_sal* lg_tpc_sal* lg_masa_sal_* /// asg
		{ 

	eststo clear
	
	*TWFE 
	eststo : xi : xtreg `var' i.date lgpop x_t_* SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_imss==1, fe  cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*B-C specification
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_imss==1, fe  cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*Luminosity
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_imss==1, fe cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*Luminosity (+ other controls)
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo salario_promedio SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_imss==1, fe cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*Luminosity (+ quarter of implementation)
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* c.date#i.q_imp SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_imss==1, fe cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*Luminosity (+ other controls) (+ quarter of implementation)
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo salario_promedio c.date#i.q_imp SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_imss==1, fe cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'
		

	esttab using "$directorio/Tables/reg_results/did_reg_`var'.csv", se r2 ${star} b(a2)  replace keep(SP*) scalars("DepVarMean DepVarMean" "num_mun num_mun")	

}		


******************************** MORTALITY *************************************
foreach var of varlist lg_total_d* { 

	eststo clear
	
	*TWFE 
	eststo : xi : xtreg `var' i.date lgpop x_t_* SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_imss==1, fe  cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*B-C specification
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_imss==1, fe  cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*Luminosity
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_imss==1, fe cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*Luminosity (+ other controls)
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo salario_promedio SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_imss==1, fe cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*Luminosity (+ quarter of implementation)
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* c.date#i.q_imp SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_imss==1, fe cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*Luminosity (+ other controls) (+ quarter of implementation)
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo salario_promedio c.date#i.q_imp SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_imss==1, fe cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'

*-------------------------------------------------------------------------------

	*TWFE 
	eststo : xi : xtreg `var' i.date lgpop x_t_* SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_d==1, fe  cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*B-C specification
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_d==1, fe  cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*Luminosity
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_d==1, fe cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*Luminosity (+ other controls)
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo salario_promedio SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_d==1, fe cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*Luminosity (+ quarter of implementation)
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* c.date#i.q_imp SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_d==1, fe cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*Luminosity (+ other controls) (+ quarter of implementation)
	eststo : xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo salario_promedio c.date#i.q_imp SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 [aw=pob2000] if bal_48_d==1, fe cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'

	esttab using "$directorio/Tables/reg_results/did_reg_`var'.csv", se r2 ${star} b(a2)  replace keep(SP*) scalars("DepVarMean DepVarMean" "num_mun num_mun")	

}		