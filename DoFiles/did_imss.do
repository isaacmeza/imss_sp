
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
merge m:1 cvemun date using "Data Created\DiD_DB.dta"

drop if year>=2012

*********** REGRESSIONS *************
*************************************
*************************************
eststo clear 
eststo : xi : reghdfe formal i.ent*i.date c.median_lum#i.date median_lum SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16  lgpop x_t_* , absorb(cvemun) cluster(cvemun)

eststo : xi : reghdfe formal i.sexo edad_final i.ent*i.date c.median_lum#i.date median_lum SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16  lgpop x_t_* , absorb(cvemun) cluster(cvemun)



esttab using "$directorio/Tables/reg_results/did_imss.csv", se r2 ${star} b(a2)  replace 


