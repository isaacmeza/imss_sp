
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	June. 22, 2022
* Last date of modification: June. 29, 2022
* Modifications: Recover coordinates of clinics
* Files used:     
		- 
* Files created:  

* Purpose: Cleaning clues dataset

*******************************************************************************/
*/

use "$directorio\Data Private\clues_1220.dta", clear

keep CLUES CLAVEDELAENTIDAD CLAVEDELMUNICIPIO CLAVEDELAINSTITUCION NOMBRETIPOESTABLECIMIENTO TOTALDECONSULTORIOS TOTALDECAMAS ESTATUSDEOPERACION FECHADEINICIODEOPERACION NIVELATENCION ULTIMOMOVIMIENTO FECHAULTIMOMOVIMIENTO LATITUD LONGITUD
rename *, lower

gen mun = clavedelaentidad + clavedelmunicipio 
destring mun, gen(cvemun)
drop mun clavedelaentidad clavedelmunicipio

foreach var of varlist clavedelainstitucion nombretipoestablecimiento estatusdeoperacion nivelatencion {
	encode `var', gen(`var'_)
	drop `var'
	rename `var'_ `var'
}

foreach var of varlist fechadeiniciodeoperacion fechaultimomovimiento {
	gen d_`var' = date(`var', "YMD")
	drop `var'
	rename d_`var' `var'
	format `var' %td
}

destring latitud, replace force
destring longitud, replace force

order clues cvemun clavedelainstitucion nombretipoestablecimiento estatusdeoperacion nivelatencion totaldeconsultorios totaldecamas fechadeiniciodeoperacion fechaultimomovimiento ultimomovimiento latitud longitud

preserve
keep if inrange(lat,15,33)
keep if inrange(lon,-122,-84)

gen date04 = 1 if ((yq(2004,1)>=qofd(fechadeinicio) | missing(fechadeinicio)) & (ultimomovimiento!="BAJA" | yq(2004,1)<=qofd(fechaultimo)))

gen date07 = 1 if ((yq(2007,1)>=qofd(fechadeinicio) | missing(fechadeinicio)) & (ultimomovimiento!="BAJA" | yq(2007,1)<=qofd(fechaultimo)))

save  "_aux\clues_lat_lon.dta", replace	
restore

********************************************************************************
*Construct instruments

forvalues year = 2000/2019 {
	forvalues quarter = 1/4 {
		di "`year'" "-" "`quarter'"
		preserve
		qui drop if ((yq(`year',`quarter')<qofd(fechadeinicio) & !missing(fechadeinicio)) | (ultimomovimiento=="BAJA" & yq(`year',`quarter')>qofd(fechaultimo)))

		qui tab clavedelainstitucion if inlist(clavedelainstitucion,6,7,8,16,17), gen(clave_institucion_)
		qui tab nombretipoestablecimiento, gen(tipo_establecimiento_)
		qui tab estatusdeoperacion if inlist(estatusdeoperacion,1,2), gen(estatus_operacion_)
		qui tab nivelatencion, gen(nivel_atencion_)
		qui gen total_clues = 1

		qui collapse (sum) clave_institucion_* (sum) tipo_establecimiento_* (sum) nivel_atencion_* (sum) totaldeconsultorios (sum) totaldecamas (sum) total_clues , by(cvemun)

		qui gen date = yq(`year',`quarter')
		format date %tq
		tempfile temp`year'`quarter'
		qui save `temp`year'`quarter''
		restore
	}
}

clear
set obs 1
forvalues year = 2000/2019 {
	forvalues quarter = 1/4 {
		append using `temp`year'`quarter''
	}
}
drop if missing(cvemun)
sort cvemun date

save  "Data Created\clues.dta", replace	