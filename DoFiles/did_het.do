
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

tab ent, gen(ent_d)
drop ent_d1

*Period of implementation dummies
tab SP_b_p, gen(SP_b_p)


********** DiD  Chaisemartin and D'Haultfoeuille ************
*************************************************************
*************************************************************

local breps = 3

matrix dd = J(12,3,.)
matrix pt = J(12,1,.)

******************************** IMSS ******************************************


local j = 1
foreach var of varlist lg_ta_femenino lg_ta_masculino  /// imss consolidated
		 lg_trab_eventual lg_trab_perm lg_trab_campo lg_trab_urb lg_ta_sal lg1_voluntarios /// asg
		 { 	
					
			did_multiplegt p_t cvemun date SP_b if bal_48_imss==1, robust_dynamic average_effect dynamic(16) placebo(8) jointtestplacebo covariances breps(`breps')  controls(lgpop x_t_* median_lum* sexo) weight(pob2000) cluster(cvemun)
			
			matrix dd[`j',1] =   e(effect_average)
			matrix dd[`j',2] =   e(effect_average) - invnormal(.975)*e(se_effect_average)
			matrix dd[`j',3] =   e(effect_average) + invnormal(.975)*e(se_effect_average) 
			
			matrix pt[`j',1] =   e(p_jointplacebo)
			
			local j = `j' + 1
		 }
	
			

******************************** IMSS CROSS  ***********************************
eststo clear
foreach var of varlist lg1_ta_low_wage lg1_ta_high_wage lg1_ta_soltero  lg1_ta_casado /// Cross-IMSS
		 { 		
		 						
			did_multiplegt p_t cvemun date SP_b if bal_48_imss==1, robust_dynamic average_effect dynamic(16) placebo(8) jointtestplacebo covariances breps(`breps')  controls(lgpop x_t_* median_lum* sexo) weight(pob2000) cluster(cvemun)
			
			matrix dd[`j',1] =   e(effect_average)
			matrix dd[`j',2] =   e(effect_average) - invnormal(.975)*e(se_effect_average)
			matrix dd[`j',3] =   e(effect_average) + invnormal(.975)*e(se_effect_average) 
			
			matrix pt[`j',1] =   e(p_jointplacebo)
			
			local j = `j' + 1
		 }
		 	

mat rownames dd =  "Female"  "Male" "Temporal" "Permanent" "Rural" "Urban" "Asalaried" "Voluntary" "Low-wage" "High-wage" "Single" "Married"
  
mat rownames pt =  "Female"  "Male" "Temporal" "Permanent" "Rural" "Urban" "Asalaried" "Voluntary" "Low-wage" "High-wage" "Single" "Married"
	
	coefplot (matrix(dd[,1]), offset(0.06) ci((dd[,2] dd[,3])) msize(large) ciopts(lcolor(gs4))) ///
	(matrix(pt[,1]), axis(2) offset(-0.06) msize(large) ciopts(lcolor(gs4))) , ///
	legend(order(2 "DiD Effect" 4 "Join test placebo") pos(6) rows(1))  xline(0)  graphregion(color(white)) 
graph export "$directorio/Figuras/did_het.pdf", replace
	
				