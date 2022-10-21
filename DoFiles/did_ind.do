
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

* Purpose: DiD with IMSS data. Individual regressions to identify HTE using Chaisemartin and D'Haultfoeuille

*******************************************************************************/
*/ 

* Merge DiD_DB with IMSS panel
use "$directorio/Data Created/panel_trabajadores.dta", clear

keep if year<=2011
merge m:1 cvemun date using "Data Created\DiD_DB.dta", keep(1 3)
keep informal size_cierre sal_cierre idnss high_labor_att date ent cvemun median_lum sexo lgpop x_t_* SP_b


gen date2 = date*date
gen date3 = date2*date

gen median_lum2 = median_lum*median_lum
gen median_lum3 = median_lum2*median_lum

*Conditioning variables
su sal_cierre, d
gen high_wage = sal_cierre >= `r(p50)' if !missing(sal_cierre)

gen size = .
replace size = 1 if inlist(size_cierre, 1)



********** DiD  Chaisemartin and D'Haultfoeuille ************
*************************************************************
*************************************************************

local breps = 10

matrix dd = J(6,3,.)
matrix pt = J(6,1,.)

******************************** IMSS ******************************************

local j = 1

			did_multiplegt informal cvemun date SP_b, robust_dynamic average_effect dynamic(16) placebo(8) jointtestplacebo covariances breps(`breps')  controls(lgpop x_t_* median_lum* sexo) cluster(cvemun)
			
			matrix dd[`j',1] =   e(effect_average)
			matrix dd[`j',2] =   e(effect_average) - invnormal(.975)*e(se_effect_average)
			matrix dd[`j',3] =   e(effect_average) + invnormal(.975)*e(se_effect_average) 
			
			matrix pt[`j',1] =   e(p_jointplacebo)
			
			local j = `j' + 1

			did_multiplegt informal cvemun date SP_b if size==1, robust_dynamic average_effect dynamic(16) placebo(8) jointtestplacebo covariances breps(`breps')  controls(lgpop x_t_* median_lum* sexo) cluster(cvemun)
			
			matrix dd[`j',1] =   e(effect_average)
			matrix dd[`j',2] =   e(effect_average) - invnormal(.975)*e(se_effect_average)
			matrix dd[`j',3] =   e(effect_average) + invnormal(.975)*e(se_effect_average) 
			
			matrix pt[`j',1] =   e(p_jointplacebo)
			
			local j = `j' + 1

			
foreach var in high_wage high_labor_att { 	
					
			did_multiplegt informal cvemun date SP_b if `var'==0, robust_dynamic average_effect dynamic(16) placebo(8) jointtestplacebo covariances breps(`breps')  controls(lgpop x_t_* median_lum* sexo) cluster(cvemun)
			
			matrix dd[`j',1] =   e(effect_average)
			matrix dd[`j',2] =   e(effect_average) - invnormal(.975)*e(se_effect_average)
			matrix dd[`j',3] =   e(effect_average) + invnormal(.975)*e(se_effect_average) 
			
			matrix pt[`j',1] =   e(p_jointplacebo)
			
			local j = `j' + 1
			
			did_multiplegt informal cvemun date SP_b if `var'==1, robust_dynamic average_effect dynamic(16) placebo(8) jointtestplacebo covariances breps(`breps')  controls(lgpop x_t_* median_lum* sexo) cluster(cvemun)
			
			matrix dd[`j',1] =   e(effect_average)
			matrix dd[`j',2] =   e(effect_average) - invnormal(.975)*e(se_effect_average)
			matrix dd[`j',3] =   e(effect_average) + invnormal(.975)*e(se_effect_average) 
			
			matrix pt[`j',1] =   e(p_jointplacebo)
			
			local j = `j' + 1			
		 }
	


mat rownames dd =  "All"  "Self-employed" "Low-wage" "High-wage" "Low labour atachment" "High labor atachment" 
  
mat rownames pt =  "All"  "Self-employed" "Low-wage" "High-wage" "Low labour atachment" "High labor atachment" 
	
	coefplot (matrix(dd[,1]), offset(0.06) ci((dd[,2] dd[,3])) msize(large) ciopts(lcolor(gs4))) , ///
	legend(order(2 "DiD Effect") pos(6) rows(1))  xline(0)  graphregion(color(white)) 
graph export "$directorio/Figuras/did_ind.pdf", replace
	

clear 
svmat dd 
svmat pt
save "$directorio/_aux/did_ind.dta", replace

	
				