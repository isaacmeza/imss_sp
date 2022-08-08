
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	July. 28, 2022
* Last date of modification: 
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: 

*******************************************************************************/
*/

use  "Data Created\DiD_DB.dta", clear	

keep if year<=2011
keep SP_b* cvemun ent date median_lum x_t_* lgpop pob2000 bal_48* /// treatvar & controls
		p_t p_1 p_50 p_250 p_1000m e_t e_1 e_50 e_250 e_1000m   /// emp dep var  
		lg_afiliados_imss* lg1_masa_sal_ta* /// asg
		lg_total_d* /// mortality dep var
		sexo lg_salario_promedio /// other vars

*Quarter of implementation
bysort cvemun : gen q_SP = date if SP_b_p==0
bysort cvemun : egen q_imp = mean(q_SP)

gen date2 = date*date
gen date3 = date2*date

gen median_lum2 = median_lum*median_lum
gen median_lum3 = median_lum2*median_lum


*Period of implementation dummies
tab SP_b_col, gen(SP_b_col)


********** EVENT STUDIES ************
*************************************
*************************************

******************************** B - C *****************************************
foreach var of varlist p_t p_1 p_50 p_250 p_1000m e_t e_1 e_50 e_250 e_1000m { 

	*Luminosity (+ other controls) (+ quarter of implementation)
	xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo c.date#i.q_imp SP_b_col1-SP_b_col3 SP_b_col5-SP_b_col11 [aw=pob2000] if bal_48==1, fe cluster(cvemun)
	matrix event_SP_b = J(11,5,.)	
	forvalues j = 1/11 {
		if `j'!=4 {
			matrix event_SP_b[`j',1] = _b[SP_b_col`j']
			matrix event_SP_b[`j',2] = _b[SP_b_col`j'] + invnormal(0.975)*_se[SP_b_col`j']
			matrix event_SP_b[`j',3] = _b[SP_b_col`j'] - invnormal(0.975)*_se[SP_b_col`j']
			matrix event_SP_b[`j',4] = _b[SP_b_col`j'] + invnormal(0.95)*_se[SP_b_col`j']
			matrix event_SP_b[`j',5] = _b[SP_b_col`j'] - invnormal(0.95)*_se[SP_b_col`j']		
		}
	}
	
	********** EVENT PLOT ************
	preserve
	clear 
	svmat event_SP_b
	
	cap drop period
	gen period = _n - 5 if inrange(_n,1,11)
			
	twoway (scatter event_SP_b1 period, color(black) lcolor(gs10%50) msize(medium) connect(line)) /// 
		(rcap event_SP_b2 event_SP_b3 period, color(navy%50)) /// 
		(rcap event_SP_b4 event_SP_b5 period, color(navy)) ///
		, legend(off) xline(-1) yline(0, lcolor(red)) xtitle("Period (year) relative to treatment")
	graph export "$directorio/Figuras/did_event_`var'.pdf", replace	
	restore
}	
	
	
******************************** IMSS ******************************************
foreach var of varlist lg_afiliados_imss* lg1_masa_sal_ta* /// imss consolidated
		{ 

	*B-C
	xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* SP_b_col1-SP_b_col3 SP_b_col5-SP_b_col11 [aw=pob2000] if bal_48==1, fe cluster(cvemun)
	matrix event_SP_b = J(11,5,.)	
	forvalues j = 1/11 {
		if `j'!=4 {
			matrix event_SP_b[`j',1] = _b[SP_b_col`j']
			matrix event_SP_b[`j',2] = _b[SP_b_col`j'] + invnormal(0.975)*_se[SP_b_col`j']
			matrix event_SP_b[`j',3] = _b[SP_b_col`j'] - invnormal(0.975)*_se[SP_b_col`j']
			matrix event_SP_b[`j',4] = _b[SP_b_col`j'] + invnormal(0.95)*_se[SP_b_col`j']
			matrix event_SP_b[`j',5] = _b[SP_b_col`j'] - invnormal(0.95)*_se[SP_b_col`j']		
		}
	}
	
	********** EVENT PLOT ************
	preserve
	clear 
	svmat event_SP_b
	
	cap drop period
	gen period = _n - 5 if inrange(_n,1,11)
			
	twoway (scatter event_SP_b1 period, color(black) lcolor(gs10%50) msize(medium) connect(line)) /// 
		(rcap event_SP_b2 event_SP_b3 period, color(navy%50)) /// 
		(rcap event_SP_b4 event_SP_b5 period, color(navy)) ///
		, legend(off) xline(-1) yline(0, lcolor(red)) xtitle("Period (year) relative to treatment")
	graph export "$directorio/Figuras/did_event_`var'_bc.pdf", replace	
	restore
	
	
	
*-------------------------------------------------------------------------------
	
	
	
	*Luminosity (+ other controls) (+ quarter of implementation)
	xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo c.date#i.q_imp SP_b_col1-SP_b_col3 SP_b_col5-SP_b_col11 [aw=pob2000] if bal_48_imss==1, fe cluster(cvemun)
	matrix event_SP_b = J(11,5,.)	
	forvalues j = 1/11 {
		if `j'!=4 {
			matrix event_SP_b[`j',1] = _b[SP_b_col`j']
			matrix event_SP_b[`j',2] = _b[SP_b_col`j'] + invnormal(0.975)*_se[SP_b_col`j']
			matrix event_SP_b[`j',3] = _b[SP_b_col`j'] - invnormal(0.975)*_se[SP_b_col`j']
			matrix event_SP_b[`j',4] = _b[SP_b_col`j'] + invnormal(0.95)*_se[SP_b_col`j']
			matrix event_SP_b[`j',5] = _b[SP_b_col`j'] - invnormal(0.95)*_se[SP_b_col`j']		
		}
	}
	
	********** EVENT PLOT ************
	preserve
	clear 
	svmat event_SP_b
	
	cap drop period
	gen period = _n - 5 if inrange(_n,1,11)
			
	twoway (scatter event_SP_b1 period, color(black) lcolor(gs10%50) msize(medium) connect(line)) /// 
		(rcap event_SP_b2 event_SP_b3 period, color(navy%50)) /// 
		(rcap event_SP_b4 event_SP_b5 period, color(navy)) ///
		, legend(off) xline(-1) yline(0, lcolor(red)) xtitle("Period (year) relative to treatment")
	graph export "$directorio/Figuras/did_event_`var'.pdf", replace	
	restore
}	
	


******************************** MORTALITY *************************************
foreach var of varlist lg_total_d* { 

	*B-C
	xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo c.date#i.q_imp SP_b_col1-SP_b_col3 SP_b_col5-SP_b_col11 [aw=pob2000] if bal_48_imss==1, fe cluster(cvemun)
	matrix event_SP_b = J(11,5,.)	
	forvalues j = 1/11 {
		if `j'!=4 {
			matrix event_SP_b[`j',1] = _b[SP_b_col`j']
			matrix event_SP_b[`j',2] = _b[SP_b_col`j'] + invnormal(0.975)*_se[SP_b_col`j']
			matrix event_SP_b[`j',3] = _b[SP_b_col`j'] - invnormal(0.975)*_se[SP_b_col`j']
			matrix event_SP_b[`j',4] = _b[SP_b_col`j'] + invnormal(0.95)*_se[SP_b_col`j']
			matrix event_SP_b[`j',5] = _b[SP_b_col`j'] - invnormal(0.95)*_se[SP_b_col`j']		
		}
	}
	
	********** EVENT PLOT ************
	preserve
	clear 
	svmat event_SP_b
	
	cap drop period
	gen period = _n - 5 if inrange(_n,1,11)
			
	twoway (scatter event_SP_b1 period, color(black) lcolor(gs10%50) msize(medium) connect(line)) /// 
		(rcap event_SP_b2 event_SP_b3 period, color(navy%50)) /// 
		(rcap event_SP_b4 event_SP_b5 period, color(navy)) ///
		, legend(off) xline(-1) yline(0, lcolor(red)) xtitle("Period (year) relative to treatment")
	graph export "$directorio/Figuras/did_event_`var'.pdf", replace	
	restore
	
*-------------------------------------------------------------------------------

	*Luminosity (+ other controls) (+ quarter of implementation)
	xi : xtreg `var' i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo c.date#i.q_imp SP_b_col1-SP_b_col3 SP_b_col5-SP_b_col11 [aw=pob2000] if bal_48_d==1, fe cluster(cvemun)
	matrix event_SP_b = J(11,5,.)	
	forvalues j = 1/11 {
		if `j'!=4 {
			matrix event_SP_b[`j',1] = _b[SP_b_col`j']
			matrix event_SP_b[`j',2] = _b[SP_b_col`j'] + invnormal(0.975)*_se[SP_b_col`j']
			matrix event_SP_b[`j',3] = _b[SP_b_col`j'] - invnormal(0.975)*_se[SP_b_col`j']
			matrix event_SP_b[`j',4] = _b[SP_b_col`j'] + invnormal(0.95)*_se[SP_b_col`j']
			matrix event_SP_b[`j',5] = _b[SP_b_col`j'] - invnormal(0.95)*_se[SP_b_col`j']		
		}
	}
	
	********** EVENT PLOT ************
	preserve
	clear 
	svmat event_SP_b
	
	cap drop period
	gen period = _n - 5 if inrange(_n,1,11)
			
	twoway (scatter event_SP_b1 period, color(black) lcolor(gs10%50) msize(medium) connect(line)) /// 
		(rcap event_SP_b2 event_SP_b3 period, color(navy%50)) /// 
		(rcap event_SP_b4 event_SP_b5 period, color(navy)) ///
		, legend(off) xline(-1) yline(0, lcolor(red)) xtitle("Period (year) relative to treatment")
	graph export "$directorio/Figuras/did_event_`var'_2.pdf", replace	
	restore
}		

