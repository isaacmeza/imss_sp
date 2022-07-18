
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	July. 11, 2022
* Last date of modification: 
* Modifications: 
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

*********** REGRESSIONS *************
*************************************
*************************************
eststo clear

preserve
*Define lag variable previous to 3 years as 1
replace TbL12x=1 if TbL12==0
replace TL12x=1 if TL12==0

* Bosch-Campos specification
eststo : xi : xtreg e9_ TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16  log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 _Ix* [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9_ if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
eststo : xi : xtreg e9 TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16  log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 _Ix* [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9 if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'		
eststo : xi : xtreg e9 TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16  log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 _Ix* [aw=pob2000], fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9 if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
	
*State x Time FE
eststo : xi : xtreg e9_ TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9_ if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
eststo : xi : xtreg e9 TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9 if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
eststo : xi : xtreg e9 TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate c.median_lum#i.mydate median_lum [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9 if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
eststo : xi : xtreg e9 TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate c.median_lum#i.mydate median_lum c.mydate#i.q_imp [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9 if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
eststo : xi : xtreg e9 TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate [aw=pob2000], fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9 if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
eststo : xi : xtreg e9 TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate c.median_lum#i.mydate median_lum [aw=pob2000], fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9 if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
eststo : xi : xtreg e9 TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate c.median_lum#i.mydate median_lum c.mydate#i.q_imp [aw=pob2000], fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9 if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
restore

*Define lag variable previous to 4 years as 1
replace TbL16x=1 if TbL16==0
replace TL16x=1 if TL16==0

* Bosch-Campos specification
eststo : xi : xtreg e9_ TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16  log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 _Ix* [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9_ if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
eststo : xi : xtreg e9 TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16  log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 _Ix* [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9 if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
eststo : xi : xtreg e9 TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16  log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 _Ix* [aw=pob2000], fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9 if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
	
*State x Time FE
eststo : xi : xtreg e9_ TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9_ if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
eststo : xi : xtreg e9 TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9 if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
eststo : xi : xtreg e9 TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate c.median_lum#i.mydate median_lum [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9 if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
eststo : xi : xtreg e9 TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate c.median_lum#i.mydate median_lum c.mydate#i.q_imp [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9 if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
eststo : xi : xtreg e9 TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate [aw=pob2000], fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9 if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
eststo : xi : xtreg e9 TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate c.median_lum#i.mydate median_lum [aw=pob2000], fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9 if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	
eststo : xi : xtreg e9 TbL16x TbL12x TbL8x Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate c.median_lum#i.mydate median_lum c.mydate#i.q_imp [aw=pob2000], fe robust cluster(cvemun)
	qui levelsof cvemun if e(sample)==1 
	local num_mun = `r(r)'
	su e9 if e(sample)==1
	estadd scalar DepVarMean = `r(mean)'
	estadd scalar num_mun = `num_mun'	

esttab using "$directorio/Tables/reg_results/did_bc.csv", se r2 ${star} b(a2)  replace keep(Tb*) scalars("DepVarMean DepVarMean" "num_mun num_mun")	


********************************************************************************
********************************************************************************


********** EVENT STUDIES ************
*************************************
*************************************

xi : xtreg e9_ yyy_p1-yyy_p11 yyy_p13-yyy_p29 _Ix* log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
matrix event_bc_1 = J(37,5,.)	
forvalues j = 1/29 {
	if `j'!=12 {
		matrix event_bc_1[`=`j'+4',1] = _b[yyy_p`j']
		matrix event_bc_1[`=`j'+4',2] = _b[yyy_p`j'] + invnormal(0.975)*_se[yyy_p`j']
		matrix event_bc_1[`=`j'+4',3] = _b[yyy_p`j'] - invnormal(0.975)*_se[yyy_p`j']
		matrix event_bc_1[`=`j'+4',4] = _b[yyy_p`j'] + invnormal(0.95)*_se[yyy_p`j']
		matrix event_bc_1[`=`j'+4',5] = _b[yyy_p`j'] - invnormal(0.95)*_se[yyy_p`j']		
	}
}

xi : xtreg e9_ xxx_p1-xxx_p15 xxx_p17-xxx_p37 _Ix* log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
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


xi : xtreg e9 xxx_p1-xxx_p15 xxx_p17-xxx_p37 _Ix* log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 c.median_lum#i.mydate median_lum [aw=pob2000] if bal_48==1, fe robust cluster(cvemun)
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
	
xi : xtreg e9 xxx_p1-xxx_p15 xxx_p17-xxx_p37 _Ix* log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 c.median_lum#i.mydate median_lum [aw=pob2000], fe robust cluster(cvemun)
matrix event_bc_4 = J(37,5,.)	
forvalues j = 1/37 {
	if `j'!=16 {
		matrix event_bc_4[`j',1] = _b[xxx_p`j']
		matrix event_bc_4[`j',2] = _b[xxx_p`j'] + invnormal(0.975)*_se[xxx_p`j']
		matrix event_bc_4[`j',3] = _b[xxx_p`j'] - invnormal(0.975)*_se[xxx_p`j']
		matrix event_bc_4[`j',4] = _b[xxx_p`j'] + invnormal(0.95)*_se[xxx_p`j']
		matrix event_bc_4[`j',5] = _b[xxx_p`j'] - invnormal(0.95)*_se[xxx_p`j']		
	}
}	

clear 
forvalues i=1/4 {
	svmat event_bc_`i'
}
save  "_aux\event_bc_did.dta", replace		
********************************************************************************
********************************************************************************


