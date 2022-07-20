
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	June. 10, 2022
* Last date of modification: 
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Transition analysis : Formal/Informal/Unemployed

*******************************************************************************/
*/

use "$directorio\Data Created\sdemt_enoe.dta", clear
merge m:1 year quarter ent mun using  "$directorio\Data Created\luminosity.dta", keep(1 3)


*Municipality
egen int municipio = group(ent mun)

*Time
gen int date = yq(year, quarter)
format date %tq

*Covariates
gen log_ing = log(ing_x_hrs+1)

*Informal 
gen byte informal = (emp_ppal==1) if emp_ppal!=0 & !missing(emp_ppal)
label define informal 0 "Formal" 1 "Informal"
label values informal informal 

gen byte noimss = !inlist(imssissste,1) if !inlist(imssissste,0,5,6) & !missing(imssissste)
label define noimss 0 "IMSS" 1 "No IMSS"
label values noimss noimss

*Formal/Informal/Desocupado
gen byte class_trab = informal
replace class_trab = 2 if missing(informal) & clase1==1

label define class_trab 0 "Formal" 1 "Informal" 2 "Unemployment"
label values class_trab class_trab 


*ID
egen id_ = group(cd_a ent con v_sel n_hog h_mud n_ren)
sort id_ date
by id_ : gen id_1 = (n_ent[_n]!=n_ent[_n-1]+1 | date[_n]!=date[_n-1]+1) 
by id_ : gen id_aux = sum(id_1)
egen id = group(id_ id_aux)


keep id date n_ent municipio class_trab informal noimss mean_lum median_lum sex eda anios_esc hrsocup log_ing t_tra scian fac

reshape wide class_trab informal noimss mean_lum median_lum sex eda anios_esc hrsocup log_ing t_tra scian municipio date fac, i(id) j(n_ent)

order id date* fac* municipio* class_trab* informal1 informal2 informal3 informal4 informal5 noimss* mean_lum* median_lum* sex* eda* anios_esc* hrsocup* log_ing* t_tra* scian* 


*Imputation
forvalues j = 2/5 {
	replace municipio`j' = municipio`=`j'-1' if missing(municipio`j') & !missing(municipio`=`j'-1') & !missing(date`j')
	replace sex`j' = sex`=`j'-1' if missing(sex`j') & !missing(sex`=`j'-1') & !missing(date`j')
	replace eda`j' = eda`=`j'-1' if missing(eda`j') & !missing(eda`=`j'-1') & !missing(date`j')
	replace anios_esc`j' = anios_esc`=`j'-1' if missing(anios_esc`j') & !missing(anios_esc`=`j'-1') & !missing(date`j')
}

egen class_trab = rownonmiss(class_trab*)
drop if inlist(class_trab,0,1)
drop class_trab

*Append time t & time t+1
forvalues j = 1/4 {
	preserve
	keep id *`j' *`=`j'+1'
	foreach var of varlist *`j' {
		local nme = substr("`var'", 1, strlen("`var'") - 1)
		rename `var' `nme'1
	}
	foreach var of varlist *`=`j'+1' {
		local nme = substr("`var'", 1, strlen("`var'") - 1)
		rename `var' `nme'2
	}	
	tempfile temp`j'
	save `temp`j''
	restore
}

use `temp1', clear
append using `temp2'
append using `temp3'
append using `temp4'
sort id date1
save  "$directorio\_aux\transition_master.dta", replace



***********************************************
**** 	Transition probabilities		  *****
***********************************************
use  "$directorio\_aux\transition_master.dta", clear

gen formal2 = (informal2==0) if !missing(informal2)
gen imss2 = (noimss2==0) if !missing(noimss2)
gen median_lum_c = median_lum2 - median_lum1

*Probability stack plot
tab class_trab1 class_trab2 [fw = fac1], row matrow(row) matcol(col) matcell(MT)
catplot class_trab2 class_trab1 [fw = fac1],  blabel(bar, format(%4.1f) pos(base)) percent(class_trab1) stack asyvars ///
	ytitle("Percent") graphregion(color(white)) legend(pos(6) rows(1)) note("Observations : `r(N)'", size(vsmall))
graph export "$directorio/Figuras/transition_matrix_class.pdf", replace
	
tab informal1 informal2 [fw = fac1], row matrow(row) matcol(col) matcell(MT)
catplot informal2 informal1 [fw = fac1],  blabel(bar, format(%4.1f) pos(base)) percent(informal1) stack asyvars ///
	ytitle("Percent") graphregion(color(white)) legend(pos(6) rows(1)) note("Observations : `r(N)'", size(vsmall))
graph export "$directorio/Figuras/transition_matrix_inf.pdf", replace

tab noimss1 noimss2 [fw = fac1], row matrow(row) matcol(col) matcell(MT)
catplot noimss2 noimss1 [fw = fac1],  blabel(bar, format(%4.1f) pos(base)) percent(noimss1) stack asyvars ///
	ytitle("Percent") graphregion(color(white)) legend(pos(6) rows(1)) note("Observations : `r(N)'", size(vsmall))
graph export "$directorio/Figuras/transition_matrix_noimss.pdf", replace
	

*-------------------------------------------------------------------------------

*Transition probabilities by municipality 
	

local j = 1
levelsof municipio1, local(levels) 
matrix beta_mun = J(`r(r)',4,.)
matrix obs_mun = J(`r(r)',4,.)

foreach l of local levels {
	if `j'==1 {
		di " "
		_dots 0, title(Loop through replications) reps(`r(r)')
	}
	qui su noimss2 [fw = fac1] if noimss1==0 & municipio1==`l'
	cap matrix beta_mun[`j',1] = `r(mean)'
	cap matrix obs_mun[`j',1] = `r(N)'	
	qui su imss2 [fw = fac1] if noimss1==1 & municipio1==`l'
	cap matrix beta_mun[`j',2] = `r(mean)'	
	cap matrix obs_mun[`j',2] = `r(N)'	
	
	qui su informal2 [fw = fac1] if informal1==0 & municipio1==`l'
	cap matrix beta_mun[`j',3] = `r(mean)'
	cap matrix obs_mun[`j',3] = `r(N)'	
	qui su formal2 [fw = fac1] if informal1==1 & municipio1==`l'
	cap matrix beta_mun[`j',4] = `r(mean)'
	cap matrix obs_mun[`j',4] = `r(N)'	
	
	noi _dots `j' 0
	local j = `j' + 1
}

svmat beta_mun
svmat obs_mun

sort beta_mun1 
cap drop n
gen n = _n if !missing(beta_mun1)
twoway (scatter beta_mun1 n [w=obs_mun1], msymbol(Oh) msize(tiny) color(navy)) ///
		(scatter beta_mun3 n [w=obs_mun3], msymbol(Oh) msize(tiny) color(maroon)) ///
	, ytitle("Pr(X{subscript:t+1}=Informal | X{subscript:t}=Formal)") xtitle("Municipality (ascending order)") legend(order(1 "No IMSS" 2 "Informal (INEGI)") rows(1) pos(6))
graph export "$directorio/Figuras/transition_prob_mun_inf.pdf", replace

sort beta_mun2 
cap drop n
gen n = _n if !missing(beta_mun2)
twoway (scatter beta_mun2 n [w=obs_mun2], msymbol(Oh) msize(tiny) color(navy)) ///
		(scatter beta_mun4 n [w=obs_mun4], msymbol(Oh) msize(tiny) color(maroon)) ///
	, ytitle("Pr(X{subscript:t+1}=Formal | X{subscript:t}=Informal)") xtitle("Municipality (ascending order)") legend(order(1 "IMSS" 2 "Formal (INEGI)") rows(1) pos(6))
graph export "$directorio/Figuras/transition_prob_mun_for.pdf", replace


*Transition probabilities by occupation 
graph hbar (mean) informal2 if scian1!=0 & informal1==0, over(scian1) ytitle("Pr(X{subscript:t+1}=Informal | X{subscript:t}=Formal)")
graph export "$directorio/Figuras/transition_prob_occ_informal.pdf", replace
graph hbar (mean) formal2 if scian1!=0 & informal1==1, over(scian1) ytitle("Pr(X{subscript:t+1}=Formal | X{subscript:t}=Informal)")
graph export "$directorio/Figuras/transition_prob_occ_formal.pdf", replace

graph hbar (mean) noimss2 if scian1!=0 & noimss1==0, over(scian1) ytitle("Pr(X{subscript:t+1}=No IMSS | X{subscript:t}=IMSS)")
graph export "$directorio/Figuras/transition_prob_occ_noimss.pdf", replace
graph hbar (mean) imss2 if scian1!=0 & noimss1==1, over(scian1) ytitle("Pr(X{subscript:t+1}=IMSS | X{subscript:t}=No IMSS)")
graph export "$directorio/Figuras/transition_prob_occ_imss.pdf", replace
*-------------------------------------------------------------------------------


***********************************************
**** 	Transition probabilities model	  *****
***********************************************

*Semi-elasticities
foreach var of varlist eda1 anios_esc1 hrsocup1 {
	replace `var' = log(`var'+ 1)
}

*Center at the mean	
qui putexcel set "$directorio\Tables\reg_results\meanvardeps.xlsx", sheet("meanvardeps") modify	
local j = 2
foreach var of varlist eda1 anios_esc1 hrsocup1 log_ing1 mean_lum1 median_lum_c {
	qui su `var' if informal1==0
	qui putexcel E`j'=`r(N)'	
	qui su `var' [fw = fac1] if informal1==0
	qui putexcel B`j'=`r(mean)'
	qui putexcel C`j'=`r(sd)'
	qui putexcel D`j'=`r(N)'
	gen `var'_for = `var'-`r(mean)'
	
	qui su `var' if noimss1==0
	qui putexcel J`j'=`r(N)'	
	qui su `var' [fw = fac1] if noimss1==0
	qui putexcel G`j'=`r(mean)'
	qui putexcel H`j'=`r(sd)'
	qui putexcel I`j'=`r(N)'
	gen `var'_imss = `var'-`r(mean)'	
	local j = `j' + 1
}

forvalues i = 1/2 { 
	matrix transition_det_informal`i' = J(7,3,.) 
	matrix transition_det_formal`i' = J(7,3,.) 
	matrix transition_det_noimss`i' = J(7,3,.) 
	matrix transition_det_imss`i' = J(7,3,.) 
}

eststo clear
*For computational purposes since we are only interested in the point estimate we use
eststo : reg informal2 ibn.date1 2.sex1 eda1_for anios_esc1_for hrsocup1_for log_ing1_for 2.t_tra1 median_lum_c_for [fw = fac1] if informal1==0, nocons vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
estadd scalar obs = `obs'
*instead of
*reg informal2 0.informal1#ibn.date1 2.sex1#ibn.date1 ... [fw = fac1], nocons
matrix transition_prob_time = e(b)'

eststo : reg noimss2 ibn.date1 2.sex1 eda1_imss anios_esc1_imss hrsocup1_imss log_ing1_imss 2.t_tra1 median_lum_c_imss [fw = fac1] if noimss1==0, nocons vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
estadd scalar obs = `obs'
matrix transition_prob_time_imss = e(b)'

svmat transition_prob_time
svmat transition_prob_time_imss
gen qr = _n + yq(2005,1) - 1 if _n + yq(2005,1) -1 < yq(2015,4)
replace transition_prob_time1 = . if missing(qr)
replace transition_prob_time_imss1 = . if missing(qr)


twoway (lpolyci transition_prob_time1 qr, clcolor(navy%50) fintensity(inten70)) ///
		(lpolyci transition_prob_time_imss1 qr, clcolor(maroon%50) fintensity(inten70)) ///
		(scatter transition_prob_time1 qr, connect(line) msymbol(Oh) color(navy)) ///
		(scatter transition_prob_time_imss1 qr, connect(line) msymbol(Oh) color(maroon)) ///
		, xtitle("") ytitle("Pr(X{subscript:t+1}=Informal | X{subscript:t}=Formal)") xlabel(180(7)222,format(%tq) labsize(small)) legend(order(5 "Informal (INEGI)" 6 "No IMSS") pos(6) rows(1))
graph export "$directorio/Figuras/transition_prob_time_inf.pdf", replace



eststo : reghdfe informal2 ibn.date1 2.sex1 eda1_for anios_esc1_for hrsocup1_for log_ing1_for 2.t_tra1 median_lum_c_for [fw = fac1] if informal1==0, nocons absorb(municipio1) vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
estadd scalar obs = `obs'
local j = 1
foreach var of varlist sex1 t_tra1 {
	matrix transition_det_informal1[`j',1] = _b[2.`var']
	matrix transition_det_informal1[`j',2] = _b[2.`var'] - invnormal(.975)*_se[2.`var']
	matrix transition_det_informal1[`j',3] = _b[2.`var'] + invnormal(.975)*_se[2.`var'] 
	local j = `j' + 1
}
foreach var of varlist eda1_for anios_esc1_for hrsocup1_for log_ing1_for  median_lum_c_for {
	matrix transition_det_informal1[`j',1] = _b[`var']
	matrix transition_det_informal1[`j',2] = _b[`var'] - invnormal(.975)*_se[`var']
	matrix transition_det_informal1[`j',3] = _b[`var'] + invnormal(.975)*_se[`var'] 
	local j = `j' + 1
}

eststo : reghdfe noimss2 ibn.date1 2.sex1 eda1_imss anios_esc1_imss hrsocup1_imss log_ing1_imss 2.t_tra1 median_lum_c_imss [fw = fac1] if noimss1==0, nocons absorb(municipio1) vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
estadd scalar obs = `obs'
local j = 1
foreach var of varlist sex1 t_tra1 {
	matrix transition_det_noimss1[`j',1] = _b[2.`var']
	matrix transition_det_noimss1[`j',2] = _b[2.`var'] - invnormal(.975)*_se[2.`var']
	matrix transition_det_noimss1[`j',3] = _b[2.`var'] + invnormal(.975)*_se[2.`var'] 
	local j = `j' + 1
}
foreach var of varlist eda1_imss anios_esc1_imss hrsocup1_imss log_ing1_imss  median_lum_c_imss {
	matrix transition_det_noimss1[`j',1] = _b[`var']
	matrix transition_det_noimss1[`j',2] = _b[`var'] - invnormal(.975)*_se[`var']
	matrix transition_det_noimss1[`j',3] = _b[`var'] + invnormal(.975)*_se[`var'] 
	local j = `j' + 1
}

eststo : reghdfe informal2 ibn.date1 2.sex1 eda1_for anios_esc1_for hrsocup1_for log_ing1_for 2.t_tra1 median_lum_c_for [fw = fac1] if informal1==0, absorb(scian1 municipio1) vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
estadd scalar obs = `obs'
local j = 1
foreach var of varlist sex1 t_tra1 {
	matrix transition_det_informal2[`j',1] = _b[2.`var']
	matrix transition_det_informal2[`j',2] = _b[2.`var'] - invnormal(.975)*_se[2.`var']
	matrix transition_det_informal2[`j',3] = _b[2.`var'] + invnormal(.975)*_se[2.`var'] 
	local j = `j' + 1
}
foreach var of varlist eda1_for anios_esc1_for hrsocup1_for log_ing1_for  median_lum_c_for {
	matrix transition_det_informal2[`j',1] = _b[`var']
	matrix transition_det_informal2[`j',2] = _b[`var'] - invnormal(.975)*_se[`var']
	matrix transition_det_informal2[`j',3] = _b[`var'] + invnormal(.975)*_se[`var'] 
	local j = `j' + 1
}
eststo : reghdfe noimss2 ibn.date1 2.sex1 eda1_imss anios_esc1_imss hrsocup1_imss log_ing1_imss 2.t_tra1 median_lum_c_imss [fw = fac1] if noimss1==0, absorb(scian1 municipio1) vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
estadd scalar obs = `obs'
local j = 1
foreach var of varlist sex1 t_tra1 {
	matrix transition_det_noimss2[`j',1] = _b[2.`var']
	matrix transition_det_noimss2[`j',2] = _b[2.`var'] - invnormal(.975)*_se[2.`var']
	matrix transition_det_noimss2[`j',3] = _b[2.`var'] + invnormal(.975)*_se[2.`var'] 
	local j = `j' + 1
}
foreach var of varlist eda1_imss anios_esc1_imss hrsocup1_imss log_ing1_imss  median_lum_c_imss {
	matrix transition_det_noimss2[`j',1] = _b[`var']
	matrix transition_det_noimss2[`j',2] = _b[`var'] - invnormal(.975)*_se[`var']
	matrix transition_det_noimss2[`j',3] = _b[`var'] + invnormal(.975)*_se[`var'] 
	local j = `j' + 1
}

esttab using "$directorio/Tables/reg_results/transition_prob_reg_inf.csv", se r2 ${star} b(a2)  replace keep(2.sex1 eda1* anios_esc1* hrsocup1* log_ing1* 2.t_tra1 median_lum_c*) scalars("obs obs")


*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

*Center at the mean	
qui putexcel set "$directorio\Tables\reg_results\meanvardeps.xlsx", sheet("meanvardeps") modify	
local j = 10
foreach var of varlist eda1 anios_esc1 hrsocup1 log_ing1 mean_lum1 median_lum_c {
	qui su `var' if informal1==1
	qui putexcel E`j'=`r(N)'	
	qui su `var' [fw = fac1] if informal1==1
	qui putexcel B`j'=`r(mean)'
	qui putexcel C`j'=`r(sd)'
	qui putexcel D`j'=`r(N)'
	gen `var'_inf = `var'-`r(mean)'
	
	qui su `var' if noimss1==1
	qui putexcel J`j'=`r(N)'	
	qui su `var' [fw = fac1] if noimss1==1
	qui putexcel G`j'=`r(mean)'
	qui putexcel H`j'=`r(sd)'
	qui putexcel I`j'=`r(N)'
	gen `var'_noimss = `var'-`r(mean)'	
	local j = `j' + 1
}

eststo clear
*For computational purposes since we are only interested in the point estimate we use
eststo : reg formal2 ibn.date1 2.sex1 eda1_inf anios_esc1_inf hrsocup1_inf log_ing1_inf 2.t_tra1 median_lum_c_inf [fw = fac1] if informal1==1, nocons vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
estadd scalar obs = `obs'
*instead of
*reg informal2 1.informal1#ibn.date1 2.sex1#ibn.date1 ... [fw = fac1], nocons
matrix transition_prob_time = e(b)'

eststo : reg imss2 ibn.date1 2.sex1 eda1_noimss anios_esc1_noimss hrsocup1_noimss log_ing1_noimss 2.t_tra1 median_lum_c_noimss [fw = fac1] if noimss1==1, nocons vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
estadd scalar obs = `obs'
matrix transition_prob_time_imss = e(b)'

cap drop transition_prob_time*
cap drop transition_prob_imss*
svmat transition_prob_time
svmat transition_prob_time_imss
replace transition_prob_time1 = . if missing(qr)
replace transition_prob_time_imss1 = . if missing(qr)


twoway (lpolyci transition_prob_time1 qr, clcolor(navy%50) fintensity(inten70)) ///
		(lpolyci transition_prob_time_imss1 qr, clcolor(maroon%50) fintensity(inten70)) ///
		(scatter transition_prob_time1 qr, connect(line) msymbol(Oh) color(navy)) ///
		(scatter transition_prob_time_imss1 qr, connect(line) msymbol(Oh) color(maroon)) ///
		, xtitle("") ytitle("Pr(X{subscript:t+1}=Formal | X{subscript:t}=Informal)") xlabel(180(7)222,format(%tq) labsize(small)) legend(order(5 "Formal (INEGI)" 6 "IMSS") pos(6) rows(1))
graph export "$directorio/Figuras/transition_prob_time_for.pdf", replace



eststo : reghdfe formal2 ibn.date1 2.sex1 eda1_inf anios_esc1_inf hrsocup1_inf log_ing1_inf 2.t_tra1 median_lum_c_inf [fw = fac1] if informal1==1, nocons absorb(municipio1) vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
estadd scalar obs = `obs'
local j = 1
foreach var of varlist sex1 t_tra1 {
	matrix transition_det_formal1[`j',1] = _b[2.`var']
	matrix transition_det_formal1[`j',2] = _b[2.`var'] - invnormal(.975)*_se[2.`var']
	matrix transition_det_formal1[`j',3] = _b[2.`var'] + invnormal(.975)*_se[2.`var'] 
	local j = `j' + 1
}
foreach var of varlist eda1_inf anios_esc1_inf hrsocup1_inf log_ing1_inf  median_lum_c_inf {
	matrix transition_det_formal1[`j',1] = _b[`var']
	matrix transition_det_formal1[`j',2] = _b[`var'] - invnormal(.975)*_se[`var']
	matrix transition_det_formal1[`j',3] = _b[`var'] + invnormal(.975)*_se[`var'] 
	local j = `j' + 1
}

eststo : reghdfe imss2 ibn.date1 2.sex1 eda1_noimss anios_esc1_noimss hrsocup1_noimss log_ing1_noimss 2.t_tra1 median_lum_c_noimss [fw = fac1] if noimss1==1, nocons absorb(municipio1) vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
estadd scalar obs = `obs'
local j = 1
foreach var of varlist sex1 t_tra1 {
	matrix transition_det_imss1[`j',1] = _b[2.`var']
	matrix transition_det_imss1[`j',2] = _b[2.`var'] - invnormal(.975)*_se[2.`var']
	matrix transition_det_imss1[`j',3] = _b[2.`var'] + invnormal(.975)*_se[2.`var'] 
	local j = `j' + 1
}
foreach var of varlist eda1_noimss anios_esc1_noimss hrsocup1_noimss log_ing1_noimss  median_lum_c_noimss {
	matrix transition_det_imss1[`j',1] = _b[`var']
	matrix transition_det_imss1[`j',2] = _b[`var'] - invnormal(.975)*_se[`var']
	matrix transition_det_imss1[`j',3] = _b[`var'] + invnormal(.975)*_se[`var'] 
	local j = `j' + 1
}

eststo : reghdfe formal2 ibn.date1 2.sex1 eda1_inf anios_esc1_inf hrsocup1_inf log_ing1_inf 2.t_tra1 median_lum_c_inf [fw = fac1] if informal1==1, absorb(scian1 municipio1) vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
estadd scalar obs = `obs'
local j = 1
foreach var of varlist sex1 t_tra1 {
	matrix transition_det_formal2[`j',1] = _b[2.`var']
	matrix transition_det_formal2[`j',2] = _b[2.`var'] - invnormal(.975)*_se[2.`var']
	matrix transition_det_formal2[`j',3] = _b[2.`var'] + invnormal(.975)*_se[2.`var'] 
	local j = `j' + 1
}
foreach var of varlist eda1_inf anios_esc1_inf hrsocup1_inf log_ing1_inf median_lum_c_inf {
	matrix transition_det_formal2[`j',1] = _b[`var']
	matrix transition_det_formal2[`j',2] = _b[`var'] - invnormal(.975)*_se[`var']
	matrix transition_det_formal2[`j',3] = _b[`var'] + invnormal(.975)*_se[`var'] 
	local j = `j' + 1
}

eststo : reghdfe imss2 ibn.date1 2.sex1 eda1_noimss anios_esc1_noimss hrsocup1_noimss log_ing1_noimss 2.t_tra1 median_lum_c_noimss [fw = fac1] if noimss1==1, absorb(scian1 municipio1) vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
estadd scalar obs = `obs'
local j = 1
foreach var of varlist sex1 t_tra1 {
	matrix transition_det_imss2[`j',1] = _b[2.`var']
	matrix transition_det_imss2[`j',2] = _b[2.`var'] - invnormal(.975)*_se[2.`var']
	matrix transition_det_imss2[`j',3] = _b[2.`var'] + invnormal(.975)*_se[2.`var'] 
	local j = `j' + 1
}
foreach var of varlist eda1_noimss anios_esc1_noimss hrsocup1_noimss log_ing1_noimss  median_lum_c_noimss {
	matrix transition_det_imss2[`j',1] = _b[`var']
	matrix transition_det_imss2[`j',2] = _b[`var'] - invnormal(.975)*_se[`var']
	matrix transition_det_imss2[`j',3] = _b[`var'] + invnormal(.975)*_se[`var'] 
	local j = `j' + 1
}

esttab using "$directorio/Tables/reg_results/transition_prob_reg_for.csv", se r2 ${star} b(a2)  replace keep(2.sex1 eda1* anios_esc1* hrsocup1* log_ing1* 2.t_tra1 median_lum_c*) scalars("obs obs")


***********       CoefPlot		***************
***********************************************
foreach var in transition_det_formal transition_det_informal transition_det_imss transition_det_noimss {
	forvalues i = 1/2 {
		mat rownames `var'`i' =  "Woman" "Log(Age)" "Log(Schooling)" "Log(Weekly hours)" "Log(hourly wage)" "Two jobs" "{&Delta} Median luminosity" 
	}
	coefplot (matrix(`var'1[,1]), offset(0.06) ci((`var'1[,2] `var'1[,3])) msize(large) ciopts(lcolor(gs4))) ///
	(matrix(`var'2[,1]), offset(-0.06) ci((`var'2[,2] `var'2[,3])) msize(large) ciopts(lcolor(gs4))) , ///
	legend(order(2 "Municipality FE" 4 "Municipality + Occupation FE") pos(6) rows(1))  xline(0)  graphregion(color(white)) 
	graph export "$directorio/Figuras//`var'.pdf", replace

}



***********************************************
**** 	Characteristics switchers		  *****
***********************************************

*Define transitions
gen inf_inf = (informal1==1 & informal2==1) if !missing(informal1) & !missing(informal2) 
gen inf_for = (informal1==1 & informal2==0) if !missing(informal1) & !missing(informal2)
gen for_inf = (informal1==0 & informal2==1) if !missing(informal1) & !missing(informal2)
gen for_for = (informal1==0 & informal2==0) if !missing(informal1) & !missing(informal2)

gen noimss_noimss = (noimss1==1 & noimss2==1) if !missing(noimss1) & !missing(noimss2) 
gen imss_noimss = (noimss1==1 & noimss2==0) if !missing(noimss1) & !missing(noimss2)
gen noimss_imss = (noimss1==0 & noimss2==1) if !missing(noimss1) & !missing(noimss2)
gen imss_imss = (noimss1==0 & noimss2==0) if !missing(noimss1) & !missing(noimss2)



 
eststo clear
eststo : reghdfe inf_for 2.sex1 eda1 anios_esc1 hrsocup1 log_ing1 2.t_tra1 median_lum_c i.scian1 ibn.date1 [fw = fac1], noabsorb vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
su inf_for if e(sample)==1
estadd scalar DepVarMean = `r(mean)'
estadd scalar obs = `obs'

eststo : reghdfe inf_for 2.sex1 eda1 anios_esc1 hrsocup1 log_ing1 2.t_tra1 median_lum_c i.scian1 ibn.date1 [fw = fac1], absorb(municipio1) vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
su inf_for if e(sample)==1
estadd scalar DepVarMean = `r(mean)'
estadd scalar obs = `obs'


eststo : reghdfe noimss_imss 2.sex1 eda1 anios_esc1 hrsocup1 log_ing1 2.t_tra1 median_lum_c i.scian1 ibn.date1 [fw = fac1], noabsorb vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
su noimss_imss if e(sample)==1
estadd scalar DepVarMean = `r(mean)'
estadd scalar obs = `obs'

eststo : reghdfe noimss_imss 2.sex1 eda1 anios_esc1 hrsocup1 log_ing1 2.t_tra1 median_lum_c i.scian1 ibn.date1 [fw = fac1], absorb(municipio1) vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
su noimss_imss if e(sample)==1
estadd scalar DepVarMean = `r(mean)'
estadd scalar obs = `obs'

********************************************************************************

eststo : reghdfe for_inf 2.sex1 eda1 anios_esc1 hrsocup1 log_ing1 2.t_tra1 median_lum_c i.scian1 ibn.date1 [fw = fac1], noabsorb vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
su for_inf if e(sample)==1
estadd scalar DepVarMean = `r(mean)'
estadd scalar obs = `obs'

eststo : reghdfe for_inf 2.sex1 eda1 anios_esc1 hrsocup1 log_ing1 2.t_tra1 median_lum_c i.scian1 ibn.date1 [fw = fac1], absorb(municipio1) vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
su for_inf if e(sample)==1
estadd scalar DepVarMean = `r(mean)'
estadd scalar obs = `obs'

eststo : reghdfe imss_noimss 2.sex1 eda1 anios_esc1 hrsocup1 log_ing1 2.t_tra1 median_lum_c i.scian1 ibn.date1 [fw = fac1], noabsorb vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
su imss_noimss if e(sample)==1
estadd scalar DepVarMean = `r(mean)'
estadd scalar obs = `obs'

eststo : reghdfe imss_noimss 2.sex1 eda1 anios_esc1 hrsocup1 log_ing1 2.t_tra1 median_lum_c i.scian1 ibn.date1 [fw = fac1], absorb(municipio1) vce(robust)
qui count if e(sample)==1
local obs = `r(N)'
su imss_noimss if e(sample)==1
estadd scalar DepVarMean = `r(mean)'
estadd scalar obs = `obs'


esttab using "$directorio/Tables/reg_results/characteristics_switchers.csv", se r2 ${star} b(a2)  replace keep(2.sex1 eda1 anios_esc1 hrsocup1 log_ing1 2.t_tra1 median_lum_c) scalars("DepVarMean DepVarMean" "obs obs")


keep inf_for for_inf imss_noimss noimss_imss fac1 sex1 eda1 anios_esc1 hrsocup1 log_ing1 t_tra1 median_lum_c scian1 date1 municipio1
drop if missing(inf_for) & missing(for_inf) & missing(imss_noimss) & missing(noimss_imss)
export delimited using "$directorio\_aux\switchers.csv", nolabel replace