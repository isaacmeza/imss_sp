
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: July. 07, 2022
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: DiD with IMSS data. Individual regressions to identify HTE

*******************************************************************************/
*/

* Merge DiD_DB with IMSS panel
use "$directorio/Data Created/panel_trabajadores.dta", clear
keep if year<=2011
merge m:1 cvemun date using "Data Created\DiD_DB.dta"
keep informal idnss date ent cvemun median_lum lgpop x_t_* SP_b_p SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16


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
eststo clear 

*B-C specification
eststo : xi : xtreg informal i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 , fe robust 
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su informal if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
*Luminosity (+ quarter of implementation)
eststo : xi : xtreg informal i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo c.date#i.q_imp SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16 , fe robust 
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su informal if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	

		
esttab using "$directorio/Tables/reg_results/did_ind_imss.csv", se r2 ${star} b(a2)  replace keep(SP*) scalars("DepVarMean DepVarMean" "num_mun num_mun")		
