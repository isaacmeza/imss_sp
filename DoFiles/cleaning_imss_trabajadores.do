
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: July. 07, 2022
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Cleaning IMSS datasets

*******************************************************************************/
*/

**************************		Panel - Workers		****************************
********************************************************************************

/*
use "$directorio/Data Private/panel_trabajadores.dta", clear
gen u = uniform()<0.0025 if periodo==20003
bysort idnss : egen kp = max(u)
keep if kp==1
drop u kp
save "$directorio/_aux/panel_trabajadores.dta", replace
*/
*use "$directorio/_aux/panel_trabajadores.dta", clear
use "$directorio/Data Private/panel_trabajadores.dta", clear
duplicates drop
rename cve_mun_final municipio
merge m:1 municipio using "Data Original\merge_ss_eneu_final.dta", keepusing(cvemun) keep(1 3) nogen
drop if missing(cvemun)
drop municipio

*Date 
tostring periodo, replace
gen year = substr(periodo,1,4)
destring year, replace
gen quarter = substr(periodo,5,.)
destring quarter, replace
replace quarter = quarter/3
gen date = yq(year, quarter)
format date %tq
drop periodo

gen date_initial_rfc = date(inirfc,"MDY")
format date_initial_rfc %td
drop inirfc
gen tenure_firm =  (dofq(date) - date_initial_rfc)/365

replace size_cierre = "S8" if size_cierre=="NA"
encode size_cierre, gen(size_cierre_)
drop size_cierre
rename size_cierre_ size_cierre

*Panel
sort idnss date sal_cierre
bysort idnss date : gen kp = (_n==_N)
keep if kp==1
drop kp
xtset idnss date

*Balance panel
gen sample1 = 1
tsfill
gen sample2 = 1
tsfill, full
gen sample3 = 1

*Imputations
replace year = yofd(dofq(date))
replace quarter = quarter(dofq(date))
sort idnss date
by idnss: replace sexo = sexo[_n-1] if missing(sexo)
by idnss : ipolate edad_final date, gen(edad_final_) epolate
drop edad_final
rename edad_final_ edad_final
*We are assuming that the individual stay at the last seen municipality in IMSS data when drops out of IMSS data.
by idnss: replace cvemun = cvemun[_n-1] if missing(cvemun) & !missing(cvemun[_n-1])
by idnss: replace cve_ent_final = cve_ent_final[_n-1] if missing(cve_ent_final) & !missing(cve_ent_final[_n-1]) 

*Imputation when drops out of IMSS data
foreach var of varlist size_cierre sal_cierre id_consultorio id_pareja id_padres id_hijos {
	by idnss : replace `var' = `var'[_n-1] if missing(`var') & !missing(`var'[_n-1])
} 

sort idnss date

*Dependent variable
gen formal = !missing(ta)
gen informal = missing(ta)

*Identify 'definitive' exits
	*because panel is balanced
by idnss : gen exits_ = 1 if missing(ta) & _n==_N	
by idnss : egen exits = max(exits_)
replace exits = 0 if missing(exits)

*Count number of active periods
by idnss : ipolate ta date, gen(active_) 
by idnss : egen num_active_periods = total(active_)

*Count (strict) gaps
by idnss : gen start_gap = 1 if missing(ta) & !missing(ta[_n-1])
by idnss : gen end_gap = 1 if missing(ta) & !missing(ta[_n+1])
by idnss : gen gap = 1 if !missing(start_gap) | !missing(end_gap)
by idnss : ipolate gap date if missing(ta), gen(gap_) 
by idnss : egen num_gaps = sum(gap_)
by idnss : gen nm_gap = sum(gap_)
replace num_gaps = num_gaps - 1 if exits==1
by idnss : replace num_gaps = . if _n!=1
by idnss : gen porc_gaps =  (num_gaps/num_active_periods)*100
by idnss : replace gap_ = . if num_gaps==nm_gap

*Labor attachment
su porc_gaps, d
by idnss : gen high_lab_att = porc_gaps>=`r(p50)' if !missing(porc_gaps)
by idnss : egen high_labor_att = mean(high_lab_att)

*Average time span (by individual) not reporting
gen chunk = sum(start_gap)
sort chunk idnss date
by chunk : egen time = sum(gap_)
by chunk : replace time = . if _n!=1
replace time = . if time==0
bysort idnss : egen mn_timegaps = mean(time)
by idnss : replace mn_timegaps = . if _n!=1

*Number of times switched
gen ind_sw = !missing(time)
bysort idnss : egen times_switch = total(ind_sw)
by idnss : replace times_switch = . if _n!=1

save "$directorio/Data Created/panel_trabajadores.dta", replace
