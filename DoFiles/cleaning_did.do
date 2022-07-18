
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

* Purpose: Cleaning of dataset for DiD

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
merge 1:1 cvemun year quarter using "Data Original\benef_SP_2002_2009.dta", nogen 
drop mydate
merge 1:1 cvemun year quarter using "Data Created\beneficiarios_sp_2004_2019.dta", nogen

*Variable of beneficiaries
gen ind_old = ind
replace ind = ind_H + ind_M if missing(ind)

replace ind_old = 100 if year>2009 // This establishes that by the end of 2009 all municipalities have implemented SP.
replace ind_old = 0 if ind_old==.


*MERGE WITH DATA FROM POPULATION 
merge m:1 cvemun year using "Data Created\population.dta", nogen 
replace quarter = 4 if missing(quarter)
 
gen date = yq(year,quarter)
drop if missing(date)
format date %tq

gen pob2000_ = pobtot if year==2000
bysort cvemun : egen pob2000 = mean(pob2000_) 
drop pob2000_
gen logpop = log(pobtot+1)
replace logpop = . if quarter!=4

sort cvemun date
by cvemun : ipolate logpop date, gen(lgpop) epolate
drop logpop

drop if year==2020


*MERGE WITH MUNICIPALITIY CHARACTERISTICS FROM THE 2000 CENSUS
merge m:1 cvemun using "Data Original\caract_muni.dta", nogen keep(3)


*MERGE WITH GOVERNMENT
gen ent=int(cvemun/1000)
merge m:1 ent year quarter using "Data Original\gob.dta", nogen keepusing(gob)

encode gob, gen(government)
drop gob


*PANEL DATASET
drop if missing(cvemun)
drop if missing(date)
sort cvemun year quarter
xtset cvemun date
*Balance panel
gen sample1 = 1
tsfill
gen sample2 = 1
tsfill, full
gen sample3 = 1


*MERGE WITH LUMINOSITY DATA
replace year = yofd(dofq(date))
replace quarter = quarter(dofq(date))
merge 1:1 cvemun year quarter using "$directorio\Data Created\luminosity.dta", nogen keep(1 3) keepusing(median_lum)


foreach var of varlist ind lgpop {
	replace `var' = . if `var'==0
	by cvemun : ipolate `var' date, gen(`var'_)
	drop `var'
	rename `var'_ `var'
	replace `var' = 0 if missing(`var') 
}


*Filter
	*Drop municipalities with 0 population
sort cvemun date
by cvemun : egen flag = max(lgpop)
drop if flag==0
drop flag

*-------------------------------------------------------------------------------

*DEFINITION OF DEPENDENT VARIABLES

*Employees
gen e_t = log(emp_t + 1)
gen e1 = log(emp_size_1 + 1)
gen e2 = log(emp_size_2_5 + 1)
gen e3 = log(emp_size_6_50 + 1)
gen e4 = log(emp_size_51_250 + 1)
gen e5 = log(emp_size_251_500 + 1)
gen e6 = log(emp_size_501_1000+emp_size_1000 + 1)
gen e7 = log(emp_size_251_500+emp_size_501_1000+emp_size_1000 + 1)
gen e8 = log(emp_size_1+emp_size_2_5+emp_size_6_50+emp_size_51_250 + 1)
gen e9 = log(emp_size_1+emp_size_2_5+emp_size_6_50 + 1)

*Employers
gen p_t = log(pat_t + 1)
gen p1 = log(pat_size_1 + 1)
gen p2 = log(pat_size_2_5 + 1)
gen p3 = log(pat_size_6_50 + 1)
gen p4 = log(pat_size_51_250 + 1)
gen p5 = log(pat_size_251_500 + 1)
gen p6 = log(pat_size_501_1000+pat_size_1000 + 1)
gen p7 = log(pat_size_251_500+pat_size_501_1000+pat_size_1000 + 1)
gen p8 = log(pat_size_1+pat_size_2_5+pat_size_6_50+pat_size_51_250 + 1)
gen p9 = log(pat_size_1+pat_size_2_5+pat_size_6_50 + 1) 


*Identify municipalities that exists in all quarters from 2000-2010
gen ones = (emp_t>1 & emp_t!=.)
bysort cvemun : egen txx = total(ones)
gen bal_48 = (txx==48 & p_t!=.) //since 2000, 10*4// //For which there is at least 1 employer in the municipality//

*-------------------------------------------------------------------------------

*IDENTIFY TREATMENT IN MUNICIPALITIES AS xx OR MORE INDIVIDUALS ENROLLED IN SP

*Definition of Bosch-Campos
replace ind_old = 0 if ind_old<1
gen SP_BC = (ind_old>10)

*Definition by intensity
gen SP = (ind>1)
gen SP_b = (ind>10)
gen SP_c = (ind>100)
gen SP_takeup = ind/exp(lgpop)

sort cvemun year quarter

foreach var of varlist SP_BC SP SP_b SP_c {
	*Ever treated 
	by cvemun : replace `var' = 0 if `var'[_n]==1 & year==2002 & `var'[_n+1]==0 & `var'[_n+2]==0
	by cvemun : replace `var' = 1 if `var'[_n-1]==1
	
	*Period of treatment
	by cvemun : gen TT = 1 if `var'==1 & `var'[_n-1]==0
	replace TT = 0 if missing(TT)

	by cvemun : egen tmax = max(TT*date)
	gen `var'_p = date - tmax	
	replace `var'_p = -16 if `var'_p<-16
	replace `var'_p = . if `var'_p>48
	replace `var'_p = 20 if `var'_p>20 & !missing(`var'_p)
	drop TT tmax
}

sort cvemun date
foreach var in SP_BC SP SP_b SP_c {
	*Lags and forward (Ever treated)
	forvalues j = 4 8 to 16 {
		gen `var'_L`j' = L`j'.`var'
		replace `var'_L`j' = 0 if missing(`var'_L`j')
		gen `var'_F`j' = F`j'.`var'
		replace `var'_F`j' = 1 if missing(`var'_F`j')
	}

	*Define year (4 quarters) of treatment
	gen yyy = 0
	by cvemun : replace yyy = `var'[_n] + yyy[_n-1] if _n>1
	gen `var'x = 0
	replace `var'x = 1 if inrange(yyy,1,4)
	drop yyy

	*Lags and forward (year of treatment)
	forvalues j = 4 8 to 16 {
		gen `var'_L`j'x = L`j'.`var'x
		replace `var'_L`j'x = 0 if missing(`var'_L`j'x)
		gen `var'_F`j'x = F`j'.`var'x
		replace `var'_F`j'x = 0 if missing(`var'_F`j'x)
	}

	*Define lag variable previous to 4 years as 1
	replace `var'_F16x = 1 if `var'_F16==0
}

*Covariates - characteristics x time
foreach var in insured urban unm inf p50 age1 age2  gender ////
		yrschl industry1 industry2 industry3 industry4 industry5 industry6 industry7 ////
		industry8 industry9 industry10 industry11 industry12 industry13 industry14 industry15 {
	gen x_t_`var' = `var'*date
}
qui tab date, gen(date_dummy)

save  "Data Created\DiD_DB.dta", replace	//General Dataset saved//