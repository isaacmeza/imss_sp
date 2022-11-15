
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
merge 1:1 cvemun date using "Data Created\DiD_BC.dta", keepusing(bal_48 TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16)

keep if year<=2011
keep SP_b* cvemun ent date median_lum x_t_* lgpop pob2000 bal_48* /// treatvar & controls
		p_t* p_1 e_t  /// emp dep var  
		lg_afiliados_imss* lg1_afiliados_imss* lg1_masa_sal_ta* /// asg
		lg_total_d* /// mortality dep var
		sexo lg_salario_promedio TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 /* other vars */

gen e_t_ = lg1_afiliados_imss	
gen p_1_ = lg1_afiliados_imss_1	
gen lg1_masa_sal_ta_ = lg1_masa_sal_ta	
gen lg1_masa_sal_ta_1_ = lg1_masa_sal_ta_1	
		
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

tab SP_b_col, gen(SP_b_col)


*keep if inrange(SP_b_col,-3,4)

********** EVENT STUDIES ************
*************************************
*************************************

	xi : reg lg_total_d   SP_b_col1-SP_b_col3 SP_b_col5-SP_b_col11  if bal_48==1 
	

	xi : xtreg lg_total_d  i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_*  SP_b_col1-SP_b_col3 SP_b_col5-SP_b_col11  [aw=pob2000] , fe cluster(cvemun)


	collapse (mean) lg_total_d lgpop x_t_* (min) pob2000 ent date date2 date3 if bal_48==1, by(SP_b_col* cvemun)
	
	
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

	
xtset cvemun imp_yr

xi : reg lg_total_d   SP_b_col1-SP_b_col3 SP_b_col5-SP_b_col11   
	

	xi : xtreg lg_total_d  i.ent*imp_yr i.ent*imp_yr2 i.ent*imp_yr3 i.imp_yr lgpop x_t_*  SP_b_col1-SP_b_col3 SP_b_col5-SP_b_col11  [aw=pob2000] , fe cluster(cvemun)
	
	


	