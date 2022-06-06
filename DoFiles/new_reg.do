
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: May. 24, 2022
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Main data cleaning

*******************************************************************************/
*/
clear all
set mem 1000m
set matsize 6000
set maxvar 8000
set more off
cd "C:\Users\isaac\Dropbox\Statistics\P27\IMSS\" 

use "Data Original\employers.dta", clear
merge 1:1 municipio year quarter using "Data Original\employees.dta", nogen
save "Data Created\data_g.dta",replace


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

replace ind = ind_H + ind_M if missing(ind)


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
merge m:1 cvemun using "Data Original\caract_muni.dta"
bysort cvemun : gen count = _N if _merge==1
drop if _merge==1 & count<10
drop count _merge


*MERGE WITH GOVERNMENT
gen ent=int(cvemun/1000)
merge m:1 ent year quarter using "Data Original\gob.dta", nogen keepusing(gob)

encode gob, gen(government)
drop gob

*PANEL DATASET
drop if missing(cvemun)
drop if missing(mydate)
sort cvemun year quarter
xtset cvemun mydate
*Balance panel
gen uno = 1
tsfill
gen dos = 1
tsfill, full
gen tres = 1

foreach var of varlist ind lgpop {
	replace `var' = . if `var'==0
	by cvemun : ipolate `var' mydate, gen(`var'_)
	drop `var'
	rename `var'_ `var'
	by cvemun : replace `var' = 0 if missing(`var') 
}


*Filter
sort cvemun mydate
by cvemun : egen flag = max(lgpop)
drop if flag==0
drop flag



*IDENTIFY TREATMENT IN MUNICIPALITIES AS xx OR MORE INDIVIDUALS ENROLLED IN SP
replace fam = 0 if ind==0
replace ind = 0 if ind<1
replace fam = 0 if ind<1

**# Bookmark #1
br cvemun mydate ind lgpop

gen SP = (ind>1)
gen SP_b = (ind>10)
gen SP_c = (ind>100)
gen SP_takeup = ind/exp(lgpop)

sort cvemun year quarter
by cvemun : replace SP = 1 if SP[_n-1]==1
by cvemun : replace SP_b = 1 if SP_b[_n-1]==1
by cvemun : replace SP_c = 1 if SP_c[_n-1]==1


*Employees
gen e_t = log(emp_t)
gen e1 = log(emp_size_1)
gen e2 = log(emp_size_2_5)
gen e3 = log(emp_size_6_50)
gen e4 = log(emp_size_51_250)
gen e5 = log(emp_size_251_500)
gen e6 = log(emp_size_501_1000+emp_size_1000)
gen e7 = log(emp_size_251_500+emp_size_501_1000+emp_size_1000)
gen e8 = log(emp_size_1+emp_size_2_5+emp_size_6_50+emp_size_51_250)
gen e9 = log(emp_size_1+emp_size_2_5+emp_size_6_50)

*Employers
gen p_t = log(pat_t)
gen p1 = log(pat_size_1)
gen p2 = log(pat_size_2_5)
gen p3 = log(pat_size_6_50)
gen p4 = log(pat_size_51_250)
gen p5 = log(pat_size_251_500)
gen p6 = log(pat_size_501_1000+pat_size_1000)
gen p7 = log(pat_size_251_500+pat_size_501_1000+pat_size_1000)
gen p8 = log(pat_size_1+pat_size_2_5+pat_size_6_50+pat_size_51_250)
gen p9 = log(pat_size_1+pat_size_2_5+pat_size_6_50) 


**# Bookmark #2
br cvemun mydate ind SP imp*

quietly tab mydate, gen(_Ix)



forvalues j=4 8 to 16 {
      quietly bys cvemun:gen x`j'=x[_n-`j'] 
	quietly bys cvemun:gen xL`j'=x[_n+`j'] 
      quietly bys cvemun:gen T`j'=T[_n-`j'] 
      quietly bys cvemun:gen TL`j'=T[_n+`j'] 
      quietly bys cvemun:gen Tb`j'=Tb[_n-`j'] 
      quietly bys cvemun:gen TbL`j'=Tb[_n+`j'] 
	quietly bys cvemun:gen Tc`j'=Tc[_n-`j'] 
      quietly bys cvemun:gen TcL`j'=Tc[_n+`j'] 



}



forval j=4 8 to 16 {
      quietly replace x`j'=0 if T`j'==.
      quietly replace T`j'=0 if T`j'==.
	quietly replace TL`j'=1 if TL`j'==.
	quietly replace Tb`j'=0 if Tb`j'==.
	quietly replace TbL`j'=1 if TbL`j'==.
      quietly replace Tc`j'=0 if Tc`j'==.
	quietly replace TcL`j'=1 if TcL`j'==.


}

foreach var in T Tb {
gen yyy=0
replace yyy=`var'[_n]+yyy[_n-1] if cvemun[_n]==cvemun[_n-1]
gen `var'x=0
replace `var'x=1 if yyy>=1 & yyy<=4
drop yyy
}

forvalues j=4 8 to 16 {
      quietly bys cvemun:gen T`j'x=Tx[_n-`j'] 
      quietly bys cvemun:gen Tb`j'x=Tbx[_n-`j'] 
      quietly bys cvemun:gen TbL`j'x=Tbx[_n+`j'] 
      quietly bys cvemun:gen TL`j'x=Tx[_n+`j'] 
replace T`j'x=0 if T`j'x==.
replace Tb`j'x=0 if Tb`j'x==.
replace TL`j'x=0 if TL`j'x==.
replace TbL`j'x=0 if TbL`j'x==.
}



replace TbL12x=1 if TbL12==0
replace TL12x=1 if TL12==0



foreach var in insured urban unm inf p50 age1 age2  gender ////
		yrschl industry1 industry2 industry3 industry4 industry5 industry6 industry7 ////
		industry8 industry9 industry10 industry11 industry12 industry13 industry14 industry15 {
gen x_t_`var'=`var'*mydate
}


********************************************************
*******************************************************
*** Event Study			 *******************************
********************************************************
*******************************************************
sort cvemun year quarter
gen TT=1 if Tb==1 & Tb[_n-1]==0
replace TT=0 if TT==.

bys cvemun: egen tmax=max(TT*mydate)
gen xxx=mydate-tmax	//temporal variable//
replace xxx=-12 if xxx<-12
replace xxx=. if xxx>50
replace xxx=16 if xxx>16 & xxx!=.
tab xxx, gen(_It)
**

*renaming variables
*_It_m leads and _It_ are lags: 20 leads, and 12 lags
sum xxx
local r=r(max)-r(min)+1
local rm=r(max)-13
forval x=1/`r' {
	local y=(-13)+`x'
	local z=(-1)*`y'
	if `x'<=13 {
		rename _It`x' _It_m`z'
		quietly replace _It_m`z'=0 if xxx==.
	}
	else if `x'>13 {
		rename _It`x' _It_`y'
		quietly replace _It_`y'=0 if xxx==.
	}
}


xtile size=pob2000, n(4)
gen mydate2=mydate*mydate
gen mydate3=mydate2*mydate

save  "Data Created\Reg_t.dta", replace	//General Dataset saved//

****REGRESSIONS

use  "Data Created\Reg_t.dta", clear	



*This routing calculates Tables 2 and 3 in the paper

foreach var in  p_t  e_t p9 e9 {
 xi: xtreg `var' mydate [aw=pob2000] , fe robust cluster(cve)


 xi:xtreg `var'  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16  log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 _Ix* [aw=pob2000], fe robust cluster(cvemun)



}

***This calculates table 4

foreach var in   p9  e9 {

quietly xi:xtreg `var'  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16  log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 _Ix* [aw=pob2000] if urban==0, fe robust cluster(cvemun)
quietly outreg2  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 using reg/t4, append  nocons bd(4) td(4)  excel 

quietly xi:xtreg `var'  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16  log_pop  x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3  _Ix* [aw=pob2000] if urban==1, fe robust cluster(cvemun)
quietly outreg2  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 using reg/t4, append  nocons bd(4) td(4)  excel   

quietly xi:xtreg `var'  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16  log_pop  x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3  _Ix* [aw=pob2000] if size==1, fe robust cluster(cvemun)
quietly outreg2  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 using reg/t4, append  nocons bd(4) td(4)  excel   

quietly xi:xtreg `var'  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16  log_pop  x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3  _Ix* [aw=pob2000] if size==2, fe robust cluster(cvemun)
quietly outreg2  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 using reg/t4, append  nocons bd(4) td(4)  excel   

quietly xi:xtreg `var'  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16  log_pop  x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3  _Ix* [aw=pob2000] if size==3, fe robust cluster(cvemun)
quietly outreg2  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 using reg/t4, append  nocons bd(4) td(4)  excel   

quietly xi:xtreg `var'  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16  log_pop  x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3  _Ix* [aw=pob2000] if size==4, fe robust cluster(cvemun)
quietly outreg2  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 using reg/t4, append  nocons bd(4) td(4)  excel   
}



************** ROBUSTNESS CHECKS (Table 5)

clear
set more off
use  "Data Created\Reg_t.dta", clear	



foreach var in  p9 e9 {

**basics


quietly xi:xtreg `var'  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 log_pop i.ent*mydate i.ent*mydate2 i.ent*mydate3  _Ix* [aw=pob2000] , fe robust cluster(cvemun)
quietly outreg2  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 using reg/t5, append  nocons bd(4) td(4)  excel 
**post pilot

quietly xi:xtreg `var'   TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 _Ix* [aw=pob2000] if imp5>1, fe robust cluster(cvemun)
quietly outreg2  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 using reg/t5, append  nocons bd(4) td(4)  excel 

***unweighted

quietly xi:xtreg `var'   TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 _Ix* , fe robust cluster(cvemun)
quietly outreg2  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 using reg/t5, append  nocons bd(4) td(4)  excel 



***statesXtime fixed effects

quietly xi:xtreg `var'   TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*i.mydate _Ix* [aw=pob2000] , fe robust cluster(cvemun)
quietly outreg2  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 using reg/t5, append  nocons bd(4) td(4)  excel 

***ENE-ENOE

quietly xi:xtreg `var'   TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 _Ix* [aw=pob2000] if stayers==1 , fe robust cluster(cvemun)
quietly outreg2  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 using reg/t5, append  nocons bd(4) td(4)  excel 


*** original treatment

quietly xi:xtreg `var'  TL12x TL8x  Tx T4x T8x T12x T16 log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 _Ix* [aw=pob2000], fe robust cluster(cvemun)
quietly outreg2  TL12x TL8x  Tx T4x T8x T12x T16 using reg/t5, append  nocons bd(4) td(4)  excel 

***Controling for big firms

quietly xi:xtreg `var'   TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 _Ix* [aw=pob2000] if e7!=., fe robust cluster(cvemun)
quietly outreg2  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 using reg/t5, append  nocons bd(4) td(4)  excel 

quietly xi:xtreg `var'   TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 log_pop x_t_* _Ix* i.ent*mydate i.ent*mydate2 i.ent*mydate3 e7 [aw=pob2000], fe robust cluster(cvemun)
quietly outreg2  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 using reg/t5, append  nocons bd(4) td(4)  excel 

}