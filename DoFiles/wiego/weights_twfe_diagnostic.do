
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	Oct. 18, 2022
* Last date of modification: 
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Computation of TWFE weights for diagnostics of TWFE

*******************************************************************************/
*/ 

use  "Data Created\DiD_DB.dta", clear	
drop bal_48 
merge 1:1 cvemun date using "Data Created\DiD_BC.dta", keepusing(bal_48)

keep if year<=2011
keep SP_b* cvemun ent date median_lum x_t_* lgpop pob2000 bal_48* /// treatvar & controls
		p_t* p_1 e_t  /// emp dep var  
		lg_afiliados_imss* lg1_afiliados_imss* lg1_masa_sal_ta* /// asg
		lg_total_d* /// mortality dep var
		sexo lg_salario_promedio /* other vars */

gen e_t_ = lg1_afiliados_imss	
gen p_1_ = lg1_afiliados_imss_1	
		
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


**********  TWFE WEIGHTS  ***********
*************************************
*************************************


foreach var of varlist p_t p_1 e_t {
	twowayfeweights `var' cvemun date SP_b if bal_48==1, type(feTR) controls(lgpop x_t_* median_lum* sexo) weight(pob2000) path("$directorio/_aux/twfe_w_`var'.dta")

	preserve
	use "$directorio/_aux/twfe_w_`var'.dta", clear
	format Time_TWFE %tq

	scatter weight Time_TWFE, ms(Oh) yline(0, lcolor(black) lpattern(solid) lwidth(medthick)) xtitle("") ytitle("Weight")  
	graph export "$directorio/Figuras/twfe_w_`var'.pdf", replace
	restore
}


