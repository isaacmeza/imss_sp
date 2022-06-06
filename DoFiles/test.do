clear all
set mem 1000m
set matsize 6000
set maxvar 8000
set more off


cd "C:\Users\isaac\Dropbox\Statistics\P27\IMSS\" ///CHANGE THIS TO YOUR DIRECTORE STRUCTURE

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

tsfill
replace ind = . if ind==0
by cvemun : ipolate ind mydate, gen(ind_)
replace ind_ = 0 if ind_==. 
drop ind
rename ind_ ind
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
*
/*
gen ones=(emp_t>1 & emp_t!=.)
gen oness=(emp_t>=1 & emp_t!=.)
bys cvemun: egen txx=total(oness)

tab tx

keep if tx==48	//since 2000, 10*4//

keep if p_t!=. //For which there is at least 1 employer in the municipality//
*/

sort cvemun mydate

quietly tab mydate, gen(_Ix)


forvalues j=4 8 to 16 {
      quietly bys cvemun:gen Tb`j'=Tb[_n-`j'] 
      quietly bys cvemun:gen TbL`j'=Tb[_n+`j'] 


}



forval j=4 8 to 16 {

	quietly replace Tb`j'=0 if Tb`j'==.
	quietly replace TbL`j'=1 if TbL`j'==.



}

foreach var in  Tb {
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



replace TbL12x=1 if TbL12==0
*replace TbL16x=1 if TbL16==0




foreach var in insured urban unm inf p50 age1 age2  gender ////
		yrschl industry1 industry2 industry3 industry4 industry5 industry6 industry7 ////
		industry8 industry9 industry10 industry11 industry12 industry13 industry14 industry15 {
gen x_t_`var'=`var'*mydate
}

gen mydate2=mydate*mydate
gen mydate3=mydate2*mydate




save  "Data Created\Reg_t.dta", replace	//General Dataset saved//

****REGRESSIONS

use  "Data Created\Reg_t.dta", clear	


 xi:xtreg e9  TbL12x TbL8x  Tbx Tb4x Tb8x Tb12x Tb16  log_pop x_t_* i.ent*mydate i.ent*mydate2 i.ent*mydate3 _Ix* [aw=pob2000], fe robust cluster(cvemun)
 
 