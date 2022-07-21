
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	July. 11, 2022
* Last date of modification: July. 20, 2022
* Modifications: Added mortality outcomes
* Files used:     
		- 
* Files created:  

* Purpose: Bosch-Campos results replication

*******************************************************************************/
*/

use  "Data Created\DiD_BC.dta", clear	

*Period of implementation dummies
tab yyy, gen(yyy_p)
tab xxx, gen(xxx_p)

*Quarter of implementation
by cvemun : gen q_SP = mydate if xxx==0
by cvemun : egen q_imp = mean(q_SP)

	*Define lag variable previous to 4 years as 1
	replace TbL16x=1 if TbL16==0
	replace TL16x=1 if TL16==0
	
foreach var in /*p_t p1 p4 p7 p9 e_t e1 e4 e7 e9*/ total_d total_d_asist total_d_noasist total_d_imss_e total_d_imss total_d_sp total_d_cov_sp total_d_cov_isp total_d_sp_cov_sp total_d_imss_cov_sp { 
	
	*********** REGRESSIONS *************
	*************************************
	*************************************
	eststo clear

	* Bosch-Campos specification
	if strpos("`var'","total")==0 {
	eststo : xi : xtreg `var'_ TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16  log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 _Ix* [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var'_ if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
	}

	eststo : xi : xtreg `var' TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16  log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 _Ix* [aw=pob2000], fe robust cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	*State x Time FE
	eststo : xi : xtreg `var' TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
	eststo : xi : xtreg `var' TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate [aw=pob2000], fe robust cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
		
	eststo : xi : xtreg `var' TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate c.median_lum#i.mydate median_lum [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
	eststo : xi : xtreg `var' TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate c.median_lum#i.mydate median_lum [aw=pob2000], fe robust cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'
		
	eststo : xi : xtreg `var' TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate c.median_lum#i.mydate median_lum c.mydate#i.q_imp [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	
	eststo : xi : xtreg `var' TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate c.median_lum#i.mydate median_lum c.mydate#i.q_imp [aw=pob2000], fe robust cluster(cvemun)
		qui levelsof cvemun if e(sample)==1 
		local num_mun = `r(r)'
		su `var' if e(sample)==1
		estadd scalar DepVarMean = `r(mean)'
		estadd scalar num_mun = `num_mun'	

	esttab using "$directorio/Tables/reg_results/did_bc_`var'.csv", se r2 ${star} b(a2)  replace keep(Tb*) scalars("DepVarMean DepVarMean" "num_mun num_mun")	


	********************************************************************************
	********************************************************************************


	********** EVENT STUDIES ************
	*************************************
	*************************************

	xi : xtreg `var'_ xxx_p1-xxx_p15 xxx_p17-xxx_p37 _Ix* log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
	matrix event_bc_1 = J(37,5,.)	
	forvalues j = 1/37 {
		if `j'!=16 {
			matrix event_bc_1[`j',1] = _b[xxx_p`j']
			matrix event_bc_1[`j',2] = _b[xxx_p`j'] + invnormal(0.975)*_se[xxx_p`j']
			matrix event_bc_1[`j',3] = _b[xxx_p`j'] - invnormal(0.975)*_se[xxx_p`j']
			matrix event_bc_1[`j',4] = _b[xxx_p`j'] + invnormal(0.95)*_se[xxx_p`j']
			matrix event_bc_1[`j',5] = _b[xxx_p`j'] - invnormal(0.95)*_se[xxx_p`j']		
		}
	}


	xi : xtreg `var' xxx_p1-xxx_p15 xxx_p17-xxx_p37 _Ix* log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 c.median_lum#i.mydate median_lum [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
	matrix event_bc_2 = J(37,5,.)	
	forvalues j = 1/37 {
		if `j'!=16 {
			matrix event_bc_2[`j',1] = _b[xxx_p`j']
			matrix event_bc_2[`j',2] = _b[xxx_p`j'] + invnormal(0.975)*_se[xxx_p`j']
			matrix event_bc_2[`j',3] = _b[xxx_p`j'] - invnormal(0.975)*_se[xxx_p`j']
			matrix event_bc_2[`j',4] = _b[xxx_p`j'] + invnormal(0.95)*_se[xxx_p`j']
			matrix event_bc_2[`j',5] = _b[xxx_p`j'] - invnormal(0.95)*_se[xxx_p`j']		
		}
	}
		
	xi : xtreg `var' xxx_p1-xxx_p15 xxx_p17-xxx_p37 _Ix* log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 c.median_lum#i.mydate median_lum [aw=pob2000], fe robust cluster(cvemun)
	matrix event_bc_3 = J(37,5,.)	
	forvalues j = 1/37 {
		if `j'!=16 {
			matrix event_bc_3[`j',1] = _b[xxx_p`j']
			matrix event_bc_3[`j',2] = _b[xxx_p`j'] + invnormal(0.975)*_se[xxx_p`j']
			matrix event_bc_3[`j',3] = _b[xxx_p`j'] - invnormal(0.975)*_se[xxx_p`j']
			matrix event_bc_3[`j',4] = _b[xxx_p`j'] + invnormal(0.95)*_se[xxx_p`j']
			matrix event_bc_3[`j',5] = _b[xxx_p`j'] - invnormal(0.95)*_se[xxx_p`j']		
		}
	}	

	preserve
	
	clear 
	forvalues i = 1/3 {
		svmat event_bc_`i'
	}
	save  "_aux\event_bc_did_`var'.dta", replace		
	********************************************************************************
	********************************************************************************
	
	use  "_aux\event_bc_did_`var'.dta", clear	

	********** EVENT STUDIES ************
	*************************************
	*************************************

	gen period = _n - 17 if inrange(_n,1,37)

	forvalues i = 1/3 { 
		twoway (scatter event_bc_`i'1 period, color(black) lcolor(gs10%50) msize(medium) connect(line)) /// 
				(rcap event_bc_`i'2 event_bc_`i'3 period, color(navy%50)) /// 
				(rcap event_bc_`i'4 event_bc_`i'5 period, color(navy)) ///
				, legend(off) xline(-1) yline(0) xtitle("Period relative to treatment")
			graph export "$directorio/Figuras/did_event_bc_`i'_`var'.pdf", replace	
	}
	
	restore


}