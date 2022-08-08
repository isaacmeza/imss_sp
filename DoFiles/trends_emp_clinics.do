
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	Aug. 04, 2022
* Last date of modification: 
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Employment trends by number of clinics
*******************************************************************************/
*/



use  "Data Created\DiD_DB.dta", clear	
merge 1:1 cvemun date using "Data Created\clues.dta", keep(1 3) nogen

*Partition by number of clinics
xtile xtiles_tc = total_clues, nq(3)

gen pat_ = exp(p_t_)
gen pat_1 = exp(p_1_)
gen emp_ = exp(e_t_)
gen emp_1 = exp(e_1_)


collapse (sum) pat_ pat_1 emp_ emp_1 patrones afiliados_imss afiliados_imss1 if bal_48_imss==1, by(xtiles_tc SP_b_p)
drop if missing(xtile) | missing(SP_b_p)
drop if inlist(SP_b_p,-16,24)

foreach var of varlist pat_ pat_1 emp_ emp_1 patrones afiliados_imss afiliados_imss1 {
	replace `var' = log(`var')
}

xtset xtiles_tc SP_b_p 


*Self-employment
twoway (tsline afiliados_imss1 if xtile==1, lpattern(solid) lcolor(navy)) ///
	(tsline afiliados_imss1 if xtile==2, lpattern(solid) lcolor(green)) ///
	(tsline afiliados_imss1 if xtile==3, lpattern(solid) lcolor(maroon)) ///
	, xline(0,lpattern(dash) lcolor(black%75)) xtitle("Quarter relative to SP implementation") ///
	ytitle("Log-employment (Firm size = 1)") ///
	legend(order( 1 "1st tercile" 2 "2nd tercile" 3 "3rd tercile")  rows(1) pos(6))
graph export "$directorio/Figuras/trends_clinics_self.pdf", replace	

*Total-employment	
twoway (tsline patrones if xtile==1, lpattern(solid) lcolor(navy)) ///
	(tsline patrones if xtile==2, lpattern(solid) lcolor(green)) ///
	(tsline patrones if xtile==3, lpattern(solid) lcolor(maroon)) ///
	(tsline afiliados_imss if xtile==1, yaxis(2) lpattern(dash) lcolor(navy)) ///
	(tsline afiliados_imss if xtile==2, yaxis(2) lpattern(dash) lcolor(dkgreen)) ///
	(tsline afiliados_imss if xtile==3, yaxis(2) lpattern(dash) lcolor(maroon)) ///
	, xline(0,lpattern(dash) lcolor(black%75)) xtitle("Quarter relative to SP implementation") ///
	ytitle("Log-employers", axis(1)) ytitle("Log-employees", axis(2)) ///
	legend(order( 1 "Employers - 1st tercile" 2 "2nd tercile" 3 "3rd tercile" ///
					4 "Employees - 1st tercile" 5 "2nd tercile" 6 "3rd tercile") rows(2) pos(6))
graph export "$directorio/Figuras/trends_clinics_total.pdf", replace		
	
	