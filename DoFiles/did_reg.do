
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: Jun. 20, 2022
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: 

*******************************************************************************/
*/

use  "Data Created\DiD_DB.dta", clear	

*Quarter of implementation
by cvemun : gen q_SP = date if SP_b_p==0
by cvemun : egen q_imp = mean(q_SP)

gen date2 = date*date
gen date3 = date2*date

*********** REGRESSIONS *************
*************************************
*************************************


tab SP_b_p, gen(SP_b_p)
	

foreach var in p_t p1 p4 p7 p9 e_t e1 e4 e7 e9 { 

	eststo clear
	
	*Condition on balanced municipalities
	eststo : xi : reghdfe `var' i.ent*i.date c.median_lum#i.date median_lum SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16  lgpop x_t_* [aw=pob2000] if bal_48==1, absorb(cvemun) cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
	eststo : xi : reghdfe `var' c.date#i.q_imp i.ent*i.date c.median_lum#i.date median_lum SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16  lgpop x_t_* [aw=pob2000] if bal_48==1, absorb(cvemun) cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
	
	xi : reghdfe `var' i.ent*i.date c.median_lum#i.date median_lum SP_b_p1-SP_b_p15 SP_b_p17-SP_b_p37 lgpop x_t_* [aw=pob2000] if bal_48==1,  absorb(cvemun) cluster(cvemun)
	matrix event_SP_b_c = J(37,5,.)	
	forvalues j = 1/37 {
		if `j'!=16 {
			matrix event_SP_b_c[`j',1] = _b[SP_b_p`j']
			matrix event_SP_b_c[`j',2] = _b[SP_b_p`j'] + invnormal(0.975)*_se[SP_b_p`j']
			matrix event_SP_b_c[`j',3] = _b[SP_b_p`j'] - invnormal(0.975)*_se[SP_b_p`j']
			matrix event_SP_b_c[`j',4] = _b[SP_b_p`j'] + invnormal(0.95)*_se[SP_b_p`j']
			matrix event_SP_b_c[`j',5] = _b[SP_b_p`j'] - invnormal(0.95)*_se[SP_b_p`j']		
		}
	}
	
	*All municipalities
	eststo : xi : reghdfe `var' i.ent*i.date c.median_lum#i.date median_lum SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16  lgpop x_t_* [aw=pob2000], absorb(cvemun) cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
	eststo : xi : reghdfe `var' c.date#i.q_imp i.ent*i.date c.median_lum#i.date median_lum SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16  lgpop x_t_* [aw=pob2000], absorb(cvemun) cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
	
	xi : reghdfe `var' i.ent*i.date c.median_lum#i.date median_lum SP_b_p1-SP_b_p15 SP_b_p17-SP_b_p37 lgpop x_t_* [aw=pob2000],  absorb(cvemun) cluster(cvemun)
	matrix event_SP_b = J(37,5,.)	
	forvalues j = 1/37 {
		if `j'!=16 {
			matrix event_SP_b[`j',1] = _b[SP_b_p`j']
			matrix event_SP_b[`j',2] = _b[SP_b_p`j'] + invnormal(0.975)*_se[SP_b_p`j']
			matrix event_SP_b[`j',3] = _b[SP_b_p`j'] - invnormal(0.975)*_se[SP_b_p`j']
			matrix event_SP_b[`j',4] = _b[SP_b_p`j'] + invnormal(0.95)*_se[SP_b_p`j']
			matrix event_SP_b[`j',5] = _b[SP_b_p`j'] - invnormal(0.95)*_se[SP_b_p`j']		
		}
	}


	esttab using "$directorio/Tables/reg_results/did_reg_`var'.csv", se r2 ${star} b(a2)  replace keep(SP*) scalars("DepVarMean DepVarMean" "num_mun num_mun")	


********************************************************************************
********************************************************************************


********** EVENT STUDIES ************
*************************************
*************************************
	preserve
	
	clear 
	svmat event_SP_b_c
	svmat event_SP_b
	
	cap drop period
	gen period = _n - 17 if inrange(_n,1,37)
	save  "_aux\event_did_`var'.dta", replace

	use  "_aux\event_did_`var'.dta", clear

	twoway (scatter event_SP_b_c1 period, color(black) lcolor(gs10%50) msize(medium) connect(line)) /// 
		(rcap event_SP_b_c2 event_SP_b_c3 period, color(navy%50)) /// 
		(rcap event_SP_b_c4 event_SP_b_c5 period, color(navy)) ///
		, legend(off) xline(-1) yline(0) xtitle("Period relative to treatment")
	graph export "$directorio/Figuras/did_event_`var'_c.pdf", replace	
			
	twoway (scatter event_SP_b1 period, color(black) lcolor(gs10%50) msize(medium) connect(line)) /// 
		(rcap event_SP_b2 event_SP_b3 period, color(navy%50)) /// 
		(rcap event_SP_b4 event_SP_b5 period, color(navy)) ///
		, legend(off) xline(-1) yline(0) xtitle("Period relative to treatment")
	graph export "$directorio/Figuras/did_event_`var'.pdf", replace	
	

	
	restore

}