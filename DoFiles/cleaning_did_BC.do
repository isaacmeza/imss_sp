
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: July. 11, 2022
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Cleaning of BC dataset - Bosh & Campos DoFile

*******************************************************************************/
*/
clear all
set mem 1000m
set matsize 6000
set maxvar 8000
set more off

use "Data Original\employers.dta", clear
merge 1:1 municipio year quarter using "Data Original\employees.dta", nogen


*MERGE WITH THE CODING FROM ENEU 
merge m:1 municipio using "Data Original\merge_ss_eneu_final.dta", nogen


*ADD OVER MUNICIPALITIES THAT ARE COMPRISED IN TWO SS CODES
collapse (sum) emp* pat*, by(cvemun year quarter)
drop if missing(cvemun)


*MERGE WITH MUNICIPALITIES PRESENT IN THE ENE-ENOE
merge m:1 cvemun using "Data Original\ENE_ENOE.dta", nogen
drop if missing(year)
drop if missing(quarter)


*MERGE WITH SEGURO POPULAR DATA
merge 1:1 cvemun year quarter using "Data Original\benef_SP_2002_2009.dta", keep(1 3) nogen 
drop mydate

replace ind = 100 if year>2009
replace ind = 0 if ind==.
replace ind = 0 if ind<1


*MERGE WITH THE OLD POPULATION DATA
merge m:1 cvemun using "Data Original\Population_Poverty.dta", keep(1 3) nogen
gen date = yq(year,quarter)
format date %tq

bys cve:egen mp1 = mean(pob2000)
replace pob2000 = mp1
bys cve:egen mp2 = mean(pob2005)
replace pob2005 = mp2
drop mp*
gen gt = ((pob2005/pob2000))^(1/24)
gen population = pob2000 if year>=1996	//assume a constant population growth rate//
sort cvemun year quarter
replace population = population[_n-1]*gt if cvemun[_n]==cvemun[_n-1] & (date>=149)
gen logpop = log(population)

*MERGE WITH MUNICIPALITIY CHARACTERISTICS FROM THE 2000 CENSUS
merge m:1 cvemun using "Data Original\caract_muni.dta", nogen keep(3)


*MERGE WITH GOVERNMENT
gen ent=int(cvemun/1000)
merge m:1 ent year quarter using "Data Original\gob.dta", nogen keepusing(gob)

encode gob, gen(government)
drop gob

drop if missing(cvemun)
drop if missing(date)

*Employees
gen e_t = log(emp_t)
gen e_50 = log(emp_size_1+emp_size_2_5+emp_size_6_50)
gen e_250 = log(emp_size_51_250)
gen e_1000m = log(emp_size_251_500+emp_size_501_1000+emp_size_1000)


*Employers
gen p_t = log(pat_t)
gen p_50 = log(pat_size_1+pat_size_2_5+pat_size_6_50) 
gen p_250 = log(pat_size_51_250)
gen p_1000m = log(pat_size_251_500+pat_size_501_1000+pat_size_1000)

drop ent
gen ent=int(cvemun/1000)


xtset cvemun date
***************
*** BALANCED PANEL DATA
**************
*WE USE A BALANCED PANEL DATASET
gen ones=(emp_t>1 & emp_t!=.)
bys cvemun: egen tx=total(ones)
tab tx

gen bal_48 = (tx==48 & p_t!=.) //since 2000, 10*4// //For which there is at least 1 employer in the municipality//


gen Tb=(ind>10)
sort cvemun year quarter
by cvemun : replace Tb=0 if Tb[_n]==1 & year==2002 & Tb[_n+1]==0 & Tb[_n+2]==0
by cvemun : replace Tb=1 if Tb[_n-1]==1



forvalues j=4 8 to 16 {
	quietly bys cvemun : gen Tb`j'=Tb[_n-`j'] 
	quietly bys cvemun : gen TbL`j'=Tb[_n+`j'] 
}

forval j=4 8 to 16 {
	quietly replace Tb`j'=0 if Tb`j'==.
	quietly replace TbL`j'=1 if TbL`j'==.
}

foreach var in Tb {
	gen yyy=0
	replace yyy=`var'[_n]+yyy[_n-1] if cvemun[_n]==cvemun[_n-1]
	gen `var'x=0
	replace `var'x=1 if yyy>=1 & yyy<=4
	drop yyy
}

forvalues j=4 8 to 16 {
	quietly bys cvemun:gen Tb`j'x=Tbx[_n-`j'] 
	quietly bys cvemun:gen TbL`j'x=Tbx[_n+`j'] 

	replace Tb`j'x=0 if Tb`j'x==.
	replace TbL`j'x=0 if TbL`j'x==.
}


foreach var in insured urban unm inf p50 age1 age2  gender ////
		yrschl industry1 industry2 industry3 industry4 industry5 industry6 industry7 ////
		industry8 industry9 industry10 industry11 industry12 industry13 industry14 industry15 {
gen x_t_`var'=`var'*date
}


********************************************************************************
***************** 				Event Study			 ***************************
********************************************************************************
sort cvemun year quarter
gen TT=1 if Tb==1 & Tb[_n-1]==0
replace TT=0 if TT==.

bys cvemun: egen tmax=max(TT*date)
gen xxx=date-tmax	//temporal variable//
replace xxx=-16 if xxx<-16
replace xxx=. if xxx>50
replace xxx=20 if xxx>20 & xxx!=.

gen date2=date*date
gen date3=date2*date


save  "Data Created\DiD_BC.dta", replace	//General Dataset saved//