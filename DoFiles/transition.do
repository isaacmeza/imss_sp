
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


keep id date n_ent municipio class_trab informal noimss noatencion_medica informal_hussmann sex eda anios_esc hrsocup log_ing t_tra scian fac

reshape wide class_trab informal noimss noatencion_medica informal_hussmann sex eda anios_esc hrsocup log_ing t_tra scian municipio date fac, i(id) j(n_ent)

order id date* fac* municipio* class_trab* informal1 informal2 informal3 informal4 informal5 noimss* noatencion_medica* informal_hussmann* sex* eda* anios_esc* hrsocup* log_ing* t_tra* scian* 


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



***********************************************
**** 	Transition probabilities		  *****
***********************************************


*Probability stack plot
tab class_trab1 class_trab2 [fw = fac1], row matrow(row) matcol(col) matcell(MT)
catplot class_trab2 class_trab1 [fw = fac1], percent(class_trab1) stack asyvars ///
	ytitle("Percent") graphregion(color(white)) legend(pos(6) rows(1)) 
	
	
tab informal1 informal2 [fw = fac1], row matrow(row) matcol(col) matcell(MT)
catplot informal2 informal1 [fw = fac1], percent(informal1) stack asyvars ///
	ytitle("Percent") graphregion(color(white)) legend(pos(6) rows(1)) 
	

*-------------------------------------------------------------------------------


*Center at the mean	
foreach var of varlist eda1 anios_esc1 hrsocup1 log_ing1 {
	su `var' [fw = fac1]
	replace `var' = `var'-`r(mean)'
}


*Define transitions
gen inf_inf = (informal1==1 & informal2==1) if !missing(informal1) & !missing(informal2) 
gen inf_for = (informal1==1 & informal2==0) if !missing(informal1) & !missing(informal2)
gen for_inf = (informal1==0 & informal2==1) if !missing(informal1) & !missing(informal2)
gen for_for = (informal1==0 & informal2==0) if !missing(informal1) & !missing(informal2)


*-----------------------
matrix beta = J(1806,1,.)
forvalues j = 1/1806 {

qui cap reg informal2 1.informal1  [fw = fac1] if municipio1==`j'	, nocons
cap matrix beta[`j',1] = _b[1.informal1]
}

svmat beta

sort beta 
cap drop n
gen n = _n if !missing(beta)
scatter beta n, msymbol(Oh) msize(tiny)
*-----------------------

reg inf_inf ibn.date1 [fw = fac1], nocons
reg inf_inf  [fw = fac1]


reg informal2 1.informal1, nocons

reg informal2 if informal1==1
reg inf_inf if informal1==1 
 
reg informal2 1.informal1#ibn.date1 [fw = fac1], nocons
reg informal2 1.informal1#ibn.date1 1.informal1#2.sex1 1.informal1#c.eda1 1.informal1#c.anios_esc1 1.informal1#c.hrsocup1 1.informal1#c.log_ing1 1.informal1#2.t_tra1 [fw = fac1], nocons

reghdfe informal2 1.informal1#ibn.date1 [fw = fac1], absorb(municipio1) nocons
reghdfe informal2 1.informal1#ibn.date1 1.informal1#2.sex1 1.informal1#c.eda1 1.informal1#c.anios_esc1 1.informal1#c.hrsocup1 1.informal1#c.log_ing1 1.informal1#2.t_tra1  [fw = fac1], absorb(municipio1) nocons

