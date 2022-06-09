
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: June. 06, 2022
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Cleaning of ENE dataset

*******************************************************************************/
*/

*Variables to keep in the analysis
local vars sex eda e_con anios_esc hrsocup ingocup ing_x_hrs imssissste p5b p3 clase1 tue2 


foreach qr in 2 3 4 {
	di "`qr'"
	qui {
	import dbase using "C:\Users\isaac\Dropbox\Statistics\P27\IMSS\Data Original\ENE_ENOE\ENE\ene_`qr'00_dbf\ene`qr'00.dbf", clear

	rename *, lower
	keep ent mun fac `vars' 
	rename p3 t_tra
	gen int year = 2000 
	gen int quarter = `qr'

	*Cleaning
	destring t_tra, replace
	replace t_tra = 2 if t_tra==3 

	destring ent, replace
	destring mun, replace

	destring sex, replace
	destring eda, replace

	replace p5b = substr(p5b,1,2)
	destring p5b, replace
	gen scian = 23 if inrange(p5b,1,4)
	replace scian = 24 if inrange(p5b,5,10)
	replace scian = 25 if inrange(p5b,11,59)
	replace scian = 26 if inlist(p5b,60)
	replace scian = 27 if inlist(p5b,61)
	replace scian = 28 if inlist(p5b,62,63)
	replace scian = 29 if inlist(p5b,64,65)
	replace scian = 30 if inlist(p5b,66,67)
	replace scian = 31 if inrange(p5b,68,74) | inlist(p5b, 88)
	replace scian = 32 if inlist(p5b,99)
	drop p5b

	label define scian 23 "Agropecuario" 24 "Mineria" 25 "Industria Manufacturera" 26 "Construccion" 27 "Electricidad, Gas y Agua" 28 "Comercio, Restaurantes y Hoteles" 29 "Transporte Almacenamiento y Comunicaciones" 30 "Servicios Financieros" 31 "Servicios Comunales, Sociales y Personales" 32 "Insuficientemente Especificado"
	label values scian scian

	compress
	tempfile temp`qr'00
	save `temp`qr'00'
	}
}


foreach year in 01 02 03 04 {
	foreach qr in 1 2 3 4 {
		di "`qr'`year'"
		qui {
		import dbase using "C:\Users\isaac\Dropbox\Statistics\P27\IMSS\Data Original\ENE_ENOE\ENE\ene_`qr'`year'_dbf\ene`qr'`year'.dbf", clear

		rename *, lower
		keep ent mun fac `vars' 
		rename p3 t_tra
		gen int year = 2000 + `year'
		gen int quarter = `qr'

		*Cleaning
		destring t_tra, replace
		replace t_tra = 2 if t_tra==3 

		destring ent, replace
		destring mun, replace

		destring sex, replace
		destring eda, replace

		replace p5b = substr(p5b,1,2)
		destring p5b, replace
		gen scian = 23 if inrange(p5b,1,4)
		replace scian = 24 if inrange(p5b,5,10)
		replace scian = 25 if inrange(p5b,11,59)
		replace scian = 26 if inlist(p5b,60)
		replace scian = 27 if inlist(p5b,61)
		replace scian = 28 if inlist(p5b,62,63)
		replace scian = 29 if inlist(p5b,64,65)
		replace scian = 30 if inlist(p5b,66,67)
		replace scian = 31 if inrange(p5b,68,74) | inlist(p5b, 88)
		replace scian = 32 if inlist(p5b,99)
		drop p5b

		label define scian 23 "Agropecuario" 24 "Mineria" 25 "Industria Manufacturera" 26 "Construccion" 27 "Electricidad, Gas y Agua" 28 "Comercio, Restaurantes y Hoteles" 29 "Transporte Almacenamiento y Comunicaciones" 30 "Servicios Financieros" 31 "Servicios Comunales, Sociales y Personales" 32 "Insuficientemente Especificado"
		label values scian scian

		compress
		tempfile temp`qr'`year'
		save `temp`qr'`year''
		}
	}
}


use `temp200', clear
foreach qr in 3 4 {
	append using `temp`qr'00'
}
foreach year in 01 02 03 04 {
	foreach qr in 1 2 3 4 {
		append using `temp`qr'`year''
	}
}
compress
save "$directorio\Data Created\ene.dta", replace
