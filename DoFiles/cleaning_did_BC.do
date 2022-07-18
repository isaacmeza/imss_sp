
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

*Employees
gen e_t_=log(emp_t)
gen e1_=log(emp_size_1)
gen e2_=log(emp_size_2_5)
gen e3_=log(emp_size_6_50)
gen e4_=log(emp_size_51_250)
gen e5_=log(emp_size_251_500)
gen e6_=log(emp_size_501_1000+emp_size_1000)
gen e7_=log(emp_size_251_500+emp_size_501_1000+emp_size_1000)
gen e8_=log(emp_size_1+emp_size_2_5+emp_size_6_50+emp_size_51_250)
gen e9_=log(emp_size_1+emp_size_2_5+emp_size_6_50)

*Employers
gen p_t_=log(pat_t)
gen p1_=log(pat_size_1)
gen p2_=log(pat_size_2_5)
gen p3_=log(pat_size_6_50)
gen p4_=log(pat_size_51_250)
gen p5_=log(pat_size_251_500)
gen p6_=log(pat_size_501_1000+pat_size_1000)
gen p7_=log(pat_size_251_500+pat_size_501_1000+pat_size_1000)
gen p8_=log(pat_size_1+pat_size_2_5+pat_size_6_50+pat_size_51_250)
gen p9_=log(pat_size_1+pat_size_2_5+pat_size_6_50)

drop ent
gen ent=int(cvemun/1000)


*MERGE IT WITH THE GOBERMENT
joinby ent year quarter using "Data Original\gob.dta", unm(b)
drop _merge
egen government=group(gob)

tset cve mydate

*MERGE WITH LUMINOSITY DATA
merge m:1 cvemun year quarter using "$directorio\Data Created\luminosity.dta", nogen keep(1 3) keepusing(median_lum)


***************
*** BALANCED PANEL DATA
**************
*WE USE A BALANCED PANEL DATASET
gen ones=(emp_t>1 & emp_t!=.)
bys cvemun: egen tx=total(ones)
tab tx

gen bal_48 = (tx==48 & p_t_!=.) //since 2000, 10*4// //For which there is at least 1 employer in the municipality//

*keep if tx==48	//since 2000, 10*4//
*keep if p_t!=. //For which there is at least 1 employer in the municipality//



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



foreach var in insured urban unm inf p50 age1 age2  gender ////
		yrschl industry1 industry2 industry3 industry4 industry5 industry6 industry7 ////
		industry8 industry9 industry10 industry11 industry12 industry13 industry14 industry15 {
gen x_t_`var'=`var'*mydate
}


********************************************************************************
***************** 				Event Study			 ***************************
********************************************************************************
sort cvemun year quarter
gen TT=1 if Tb==1 & Tb[_n-1]==0
replace TT=0 if TT==.

bys cvemun: egen tmax=max(TT*mydate)
gen xxx=mydate-tmax	//temporal variable//
replace xxx=-16 if xxx<-16
replace xxx=. if xxx>50
replace xxx=20 if xxx>20 & xxx!=.

gen yyy=mydate-tmax	//temporal variable//
replace yyy=-12 if yyy<-12
replace yyy=. if yyy>50
replace yyy=16 if yyy>16 & yyy!=.


xtile size=pob2000, n(4)
gen mydate2=mydate*mydate
gen mydate3=mydate2*mydate

save  "Data Created\DiD_BC.dta", replace	//General Dataset saved//