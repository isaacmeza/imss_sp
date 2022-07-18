
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

eststo clear
foreach var in SP_BC SP_b {

	tab `var'_p, gen(`var'_p)

	*Condition on balanced municipalities
	eststo : xi : xtreg e9 i.ent*date i.ent*date2 i.ent*date3 i.date `var'_F16x `var'_F12x `var'_F8x `var'x `var'_L4x `var'_L8x `var'_L12x `var'_L16  lgpop x_t_* [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su e9 if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
	eststo : xi : reghdfe e9 i.ent*date i.ent*date2 i.ent*date3 i.date `var'_F16x `var'_F12x `var'_F8x `var'x `var'_L4x `var'_L8x `var'_L12x `var'_L16  lgpop x_t_* [aw=pob2000] if bal_48==1, absorb(cvemun) cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su e9 if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'		
	eststo : xi : reghdfe e9 i.ent*i.date `var'_F16x `var'_F12x `var'_F8x `var'x `var'_L4x `var'_L8x `var'_L12x `var'_L16  lgpop x_t_* [aw=pob2000] if bal_48==1, absorb(cvemun) cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su e9 if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
	eststo : xi : reghdfe e9 i.ent*i.date c.median_lum#i.date median_lum `var'_F16x `var'_F12x `var'_F8x `var'x `var'_L4x `var'_L8x `var'_L12x `var'_L16  lgpop x_t_* [aw=pob2000] if bal_48==1, absorb(cvemun) cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su e9 if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
	eststo : xi : reghdfe e9 c.date#i.q_imp i.ent*i.date c.median_lum#i.date median_lum `var'_F16x `var'_F12x `var'_F8x `var'x `var'_L4x `var'_L8x `var'_L12x `var'_L16  lgpop x_t_* [aw=pob2000] if bal_48==1, absorb(cvemun) cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su e9 if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
	
	xi : reghdfe e9 i.ent*i.date c.median_lum#i.date median_lum `var'_p1-`var'_p15 `var'_p17-`var'_p37 lgpop x_t_* [aw=pob2000] if bal_48==1,  absorb(cvemun) cluster(cvemun)
	matrix event_`var'_c = J(37,5,.)	
	forvalues j = 1/37 {
		if `j'!=16 {
			matrix event_`var'_c[`j',1] = _b[`var'_p`j']
			matrix event_`var'_c[`j',2] = _b[`var'_p`j'] + invnormal(0.975)*_se[`var'_p`j']
			matrix event_`var'_c[`j',3] = _b[`var'_p`j'] - invnormal(0.975)*_se[`var'_p`j']
			matrix event_`var'_c[`j',4] = _b[`var'_p`j'] + invnormal(0.95)*_se[`var'_p`j']
			matrix event_`var'_c[`j',5] = _b[`var'_p`j'] - invnormal(0.95)*_se[`var'_p`j']		
		}
	}
	
	*All municipalities
	eststo : xi : reghdfe e9 i.ent*i.date `var'_F16x `var'_F12x `var'_F8x `var'x `var'_L4x `var'_L8x `var'_L12x `var'_L16  lgpop x_t_* [aw=pob2000], absorb(cvemun) cluster(cvemun)	
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su e9 if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
	eststo : xi : reghdfe e9 i.ent*i.date c.median_lum#i.date median_lum `var'_F16x `var'_F12x `var'_F8x `var'x `var'_L4x `var'_L8x `var'_L12x `var'_L16  lgpop x_t_* [aw=pob2000], absorb(cvemun) cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su e9 if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
	eststo : xi : reghdfe e9 c.date#i.q_imp i.ent*i.date c.median_lum#i.date median_lum `var'_F16x `var'_F12x `var'_F8x `var'x `var'_L4x `var'_L8x `var'_L12x `var'_L16  lgpop x_t_* [aw=pob2000], absorb(cvemun) cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su e9 if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
	
	xi : reghdfe e9 i.ent*i.date c.median_lum#i.date median_lum `var'_p1-`var'_p15 `var'_p17-`var'_p37 lgpop x_t_* [aw=pob2000],  absorb(cvemun) cluster(cvemun)
	matrix event_`var' = J(37,5,.)	
	forvalues j = 1/37 {
		if `j'!=16 {
			matrix event_`var'[`j',1] = _b[`var'_p`j']
			matrix event_`var'[`j',2] = _b[`var'_p`j'] + invnormal(0.975)*_se[`var'_p`j']
			matrix event_`var'[`j',3] = _b[`var'_p`j'] - invnormal(0.975)*_se[`var'_p`j']
			matrix event_`var'[`j',4] = _b[`var'_p`j'] + invnormal(0.95)*_se[`var'_p`j']
			matrix event_`var'[`j',5] = _b[`var'_p`j'] - invnormal(0.95)*_se[`var'_p`j']		
		}
	}
}

esttab using "$directorio/Tables/reg_results/did_reg.csv", se r2 ${star} b(a2)  replace keep(SP*) scalars("DepVarMean DepVarMean" "num_mun num_mun")	


********************************************************************************
********************************************************************************


********** EVENT STUDIES ************
*************************************
*************************************

gen period = _n - 17 if inrange(_n,1,37)
foreach var in SP_BC SP_b {
	cap svmat event_`var'_c
		twoway (scatter event_`var'_c1 period, color(black) lcolor(gs10%50) msize(medium) connect(line)) /// 
			(rcap event_`var'_c2 event_`var'_c3 period, color(navy%50)) /// 
			(rcap event_`var'_c4 event_`var'_c5 period, color(navy)) ///
			, legend(off) xline(-1) yline(0) xtitle("Period relative to treatment")
		graph export "$directorio/Figuras/did_event_`var'_c.pdf", replace	
		
	cap svmat event_`var'
		twoway (scatter event_`var'1 period, color(black) lcolor(gs10%50) msize(medium) connect(line)) /// 
			(rcap event_`var'2 event_`var'3 period, color(navy%50)) /// 
			(rcap event_`var'4 event_`var'5 period, color(navy)) ///
			, legend(off) xline(-1) yline(0) xtitle("Period relative to treatment")
		graph export "$directorio/Figuras/did_event_`var'.pdf", replace	
}


keep period event_*
drop if missing(period)
save  "_aux\event_did.dta", replace	