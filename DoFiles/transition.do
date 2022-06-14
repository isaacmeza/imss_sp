
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: June. 10, 2022
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

gen byte noatencion_medica = !inlist(imssissste,1,2,3) if !inlist(imssissste,0,5,6) & !missing(imssissste)
gen byte informal_hussmann = (mh_fil2==1) if mh_fil2!=0 & !missing(mh_fil2)

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


keep id date n_ent municipio class_trab informal noimss noatencion_medica informal_hussmann mean_lum median_lum sex eda anios_esc hrsocup log_ing t_tra scian fac

reshape wide class_trab informal noimss noatencion_medica informal_hussmann mean_lum median_lum sex eda anios_esc hrsocup log_ing t_tra scian municipio date fac, i(id) j(n_ent)

order id date* fac* municipio* class_trab* informal1 informal2 informal3 informal4 informal5 noimss* noatencion_medica* informal_hussmann* mean_lum* median_lum* sex* eda* anios_esc* hrsocup* log_ing* t_tra* scian* 


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


*Probability stack plot
tab class_trab1 class_trab2 [fw = fac1], row matrow(row) matcol(col) matcell(MT)
catplot class_trab2 class_trab1 [fw = fac1], percent(class_trab1) stack asyvars ///
	ytitle("Percent") graphregion(color(white)) legend(pos(6) rows(1)) note("Observations : `r(N)'", size(vsmall))
graph export "$directorio/Figuras/transition_matrix_class.pdf", replace
	
tab informal1 informal2 [fw = fac1], row matrow(row) matcol(col) matcell(MT)
catplot informal2 informal1 [fw = fac1], percent(informal1) stack asyvars ///
	ytitle("Percent") graphregion(color(white)) legend(pos(6) rows(1)) note("Observations : `r(N)'", size(vsmall))
graph export "$directorio/Figuras/transition_matrix_inf.pdf", replace

tab noimss1 noimss2 [fw = fac1], row matrow(row) matcol(col) matcell(MT)
catplot noimss2 noimss1 [fw = fac1], percent(noimss1) stack asyvars ///
	ytitle("Percent") graphregion(color(white)) legend(pos(6) rows(1)) note("Observations : `r(N)'", size(vsmall))
graph export "$directorio/Figuras/transition_matrix_noimss.pdf", replace
	

*-------------------------------------------------------------------------------

*Transition probabilities by municipality 
	
matrix beta_mun = J(1790,2,.)

local j = 1
levelsof municipio1, local(levels) 
foreach l of local levels {
	if `j'==1 {
		di " "
		_dots 0, title(Loop through replications) reps(1790)
	}
	qui su informal2 [fw = fac1] if informal1==1 & municipio1==`l', meanonly
	cap matrix beta_mun[`j',1] = `r(mean)'
	
	qui su noimss2 [fw = fac1] if noimss1==1 & municipio1==`l', meanonly
	cap matrix beta_mun[`j',2] = `r(mean)'
	noi _dots `j' 0
	local j = `j' + 1
}

svmat beta_mun
sort beta_mun1 
cap drop n
gen n = _n if !missing(beta_mun1)
twoway (scatter beta_mun1 n, msymbol(Oh) msize(tiny) color(navy)) ///
		(scatter beta_mun2 n, msymbol(Oh) msize(tiny) color(maroon)) ///
	, ytitle("Pr(X{subscript:t+1}=Informal | X{subscript:t}=Informal)") xtitle("Municipality (ascending order)") legend(order(1 "Informal" 2 "No IMSS") rows(1) pos(6))
graph export "$directorio/Figuras/transition_prob_mun.pdf", replace

*Transition probabilities by occupation 
graph hbar (mean) informal2 if scian1!=0 & informal1==1, over(scian1) ytitle("Pr(X{subscript:t+1}=Informal | X{subscript:t}=Informal)")
graph export "$directorio/Figuras/transition_prob_occ_informal.pdf", replace

graph hbar (mean) noimss2 if scian1!=0 & noimss1==1, over(scian1) ytitle("Pr(X{subscript:t+1}=No IMSS | X{subscript:t}=No IMSS)")
graph export "$directorio/Figuras/transition_prob_occ_noimss.pdf", replace

*-------------------------------------------------------------------------------


***********************************************
**** 	Transition probabilities model	  *****
***********************************************

*Center at the mean	
qui putexcel set "$directorio\Tables\reg_results\meanvardeps.xlsx", sheet("meanvardeps") modify	
local j = 2
foreach var of varlist eda1 anios_esc1 hrsocup1 log_ing1 mean_lum1 median_lum1 {
	su `var' [fw = fac1], meanonly
	qui putexcel B`j'=`r(mean)'
	replace `var' = `var'-`r(mean)'
	local j = `j' + 1
}


*Define transitions
gen inf_inf = (informal1==1 & informal2==1) if !missing(informal1) & !missing(informal2) 
gen inf_for = (informal1==1 & informal2==0) if !missing(informal1) & !missing(informal2)
gen for_inf = (informal1==0 & informal2==1) if !missing(informal1) & !missing(informal2)
gen for_for = (informal1==0 & informal2==0) if !missing(informal1) & !missing(informal2)

 
eststo clear
*For computational purposes since we are only interested in the point estimate we use
eststo : reg informal2 ibn.date1 2.sex1 eda1 anios_esc1 hrsocup1 log_ing1 2.t_tra1 median_lum1 [fw = fac1] if informal1==1, nocons vce(robust)
*instead of
*reg informal2 1.informal1#ibn.date1 2.sex1#ibn.date1 ... [fw = fac1], nocons
matrix transition_prob_time = e(b)'

eststo : reg noimss2 ibn.date1 2.sex1 eda1 anios_esc1 hrsocup1 log_ing1 2.t_tra1 median_lum1 [fw = fac1] if noimss1==1, nocons vce(robust)
matrix transition_prob_time_imss = e(b)'

svmat transition_prob_time
svmat transition_prob_time_imss
gen qr = _n + yq(2005,1) - 1 if _n + yq(2005,1) -1 <= yq(2018,1)
replace transition_prob_time1 = . if missing(qr)
replace transition_prob_time_imss1 = . if missing(qr)


twoway (lpolyci transition_prob_time1 qr, clcolor(navy%50) fintensity(inten70)) ///
		(lpolyci transition_prob_time_imss1 qr, clcolor(maroon%50) fintensity(inten70)) ///
		(scatter transition_prob_time1 qr, connect(line) msymbol(Oh) color(navy)) ///
		(scatter transition_prob_time_imss1 qr, connect(line) msymbol(Oh) color(maroon)) ///
		, xtitle("") ytitle("Pr(X{subscript:t+1}=Informal | X{subscript:t}=Informal)") xlabel(180(15)232,format(%tq) labsize(small)) legend(order(5 "Informal" 6 "No IMSS") pos(6) rows(1))
graph export "$directorio/Figuras/transition_prob_time.pdf", replace



eststo : reghdfe informal2 ibn.date1 2.sex1 eda1 anios_esc1 hrsocup1 log_ing1 2.t_tra1 median_lum1 [fw = fac1] if informal1==1, nocons absorb(municipio1) vce(robust)
eststo : reghdfe noimss2 ibn.date1 2.sex1 eda1 anios_esc1 hrsocup1 log_ing1 2.t_tra1 median_lum1 [fw = fac1] if noimss1==1, nocons absorb(municipio1) vce(robust)

eststo : reghdfe informal2 ibn.date1 2.sex1 eda1 anios_esc1 hrsocup1 log_ing1 2.t_tra1 median_lum1 [fw = fac1] if informal1==1, absorb(scian1 municipio1) vce(robust)
eststo : reghdfe noimss2 ibn.date1 2.sex1 eda1 anios_esc1 hrsocup1 log_ing1 2.t_tra1 median_lum1 [fw = fac1] if noimss1==1, absorb(scian1 municipio1) vce(robust)

esttab using "$directorio/Tables/reg_results/transition_prob_reg.csv", se r2 ${star} b(a2)  replace keep(2.sex1 eda1 anios_esc1 hrsocup1 log_ing1 2.t_tra1 median_lum1)
