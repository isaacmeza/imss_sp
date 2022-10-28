
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: October. 29, 2022
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: DiD with IMSS data. Individual regressions to identify HTE with felxible regression and individual FE

*******************************************************************************/
*/

* Merge DiD_DB with IMSS panel
use "$directorio/Data Created/panel_trabajadores.dta", clear

keep if year<=2011
merge m:1 cvemun date using "Data Created\DiD_DB.dta", keep(1 3)
keep informal size_cierre sal_cierre idnss high_labor_att date ent cvemun median_lum sexo lgpop x_t_* SP_b_p SP_b_F16x SP_b_F12x SP_b_F8x SP_bx SP_b_L4x SP_b_L8x SP_b_L12x SP_b_L16


*Quarter of implementation
bysort cvemun : gen q_SP = date if SP_b_p==0
bysort cvemun : egen q_imp = mean(q_SP)

gen date2 = date*date
gen date3 = date2*date

gen median_lum2 = median_lum*median_lum
gen median_lum3 = median_lum2*median_lum

*Conditioning variables
su sal_cierre, d
gen high_wage = sal_cierre >= `r(p50)' if !missing(sal_cierre)

gen size = .
replace size = 1 if inlist(size_cierre, 1)
replace size = 2 if inlist(size_cierre, 2,3)
replace size = 3 if inlist(size_cierre, 4)
replace size = 4 if inlist(size_cierre, 5,6,7)

gen pre = 0
replace pre = 1 if (SP_b_F16x==1 | SP_b_F12x==1 | SP_b_F8x==1)
gen post_dd = 0
replace post_dd = 1 if (SP_bx==1 | SP_b_L4x==1 | SP_b_L8x==1 | SP_b_L12x==1 | SP_b_L16==1)
********************************************************************************


matrix post_dd = J(6,3,.)
matrix pre = J(6,1,.)

******************************** IMSS ******************************************

local j = 1

			xi : xtreg informal i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo c.date#i.q_imp pre post_dd, fe cluster(idnss)
			
			matrix post_dd[`j',1] =   _b[post_dd]
			matrix post_dd[`j',2] =   _b[post_dd] - invnormal(.975)*_se[post_dd]
			matrix post_dd[`j',3] =   _b[post_dd] + invnormal(.975)*_se[post_dd]
			
			test pre
			matrix pre[`j',1] =  r(p)
			
			local j = `j' + 1

			xi : xtreg informal i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo c.date#i.q_imp pre post_dd if size==1, fe cluster(idnss)
			
			matrix post_dd[`j',1] =   _b[post_dd]
			matrix post_dd[`j',2] =   _b[post_dd] - invnormal(.975)*_se[post_dd]
			matrix post_dd[`j',3] =   _b[post_dd] + invnormal(.975)*_se[post_dd]
			
			test pre
			matrix pre[`j',1] =  r(p)
			
			local j = `j' + 1

			
foreach var in high_wage high_labor_att { 	
					
			xi : xtreg informal i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo c.date#i.q_imp pre post_dd if `var'==0, fe cluster(idnss)
			
			matrix post_dd[`j',1] =   _b[post_dd]
			matrix post_dd[`j',2] =   _b[post_dd] - invnormal(.975)*_se[post_dd]
			matrix post_dd[`j',3] =   _b[post_dd] + invnormal(.975)*_se[post_dd]
			
			test pre
			matrix pre[`j',1] =  r(p)
			
			local j = `j' + 1
			
			xi : xtreg informal i.ent*date i.ent*date2 i.ent*date3 i.date lgpop x_t_* median_lum* sexo c.date#i.q_imp pre post_dd if `var'==1, fe cluster(idnss)
			
			matrix post_dd[`j',1] =   _b[post_dd]
			matrix post_dd[`j',2] =   _b[post_dd] - invnormal(.975)*_se[post_dd]
			matrix post_dd[`j',3] =   _b[post_dd] + invnormal(.975)*_se[post_dd]
			
			test pre
			matrix pre[`j',1] =  r(p)
			
			local j = `j' + 1			
		 }
		 
	


mat rownames dd =  "All"  "Self-employed" "Low-wage" "High-wage" "Low labour atachment" "High labor atachment" 
  
mat rownames pt =  "All"  "Self-employed" "Low-wage" "High-wage" "Low labour atachment" "High labor atachment" 
	
	coefplot (matrix(dd[,1]), offset(0.06) ci((dd[,2] dd[,3])) msize(large) ciopts(lcolor(gs4))) , ///
	legend(order(2 "DiD Effect") pos(6) rows(1))  xline(0)  graphregion(color(white)) 
graph export "$directorio/Figuras/did_imss.pdf", replace
	

clear 
svmat dd 
svmat pt
save "$directorio/_aux/did_imss.dta", replace

		
		 