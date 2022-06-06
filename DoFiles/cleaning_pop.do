
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

* Purpose: Population cleaning

*******************************************************************************/
*/

import delimited "C:\Users\isaac\Dropbox\Statistics\P27\IMSS\Data Original\CONEVAL\Indicadores_municipales_sabana_DA.csv", clear 

rename (clave_mun pobtot_00 pobtot_05) (cvemun pobtot2000 pobtot2005)
keep cvemun pobtot2000 pobtot2005
tempfile temp_00
save `temp_00'

import delimited "C:\Users\isaac\Dropbox\Statistics\P27\IMSS\Data Original\CONEVAL\indicadores de pobreza municipal_2010.csv", clear 

rename (clave_municipio poblacion) (cvemun pobtot2010)
destring pobtot, replace ignore(",") force
keep cvemun pobtot
tempfile temp_10
save `temp_10'

import delimited "C:\Users\isaac\Dropbox\Statistics\P27\IMSS\Data Original\CONEVAL\indicadores de pobreza municipal_2015.csv", clear 

rename (clave_municipio poblacion) (cvemun pobtot2015)
destring pobtot, replace ignore(",") force
keep cvemun pobtot
tempfile temp_15
save `temp_15'

import delimited "C:\Users\isaac\Dropbox\Statistics\P27\IMSS\Data Original\CONEVAL\indicadores de pobreza municipal_2020.csv", clear 

rename (clave_municipio poblacion) (cvemun pobtot2020)
destring pobtot, replace ignore(",") force
keep cvemun pobtot


foreach yr in "00" "10" "15" {
	merge 1:1 cvemun using `temp_`yr'', nogen
}

reshape long pobtot, i(cvemun) j(year)


*Pool together CDMX
replace cvemun = 9000 if inrange(cvemun,9000,9999)
collapse (sum) pobtot, by(cvemun year)

save  "C:\Users\isaac\Dropbox\Statistics\P27\IMSS\Data Created\population.dta" , replace