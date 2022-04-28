clear all
set matsize 11000
set maxvar 18000
set more off

cd "C:\Users\isaac\Downloads\114886-V1\" ///CHANGE THIS TO YOUR DIRECTORE STRUCTURE

*Figure 1*
use  "Data Created\Event_Study.dta", clear


collapse (sum) emp_t pat_t , by(mydate)

replace emp_t=emp_t/1000000
replace pat_t=pat_t/1000000




label var emp_t "Employees (in Millions)"
label var pat_t "Employers (in Millions)"

twoway (line emp_t mydate, sort lwidth(medthick) lpattern(dash)  xtitle("Year - Quarter")) (line pat_t mydate, lwidth(medthick) lpattern(solid) yaxis(2))
graph export "figures\Fig1.eps", fontface("Times New Roman") replace

*Figure 2*
clear all
use  "Data Created\Event_Study.dta", clear

gen M=1
bys mydate: egen smun= sum(Tb)
bys mydate: egen spob=sum(ind) 

collapse smun spob  , by (mydate)
replace spob=0 if spob==.
replace smun=smun/1392
replace spob=spob/97480000
label var   smun "% Municipalities"
label var   spob  "SP-Take up rate"
twoway(line smun  mydate if mydate<200,lwidth(medthick)) (line spob mydate if mydate<200, lwidth(medthick) yaxis(2) xtitle("Year-Quater"))
graph export "figures\Fig2.eps", fontface("Times New Roman") replace

*Figure 3*
clear all
use  "Data Original\affiliated.dta"
gen others= ISSSTE+ SEDENA+ PEMEX+ SEMAR
label var   SeguroPopular "Seguro Popular"
label var   IMSS "IMSS"
label var   others  "Others"

line Seguro IMSS others year, lwidth(medthick medthick medthick) symbol(triangle) ytitle("Afiliated to Health Services (in Millions)") xtitle("Year")
graph export "figures\Fig3.eps", fontface("Times New Roman") replace


*Figure 4 and 5
clear all
use  "Data Created\Event_Study.dta", clear

collapse p* e* s*, by(xxx)

foreach var1 in p  {

foreach var in `var1'_t `var1'1 `var1'2 `var1'3 `var1'4   {
twoway (line s_b_`var' xxx, sort lwidth(medthick) lpattern(solid))  ////
	 (connected s_se1_`var' xxx, sort lwidth(medthick) lpattern(dash) symbol(triangle))  ////
	 (connected s_se2_`var' xxx, sort lwidth(medthick) lpattern(dash) symbol(triangle)),  ////
	ytitle(Change in Formal Emp in %) xtitle(Period Relative to Treatment) ////
	ylabel(-0.08(0.02)0.08) xlabel(-13(2)16) xline(0) yline(0) ////
	legend(off) ////
      graphregion(fcolor(white)) 
graph display Graph, scheme(s2mono)

*graph export "figures\Fig4_`var'.eps", fontface("Times New Roman") replace
}

foreach var in `var1'7 {
twoway (line s_b_`var' xxx, sort lwidth(medthick) lpattern(solid))  ////
	 (connected s_se1_`var' xxx, sort lwidth(medthick) lpattern(dash) symbol(triangle))  ////
	 (connected s_se2_`var' xxx, sort lwidth(medthick) lpattern(dash) symbol(triangle)),  ////
	ytitle(Change in Formal Emp in %) xtitle(Period Relative to Treatment) ////
	ylabel(-0.3(0.05)0.3) xlabel(-13(2)16) xline(0) yline(0) ////
	legend(off) ////
      graphregion(fcolor(white)) 
graph display Graph, scheme(s2mono)

*graph export "figures\Fig4_`var'.eps", fontface("Times New Roman") replace
}


}



foreach var1 in e  {

foreach var in `var1'_t `var1'1 `var1'2 `var1'3 `var1'4   {
twoway (line s_b_`var' xxx, sort lwidth(medthick) lpattern(solid))  ////
	 (connected s_se1_`var' xxx, sort lwidth(medthick) lpattern(dash) symbol(triangle))  ////
	 (connected s_se2_`var' xxx, sort lwidth(medthick) lpattern(dash) symbol(triangle)),  ////
	ytitle(Change in Formal Emp in %) xtitle(Period Relative to Treatment) ////
	ylabel(-0.08(0.02)0.08) xlabel(-13(2)16) xline(0) yline(0) ////
	legend(off) ////
      graphregion(fcolor(white)) 
graph display Graph, scheme(s2mono)

graph export "figures\Fig5_`var'.eps", fontface("Times New Roman") replace
}
foreach var in  `var1'7 {
twoway (line s_b_`var' xxx, sort lwidth(medthick) lpattern(solid))  ////
	 (connected s_se1_`var' xxx, sort lwidth(medthick) lpattern(dash) symbol(triangle))  ////
	 (connected s_se2_`var' xxx, sort lwidth(medthick) lpattern(dash) symbol(triangle)),  ////
	ytitle(Change in Formal Emp in %) xtitle(Period Relative to Treatment) ////
	ylabel(-0.30(0.05)0.30) xlabel(-13(2)16) xline(0) yline(0) ////
	legend(off) ////
      graphregion(fcolor(white)) 
graph display Graph, scheme(s2mono)

graph export "figures\Fig5_`var'.eps", fontface("Times New Roman") replace
}



}
