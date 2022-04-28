clear all
set mem 1000m
set matsize 6000
set maxvar 8000
set more off


cd "C:\Users\isaac\Downloads\114886-V1\" ///CHANGE THIS TO YOUR DIRECTORE STRUCTURE

use "Data Original\employers.dta", clear
joinby municipio year quarter using "Data Original\employees.dta", unm(b)
drop _merge

save "Data Created\data_g.dta",replace


****MERGING WITH OTHER DATASETS



*MERGING WITH THE CODING FROM ENEU (VERy VERY FEW MISSING VALUES)
joinby municipio using "Data Original\merge_ss_eneu_final.dta", unm(b)
tab _merge
drop _merge


*I DO THIS TO ADD OVER MUNICIPALITIE BS THAT ARE COMPRISED IN TWO SS CODES
collapse (sum) emp* pat*, by(cvemun year quarter)
drop if cvemun==.
tab year quarter
count

*MERGING WITH MUNICIPALITIES PRESENT IN THE ENE-ENOE)
joinby cvemun  using "Data Original\ENE_ENOE.dta", unm(b)
tab _merge
drop _merge

*MERGE WITH SEGURO POPULAR DATA
joinby cvemun year quarter using "Data Original\benef_SP_2002_2009.dta", unm(b)
tab _merge
drop if _merge==2 	//Drop this cities: no coding in SP data, or no data on SS records//
							//very few cities and small//
drop _merge mydate

tab year quarter
count

replace fam=100 if year>2009 // This establishes that by the end of 2009 all municipalities have implemented SP.

replace ind=100 if year>2009
replace fam=0 if fam==.
replace ind=0 if ind==.
gen mydate=yq(year,quarter)

*MERGE WITH THE DATA FROM POVERTY AND POPULATION 
joinby cvemun using "Data Original\Population_Poverty.dta", unm(b)
tab _merge
keep if _merge==3|_merge==1
* Tulum did not exist as city in 2000, others 2 cities are errors//
						//_merge==2: Small cities that are not in SS records//


drop _merge
bys cve:egen mp1=mean(pob2000)
replace pob2000=mp1
bys cve:egen mp2=mean(pob2005)
replace pob2005=mp2
drop mp*
gen gt=((pob2005/pob2000))^(1/24)
gen population=pob2000 if year>=1996	//assume a constant population growth rate//
sort cvemun year quarter
replace population=population[_n-1]*gt if cvemun[_n]==cvemun[_n-1] & (mydate>=149)
tsset cve mydate

*POLICY VARIABLES
gen SP_takeup=ind/population	//SP enrollment rate//


*IMPORTANT ASSUMPTION I AM TAKING THE IMPLEMENTATION OF THE SP ONLY IN THOSE MUNICIPALITIES WITH MORE THAN 10 FAMILIES (
*ONCE THE JOIN THE SP THEY ARE IN FOREVER
replace ind=0 if ind==.
replace fam=0 if fam==.
replace ind=0 if ind<1
replace fam=0 if ind<1
gen T=(ind>0)
gen Tb=(ind>10)
gen Tc=(ind>100)

sort cvemun year quarter
by cvemun:replace T=0 if T[_n]==1 & year==2002 & T[_n+1]==0 & T[_n+2]==0
by cvemun:replace Tb=0 if Tb[_n]==1 & year==2002 & Tb[_n+1]==0 & Tb[_n+2]==0
by cvemun:replace Tc=0 if Tc[_n]==1 & year==2002 & Tc[_n+1]==0 & Tc[_n+2]==0
by cvemun:replace T=1 if T[_n-1]==1
by cvemun:replace Tb=1 if Tb[_n-1]==1
by cvemun:replace Tc=1 if Tc[_n-1]==1
egen muni=group(cve)


*HERE I MERGE WITH MUNICIPALITIY CHARACTERISTICS FROM THE 2000 CENSUS
joinby cve using "Data Original\caract_muni.dta", unm(b)
sort cvemun year quarter
tab _merge
keep if _merge==3	//Drop those cities that were not cities in 2000//
drop _merge

*HERE I GENERATE SOME VARIABLES.
gen ent=statemx
bys ent mydate: egen pop_ent=sum(population)
gen log_pop_ent=log(pop_ent)


format mydate %tq


drop SP_takeup
gen SP_takeup=ind/population
replace SP_takeup=0 if SP_takeup==.

**Generating weights
*constant per year
sort cvemun year quarter

bys mydate: egen tp=total(population)
gen popwt=population/tp	//NEW WEIGHT: PROPORTIONAL WEIGHT//
gen log_pop=log(population)
sum SP_takeup [aw=popwt]
gen logw50=log(p50+1)



*Total Number of Workers



gen x=log(ind+1)
gen f=log(fam+1)

*Employees
gen e_t=log(emp_t)
gen e1=log(emp_size_1)
gen e2=log(emp_size_2_5)
gen e3=log(emp_size_6_50)
gen e4=log(emp_size_51_250)
gen e5=log(emp_size_251_500)
gen e6=log(emp_size_501_1000+emp_size_1000)
gen e7=log(emp_size_251_500+emp_size_501_1000+emp_size_1000)
gen e8=log(emp_size_1+emp_size_2_5+emp_size_6_50+emp_size_51_250)
gen e9=log(emp_size_1+emp_size_2_5+emp_size_6_50)

*Employers
gen p_t=log(pat_t)
gen p1=log(pat_size_1)
gen p2=log(pat_size_2_5)
gen p3=log(pat_size_6_50)
gen p4=log(pat_size_51_250)
gen p5=log(pat_size_251_500)
gen p6=log(pat_size_501_1000+pat_size_1000)
gen p7=log(pat_size_251_500+pat_size_501_1000+pat_size_1000)
gen p8=log(pat_size_1+pat_size_2_5+pat_size_6_50+pat_size_51_250)
gen p9=log(pat_size_1+pat_size_2_5+pat_size_6_50)

drop ent
gen ent=int(cvemun/1000)


*MERGE IT WITH THE GOBERMENT
joinby ent year quarter using "Data Original\gob.dta", unm(b)
drop _merge
egen government=group(gob)

tset cve mydate

***************
*** BALANCED PANEL DATA
**************
*WE USE A BALANCED PANEL DATASET
gen ones=(emp_t>1 & emp_t!=.)
bys cvemun: egen tx=total(ones)
tab tx

keep if tx==48	//since 2000, 10*4//
keep if p_t!=. //For which there is at least 1 employer in the municipality//



*DEFINING IMPLEMENTATION

gen imp=.
replace imp=0 if (year==2002)&Tb==1
bys cve: egen imp0=mean(imp)
replace imp=1 if (year==2003)&Tb==1&imp0==.
bys cve: egen imp1=mean(imp)
replace imp=2 if (year==2004)&Tb==1&imp1==.
bys cve: egen imp2=mean(imp)
replace imp=3 if (year==2005)&Tb==1&imp2==.
bys cve: egen imp3=mean(imp)
replace imp=4 if (year==2006)&Tb==1&imp3==.
bys cve: egen imp4=mean(imp)
replace imp=5 if (year==2007|year==2008|year==2009)&Tb==1&imp4==.
bys cve: egen imp5=mean(imp)




tsset cvemun mydate
sort cvemun mydate

quietly tab mydate, gen(_Ix)

gen fe_statedate=100*mydate+ent
gen log_pop2=log_pop^2
gen log_pop3=log_pop^3
sort cvemun mydate

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



xi: reg x x 
outreg2 mydate using reg\t1, replace   nocons bd(4) td(4)  excel   

xi: reg x x 
outreg2 mydate using reg\t2_3, replace   nocons bd(4) td(4)  excel    

xi: reg x x 
outreg2 mydate using reg\t4, replace   nocons bd(4) td(4)  excel    

xi: reg x x 
outreg2 mydate using reg\t5, replace   nocons bd(4) td(4)  excel    

xi: reg x x 
outreg2 mydate using reg\t6, replace   nocons bd(4) td(4)  excel    

capture program drop trends
capture program define trends
cap drop p_c
gen p_c=new-(_coef[TbL8x]*TbL8x+_coef[TbL12x]*TbL12x+_coef[Tbx]*Tbx+_coef[Tb4x]*Tb4x+_coef[Tb8x]*Tb8x+_coef[Tb12x]*Tb12x+_coef[Tb16]*Tb16) if new!=.
xi: areg p_c mydate [aw=pob2000],  a(cve) cluster(year)
outreg2 mydate using reg\t6, append   nocons bd(4) td(4)  excel    
drop new
end

*This calculates table 1

gen impplement1=mydate-170 if Tbx==1&Tbx[_n-1]==0
gen impplement2=mydate-170 if Tx==1&Tx[_n-1]==0

*this is because municipality 8003 never reaches 10 affiliates up to 2009. We do this for completeness so we have all 1392 in table 1. 
*It does not make any difference weahter 8003 is included or not in the analysis
 
replace impplement1=impplement2 if cve==8003

xi: reg impplement1 log_pop log_pop_ent  insured urban logw50 yrschl unm i.gov pobreza_alim2000 pobreza_pat2000 age1 age2  gender  industry1 industry2 industry3 industry4 industry5 industry6 industry7 industry8 industry9 industry10 industry11 industry12 industry13 industry14 industry15 , robust cluster(ent)
outreg2  using "reg\t1", replace se   nocons bdec(3)  td(4)  excel  
 
xi: reg impplement1 log_pop log_pop_ent  insured urban logw50 yrschl unm i.gov pobreza_alim2000 pobreza_pat2000 age1 age2  gender  industry1 industry2 industry3 industry4 industry5 industry6 industry7 industry8 industry9 industry10 industry11 industry12 industry13 industry14 industry15 if imp5>1 , robust cluster(ent)
outreg2  using "reg\t1", append se   nocons bdec(3)  td(4)  excel    


*This routing calculates Tables 2 and 3 in the paper

foreach var in  p_t p1 p2 p3 p4 p7 p9 e_t e1 e2 e3 e4 e7 e9 {
xi: xtreg `var' mydate [aw=pob2000] , fe robust cluster(cve)
outreg2 mydate using reg\t6, append  nocons bd(4) td(4)  excel    

gen new=`var'
quietly xi:xtreg `var'  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16  log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 _Ix* [aw=pob2000], fe robust cluster(cvemun)
quietly outreg2  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16 using reg/t2_3, append  nocons bd(4) td(4)  excel  
trends
gen c_`var'=p_c

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


*Figures 
*This rotine prepares the data to 


foreach var in  p_t p1 p2 p3 p4 p7 p9 e_t e1 e2 e3 e4 e7 e9{

**Event Study****
quietly xi: xtreg `var'   _It_m12-_It_m2 _It_m0 _It_1-_It_16   _Ix*  log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3  [aw=pob2000], fe robust cluster(cvemun)
gen s_b_`var'=.
gen s_se1_`var'=.
gen s_se2_`var'=.
quietly replace s_b_`var'=0 if xxx==-1


forval m=0/12 {
	if `m'!=1 {
	quietly replace s_b_`var'=_b[_It_m`m'] if xxx==-`m'
	quietly replace s_se1_`var'=_b[_It_m`m']+1.96*_se[_It_m`m'] if xxx==-`m'
	quietly replace s_se2_`var'=_b[_It_m`m']-1.96*_se[_It_m`m'] if xxx==-`m'
	}
}

forval m=1/16 {
	quietly replace s_b_`var'=_b[_It_`m'] if xxx==`m'
	quietly replace s_se1_`var'=_b[_It_`m']+1.96*_se[_It_`m'] if xxx==`m'
	quietly replace s_se2_`var'=_b[_It_`m']-1.96*_se[_It_`m'] if xxx==`m'
}


}

save "Data Created\Event_Study.dta", replace	//Dataset used in this current subroutine//
