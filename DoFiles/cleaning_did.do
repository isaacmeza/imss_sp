
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

*MERGE WITH IMSS DATASET
merge 1:1 cvemun year quarter using "Data Created\emp_imss.dta", nogen
merge 1:1 cvemun year quarter using "Data Created\asg_imss.dta", nogen
merge 1:1 cvemun year quarter using "Data Created\cross_trabajadores_mun.dta", nogen


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

replace ind = 0 if ind==.
replace ind = 0 if ind<1

replace ind_old = 0 if ind_old==.
replace ind_old = 0 if ind_old<1

*MERGE WITH DATA FROM POPULATION 
merge m:1 cvemun year using "Data Created\population.dta", nogen 
replace quarter = 4 if missing(quarter)
 
gen date = yq(year,quarter)
drop if missing(date)
format date %tq

gen pob2000_ = pobtot if year==2000
bysort cvemun : egen pob2000 = mean(pob2000_) 
drop pob2000_
gen logpop = log(pobtot)
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

*MERGE WITH INEGI MORTALITY DATA
replace year = yofd(dofq(date))
replace quarter = quarter(dofq(date))
merge 1:1 cvemun year quarter using "Data Created\mortality_cvemundate.dta", nogen


*MERGE WITH LUMINOSITY DATA
merge 1:1 cvemun year quarter using "$directorio\Data Created\luminosity.dta", nogen keep(1 3) keepusing(median_lum sd_lum)

*Epolation of luminosity
bysort cvemun : ipolate median_lum date, gen(median_lum_) epolate
drop median_lum
rename median_lum_ median_lum

*Epolation of population
bysort cvemun : egen pob2000_ = mean(pob2000)
replace pob2000 = pob2000_ if missing(pob2000)
drop pob2000_

bysort cvemun : ipolate lgpop date, gen(lgpop_) epolate
drop lgpop
rename lgpop_ lgpop

*Epolation of beneficiaries
sort cvemun date
by cvemun : replace ind = 0 if _n==1 & missing(ind)
replace ind = . if ind==0 & year>=2010
by cvemun : ipolate ind date, gen(ind_) epolate
drop ind
rename ind_ ind

drop if missing(cvemun)
drop if missing(date)

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

*DEFINITION OF DEPENDENT VARIABLES

*Imputation employers
sort cvemun date
by cvemun : gen fte = _n if !missing(afiliados_imss) 
by cvemun : egen firsttimeemp = min(fte)

by cvemun : replace afiliados_imss = 0 if missing(afiliados_imss) & year<=2015 & _n<=firsttimeemp & missing(ta)

foreach var of varlist asegurados1 asegurados2 asegurados3 asegurados4 asegurados5 asegurados6 asegurados7 asegurados8 asegurados afiliados_imss1 afiliados_imss2 afiliados_imss3 afiliados_imss4 afiliados_imss5 afiliados_imss6 afiliados_imss7 afiliados_imss8 trab_eventual_urb1 trab_eventual_urb2 trab_eventual_urb3 trab_eventual_urb4 trab_eventual_urb5 trab_eventual_urb6 trab_eventual_urb7 trab_eventual_urb8 trab_eventual_urb trab_eventual_campo1 trab_eventual_campo2 trab_eventual_campo3 trab_eventual_campo4 trab_eventual_campo5 trab_eventual_campo6 trab_eventual_campo7 trab_eventual_campo8 trab_eventual_campo trab_perm_urb1 trab_perm_urb2 trab_perm_urb3 trab_perm_urb4 trab_perm_urb5 trab_perm_urb6 trab_perm_urb7 trab_perm_urb8 trab_perm_urb trab_perm_campo1 trab_perm_campo2 trab_perm_campo3 trab_perm_campo4 trab_perm_campo5 trab_perm_campo6 trab_perm_campo7 trab_perm_campo8 trab_perm_campo ta_sal1 ta_sal2 ta_sal3 ta_sal4 ta_sal5 ta_sal6 ta_sal7 ta_sal8 ta_sal teu_sal1 teu_sal2 teu_sal3 teu_sal4 teu_sal5 teu_sal6 teu_sal7 teu_sal8 teu_sal tec_sal1 tec_sal2 tec_sal3 tec_sal4 tec_sal5 tec_sal6 tec_sal7 tec_sal8 tec_sal tpu_sal1 tpu_sal2 tpu_sal3 tpu_sal4 tpu_sal5 tpu_sal6 tpu_sal7 tpu_sal8 tpu_sal tpc_sal1 tpc_sal2 tpc_sal3 tpc_sal4 tpc_sal5 tpc_sal6 tpc_sal7 tpc_sal8 tpc_sal {
	by cvemun : replace `var' = 0 if missing(`var') & !missing(afiliados_imss) & year<=2015 
}

*Imputation deaths
foreach var of varlist total_d* {
	replace `var' = 0 if missing(`var') & inrange(year,2000,2019) 
}

*-------------------------------------------------------------------------------
*Employees
gen e_t = log(emp_t)
gen e_1 = log(emp_size_1) 
gen e_50 = log(emp_size_2_5+emp_size_6_50)
gen e_250 = log(emp_size_51_250)
gen e_1000m = log(emp_size_251_500+emp_size_501_1000+emp_size_1000)

gen e_t_ = log(emp_t + 1)
gen e_1_ = log(emp_size_1 + 1) 
gen e_50_ = log(emp_size_2_5+emp_size_6_50 + 1)
gen e_250_ = log(emp_size_51_250 + 1)
gen e_1000m_ = log(emp_size_251_500+emp_size_501_1000+emp_size_1000 + 1)


*Employers
gen p_t = log(pat_t)
gen p_1 = log(pat_size_1) 
gen p_50 = log(pat_size_2_5+pat_size_6_50) 
gen p_250 = log(pat_size_51_250)
gen p_1000m = log(pat_size_251_500+pat_size_501_1000+pat_size_1000)

gen p_t_ = log(pat_t + 1)
gen p_1_ = log(pat_size_1 + 1) 
gen p_50_ = log(pat_size_2_5+pat_size_6_50 + 1) 
gen p_250_ = log(pat_size_51_250 + 1)
gen p_1000m_ = log(pat_size_251_500+pat_size_501_1000+pat_size_1000 + 1)


	*IMSS
foreach var of varlist eventuales permanentes ta_femenino ta_masculino salario_promedio voluntarios_masculino voluntarios_femenino voluntarios {
	gen lg_`var' = log(`var')
	gen lg1_`var' = log(`var' + 1)
}

gen trab_eventual = trab_eventual_urb + trab_eventual_campo
gen te_sal = teu_sal + tec_sal
gen trab_perm = trab_perm_urb + trab_perm_campo
gen tp_sal = tpu_sal + tpc_sal
gen trab_campo = trab_eventual_campo + trab_perm_campo
gen tc_sal = tec_sal + tpc_sal
gen trab_urb = trab_eventual_urb + trab_perm_urb
gen tu_sal = teu_sal + tpu_sal

foreach size in 1 2 3 4 5 6 7 {
	gen trab_eventual`size' = trab_eventual_urb`size' + trab_eventual_campo`size'
	gen te_sal`size' = teu_sal`size' + tec_sal`size'
	gen trab_perm`size' = trab_perm_urb`size' + trab_perm_campo`size'
	gen tp_sal`size' = tpu_sal`size' + tpc_sal`size'
	gen trab_campo`size' = trab_eventual_campo`size' + trab_perm_campo`size'
	gen tc_sal`size' = tec_sal`size' + tpc_sal`size'
	gen trab_urb`size' = trab_eventual_urb`size' + trab_perm_urb`size'
	gen tu_sal`size' = teu_sal`size' + tpu_sal`size'
}


	*ASG
foreach var in asegurados afiliados_imss trab_eventual trab_perm trab_campo trab_urb ta_sal {
	gen lg_`var' = log(`var')
	gen lg_`var'_1 = log(`var'1)
	gen lg_`var'_50 = log(`var'2 + `var'3)
	gen lg_`var'_250 = log(`var'4)
	gen lg_`var'_1000m = log(`var'5 + `var'6 + `var'7)
	
	gen lg1_`var' = log(`var' + 1)
	gen lg1_`var'_1 = log(`var'1 + 1)
	gen lg1_`var'_50 = log(`var'2 + `var'3 + 1)
	gen lg1_`var'_250 = log(`var'4 + 1)
	gen lg1_`var'_1000m = log(`var'5 + `var'6 + `var'7 + 1)
}

	
gen masa_sal_te = (masa_sal_teu*teu_sal + masa_sal_tec*tec_sal)/(te_sal)
gen masa_sal_tp = (masa_sal_tpu*tpu_sal + masa_sal_tpc*tpc_sal)/(tp_sal)
gen masa_sal_tc = (masa_sal_tec*tec_sal + masa_sal_tpc*tpc_sal)/(tc_sal)
gen masa_sal_tu = (masa_sal_teu*teu_sal + masa_sal_tpu*tpu_sal)/(tu_sal)

foreach size in 1 2 3 4 5 6 7 {
	gen masa_sal_te`size' = (masa_sal_teu`size'*teu_sal`size' + masa_sal_tec`size'*tec_sal`size')/(te_sal`size')
	gen masa_sal_tp`size' = (masa_sal_tpu`size'*tpu_sal`size' + masa_sal_tpc`size'*tpc_sal`size')/(tp_sal`size')
	gen masa_sal_tc`size' = (masa_sal_tec`size'*tec_sal`size' + masa_sal_tpc`size'*tpc_sal`size')/(tc_sal`size')
	gen masa_sal_tu`size' = (masa_sal_teu`size'*teu_sal`size' + masa_sal_tpu`size'*tpu_sal`size')/(tu_sal`size')
}
	
foreach var in ta te tp tc tu {
	gen lg1_masa_sal_`var' = log(masa_sal_`var' + 1)
	replace lg1_masa_sal_`var' = 0 if missing(lg1_masa_sal_`var')
	
	gen lg1_masa_sal_`var'_1 = log((masa_sal_`var'1*`var'_sal1)/(`var'_sal1) + 1)
	replace lg1_masa_sal_`var'_1 = 0 if missing(lg1_masa_sal_`var'_1)	
	
	gen lg1_masa_sal_`var'_50 = log((masa_sal_`var'2*`var'_sal2 + masa_sal_`var'3*`var'_sal3)/(`var'_sal2 + `var'_sal3) + 1)
	replace lg1_masa_sal_`var'_50 = 0 if missing(lg1_masa_sal_`var'_50)
	
	gen lg1_masa_sal_`var'_250 = log(masa_sal_`var'4 + 1)
	replace lg1_masa_sal_`var'_250 = 0 if missing(lg1_masa_sal_`var'_250)
	
	gen lg1_masa_sal_`var'_1000m = log((masa_sal_`var'5*`var'_sal5 + masa_sal_`var'6*`var'_sal6 + masa_sal_`var'7*`var'_sal7)/(`var'_sal5 + `var'_sal6 + `var'_sal7) + 1)
	replace lg1_masa_sal_`var'_1000m = 0 if missing(lg1_masa_sal_`var'_1000m)
}	
	
	
*Cross-section IMSS
gen lg1_emp_cross_1 = log(taS1 + 1)
gen lg1_emp_cross_50 = log(taS2 + taS3 + 1)
gen lg1_emp_cross_250 = log(taS4 + 1)
gen lg1_emp_cross_1000m = log(taS5 + taS6 + taS7 + 1)
	
foreach var of varlist ta_low_wage ta_high_wage ta_soltero ta_casado {
	gen lg1_`var' = log(`var' + 1)
}
	
*Mortality
foreach var of varlist total_d* {
	gen lg_`var' = log(`var' + 1)
}


*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

*Identify municipalities that exists in all quarters from 2000-2011 used in B-C
cap drop ones
gen ones = (emp_t>=1 & emp_t!=.) if year<=2011
bysort cvemun : egen txx = total(ones)
tab txx
gen bal_48 = (txx==48 & p_t!=.) //since 2000, 12*4// //For which there is at least 1 employer in the municipality//

*Identify municipalities that exists in all quarters from 2000-2011 with IMSS data
cap drop ones
gen ones = (afiliados_imss>=0 & afiliados_imss!=.) if year<=2011
bysort cvemun : egen tyy = total(ones)
tab tyy
gen bal_48_imss = (tyy==48)

*Identify municipalities that exists in all quarters from 2002-2010 with INEGI mortality data
cap drop ones
gen ones = (total_d!=.) if year<=2011
bysort cvemun : egen tzz = total(ones)
tab tzz
gen bal_48_d = (tzz==48)

*-------------------------------------------------------------------------------

*IDENTIFY TREATMENT IN MUNICIPALITIES AS xx OR MORE INDIVIDUALS ENROLLED IN SP


*Definition by intensity
gen SP = (ind>1) | year>2009
gen SP_b = (ind>10) | year>2009 /*Agrees with B-C definition when bal_48==1*/
gen SP_c = (ind>100) | year>2009
gen SP_takeup = ind/exp(lgpop)

sort cvemun year quarter

foreach var of varlist SP SP_b SP_c {
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
	replace `var'_p = 24 if `var'_p>24 & !missing(`var'_p)
	drop TT tmax
	
	*Collapsed period of treatment
	gen `var'_col = .
	local k = -10
	forvalues i = -40(4)80 {
		replace `var'_col = `k' if inrange(`var'_p, `i',`=`i'+3')
		local k = `k' + 1
	}
}

sort cvemun date
foreach var in SP SP_b SP_c {
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

compress
save  "Data Created\DiD_DB.dta", replace	//General Dataset saved//