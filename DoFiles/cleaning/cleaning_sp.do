
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

* Purpose: SP cleaning

*******************************************************************************/
*/

import excel "Data Original\SP\BeneficiariosProteccionSocialSalud.xlsx", sheet("Datos") cellrange(A3:AS2470) clear

drop B C D E

rename (A F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS) (cvemun ind_H2004 ind_M2004 ///
ind_H2005 ind_M2005 ///
ind_H2006 ind_M2006 ///
ind_H2007 ind_M2007 ///
ind_H2008 ind_M2008 ///
ind_H2009 ind_M2009 ///
ind_H2010 ind_M2010 ///
ind_H2011 ind_M2011 /// 
ind_H2012 ind_M2012 ///
ind_H2013 ind_M2013 ///
ind_H2014 ind_M2014 ///
ind_H2015 ind_M2015 ///
ind_H2016 ind_M2016 ///
ind_H2017 ind_M2017 ///
ind_H2018m6 ind_M2018m6 ///
ind_H2018m9 ind_M2018m9 ///
ind_H2018 ind_M2018 ///
ind_H2019m3 ind_M2019m3 ///
ind_H2019m6 ind_M2019m6 ///
ind_H2019 ind_M2019)

drop ind_H2018m6 ind_M2018m6 ind_H2018m9 ind_M2018m9 ind_H2019m3 ind_M2019m3 ind_H2019m6 ind_M2019m6 

reshape long ind_H ind_M, i(cvemun) j(year)

destring cvemun, replace

tempfile temp_sp
save `temp_sp'


local i = 1
foreach dtaset in Beneficiarios0_12anosSPSS Beneficiarios12_18anosSPSS Beneficiarios18_30anosSPSS Beneficiarios65anosedad_más_SPSS {

	di "`dtaset'"
	
	import excel "C:\Users\isaac\Dropbox\Statistics\P27\IMSS\Data Original\SP\\`dtaset'.xlsx", sheet(2012) firstrow case(lower) clear
		
	rename (pormpio) (cvemun)
	destring cvemun, replace
	gen year = 2012
	foreach var of varlist edad* {
		rename `var' ind_`var'
	}
	cap drop total
	drop clave_edo nombreestado clave_mpio descripciónmun 
	drop if missing(cvemun) | missing(sexommujerhhombre)
	qui reshape wide ind_*, i(cvemun) j(sexommujerhhombre) string

	tempfile temp_`i'
	save `temp_`i''
		
	foreach sheet in  "2013" "2014" "2015" "2016" "2017" "diciembre 2018" "noviembre 2019" {
		
		di "`sheet'"
		
		import excel "C:\Users\isaac\Dropbox\Statistics\P27\IMSS\Data Original\SP\\`dtaset'.xlsx", sheet(`sheet') firstrow case(lower) clear
		
		rename (pormpio) (cvemun)
		destring cvemun, replace
		gen year = substr("`sheet'",-4,.)
		destring year, replace
		foreach var of varlist edad* {
			rename `var' ind_`var'
		}
		cap drop total
		drop clave_edo nombreestado clave_mpio descripciónmun 
		drop if missing(cvemun) | missing(sexommujerhhombre)		
		qui reshape wide ind_*, i(cvemun) j(sexommujerhhombre) string
		
		append using `temp_`i''
		tempfile temp_`i'
		save `temp_`i''
	}

	local i = `i' + 1
}


use `temp_sp', clear
forvalues i = 1/4 {
	merge 1:1 cvemun year using `temp_`i'', nogen
}
keep cvemun year ind*
gen quarter = 4

*Pool together CDMX
replace cvemun = 9000 if inrange(cvemun,9000,9999)
collapse (sum) ind*, by(cvemun year)

save  "C:\Users\isaac\Dropbox\Statistics\P27\IMSS\Data Created\beneficiarios_sp_2004_2019.dta" , replace
