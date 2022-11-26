/* ----------------------------------------------------------------------------
						  Effects of Seguro Popular
					Ph.D. Enrique Seira & MSc. Isaac Meza

    Code author: Roberto González
	Date: August 1, 2022
	
	Code modifications: 
		1. 
	Most recent modifications: 
	
	Code Objective: Make table of social health security beneficiaries
	
	Files used:
		Do Files:
			- 04_asegurados_imss.do
		Data sets:
			- 
	
	Files produced:
---------------------------------------------------------------------------- */

#delimit ;

// Control which parts of the script to run
local prep_2000 = 0 ;
local prep_2005 = 0 ;
local prep_2010 = 0 ;
local prep_2015 = 0 ;
local prep_2020 = 0 ;

/* ----------------------------------------------------------------------------
						Prepare data for year 2000
---------------------------------------------------------------------------- */
if (`prep_2000' == 1) {;

/* ----------------------------------------------------------------------------
					APPEND DATA FROM ALL 32 STATES
---------------------------------------------------------------------------- */


#delimit ; 

	/* Read in data from the census and save as dta for appending data from all 
	states */
	local datasets : dir "$directorio/Data Original/censo_pob_viv_2000" files "*.DBF", respectcase ;
	
	foreach file of local datasets { ;
		import dbase "$directorio/Data Original/censo_pob_viv_2000/`file'", case(lower) clear ;
		drop dis* causadis-edamora ;
		save "$directorio/Data Original/censo_pob_viv_2000/`file'.dta", replace ;
	} ;
	
	// Create an empty file in which to append all dta converted files
	clear ;
	save "$directorio/Data Created/derechohabiencia_2000.dta", emptyok replace ;
	
	// Append all files
	use "$directorio/Data Created/derechohabiencia_2000.dta", clear ;
	local benef : dir "$directorio/Data Original/censo_pob_viv_2000" files "*.dta", respectcase ;
		
	foreach dataset of local benef { ;
		append using "$directorio/Data Original/censo_pob_viv_2000/`dataset'" ;
		compress ;
		save "$directorio/Data Created/derechohabiencia_2000.dta", replace ;
	} ;

/* ----------------------------------------------------------------------------
								CLEAN VARIABLES
---------------------------------------------------------------------------- */

	// Read in dataset
	use "$directorio/Data Created/derechohabiencia_2000.dta", clear ;
	
	keep numviv imss issste pemex otrins_v notieder factor ;

	// Rename notieder var to a meaningful name (not being beneficiary)
	cap ren notieder no_derechohab ;
	
	// Make variables double to clean easily
	destring imss issste pemex otrins_v no_derechohab factor, replace ;
	
	// Clean the variables related to providers of security
	cap gen double no_se_sabe_derechohab = (imss == 9) ;
	
	replace imss = (imss == 1) ;
	
	foreach var of varlist issste pemex otrins_v no_derechohab { ;
		replace `var' = 1 if !missing(`var') ;
		replace `var' = 0 if `var' != 1 ;
	} ;
	
	foreach var of varlist imss issste pemex otrins_v no_derechohab 
	no_se_sabe_derechohab { ;
		replace `var' = factor*`var' ;
	} ;
	
	// Generate labels for the institution names to appear in the graph
	rename (imss issste pemex otrins_v no_derechohab no_se_sabe_derechohab) (institution#), addnumber(1) ;
	gen id = _n ;
	reshape long institution, i(id) ;
	label define _j 1 "IMSS" 2 "ISSSTE" 3 "PEMEX" 4 "Otra" 5 "None" ;
	label values _j _j ;
	
	collapse (rawsum) institution, by(_j) ;
	
	egen total = sum(institution) ;
	gen frac = 100*institution/total ;
	
	gen year = 2000 ;
	
	gen nombre = "." ;
	replace nombre = "IMSS" if _j == 1 ;
	replace nombre = "ISSSTE" if _j == 2 ;
	replace nombre = "PEMEX" if _j == 3 ;
	replace nombre = "Otra" if _j == 4 ;
	replace nombre = "None" if _j == 5 ;
	
	keep nombre year frac ;
	
	save "$directorio/Data Created/derechohabiencia_2000.dta", replace ;
};
	
/* ----------------------------------------------------------------------------
						Prepare data for year 2005
---------------------------------------------------------------------------- */

if (`prep_2005' == 1) { ;
/* ----------------------------------------------------------------------------
					APPEND DATA FROM ALL 32 STATES
---------------------------------------------------------------------------- */

	/* Read in data from the census and save as dta for appending data from all 
	states */
	local datasets : dir "$directorio/Data Original/conteo_pob_viv_2005" files "*.DBF", respectcase ;
	
	foreach file of local datasets { ;
		import dbase "$directorio/Data Original/conteo_pob_viv_2005/`file'", case(lower) clear ;
		keep imss issste pemex segu_pop inst_pri otra_ins sin_dere ;
		ren (sin_dere otra_ins) (notieder otrins_v) ;
		
		gen factor = 1 ;
		
		destring otrins_v, replace ;
		replace otrins_v = 1 if inrange(otrins_v, 1, 9) ;
		
		save "$directorio/Data Original/conteo_pob_viv_2005/`file'.dta", replace ;
	} ;
	
	// Create an empty file in which to append all dta converted files
	clear ;
	save "$directorio/Data Created/derechohabiencia_2005.dta", emptyok replace ;
	
	// Append all files
	use "$directorio/Data Created/derechohabiencia_2005", clear ;
	local benef : dir "$directorio/Data Original/conteo_pob_viv_2005" files "*.dta", respectcase ;
		
	foreach dataset of local benef { ;
		append using "$directorio/Data Original/conteo_pob_viv_2005/`dataset'" ;
		compress ;
		save "$directorio/Data Created/derechohabiencia_2005.dta", replace ;
	} ;

/* ----------------------------------------------------------------------------
								CLEAN VARIABLES
---------------------------------------------------------------------------- */

	// Read in dataset
	use "$directorio/Data Created/derechohabiencia_2005.dta", clear ;

	// Rename notieder var to a meaningful name (not being beneficiary)
	cap ren notieder no_derechohab ;
	
	// Make variables double to clean easily
	destring imss issste pemex segu_pop inst_pri otrins_v no_derechohab, replace ;
	
	// Clean the variables related to providers of security	
	foreach var of varlist imss issste pemex segu_pop inst_pri otrins_v no_derechohab { ;
		replace `var' = 1 if !missing(`var') ;
		replace `var' = 0 if `var' != 1 ;
	} ;
	
	// Generate labels for the institution names to appear in the graph
	rename (imss issste pemex segu_pop inst_pri otrins_v no_derechohab) (institution#), addnumber(1) ;
	gen id = _n ;
	reshape long institution, i(id) ;
	label define _j 1 "IMSS" 2 "ISSSTE" 3 "PEMEX" 4 "Seguro Popular" 5 "Institución privada" 6 "Otra" 7 "None" ;
	label values _j _j ;
	
	collapse (rawsum) institution, by(_j) ;
	
	egen total = sum(institution) ;
	gen frac = 100*institution/total ;
	
	gen year = 2005 ;
	
	gen nombre = "." ;
	replace nombre = "IMSS" if _j == 1 ;
	replace nombre = "ISSSTE" if _j == 2 ;
	replace nombre = "PEMEX" if _j == 3 ;
	replace nombre = "Seguro Popular" if _j == 4 ;
	replace nombre = "Institución privada" if _j == 5 ;
	replace nombre = "Otra" if _j == 6 ;
	replace nombre = "None" if _j == 7 ;
	
	keep nombre year frac ;
	
	save "$directorio/Data Created/derechohabiencia_2005.dta", replace ;
} ;

/* ----------------------------------------------------------------------------
							Prepare data for year 2010
---------------------------------------------------------------------------- */

if (`prep_2010' == 1) { ;

	local bases : dir "$directorio/Data Original/censo_pob_viv_2010" files "*.dta" ;

	foreach file of local bases { ;
		use "$directorio/Data  Original/censo_pob_viv_2010/`file'", clear ;
		keep dhsersal1 dhsersal2 factor ;
		save "$directorio/Data Created/derechohab2010/`file'", replace ;
	};
	
	/* Read in data from the census and save as dta for appending data from all 
		states */
	use "$directorio/Data Created/derechohab2010/personas_01.dta", clear ;
	forvalues j = 2/9 { ;
		append using "$directorio/Data Created/derechohab2010/personas_0`j'.dta" ;
	} ;
	forvalues k = 10/32 { ;
		append using "$directorio/Data Created/derechohab2010/personas_`k'.dta" ;
	} ;

	compress ;
	
/* ----------------------------------------------------------------------------
								CLEAN VARIABLES
---------------------------------------------------------------------------- */
	
	gen imss = 0 ;
	gen issste = 0 ;
	gen pemex = 0 ;
	gen sp = 0 ;
	gen priv = 0 ;
	gen otrins_v = 0 ; 
	gen no_derechohab = 0 ;
	
	replace imss = 1*factor if dhsersal1 == 1 | dhsersal2 == 1 ;
	replace issste = 1*factor if inrange(dhsersal1, 2, 3) | inrange(dhsersal2, 2, 3) ;
	replace pemex = 1*factor if dhsersal1 == 4 | dhsersal2 == 4 ;
	replace sp = 1*factor if dhsersal1 == 5 | dhsersal2 == 5 ;
	replace priv = 1*factor if dhsersal1 == 6 | dhsersal2 == 6 ;
	replace otrins_v = 1*factor if dhsersal1 == 7 | dhsersal2 == 7 ;
	replace no_derechohab = 1*factor if dhsersal1 == 8 | dhsersal2 == 8 ;
	
	// Generate labels for the institution names to appear in the graph
	rename (imss issste pemex sp priv otrins_v no_derechohab) (institution#), addnumber(1) ;
	gen id = _n ;
	reshape long institution, i(id) ;
	label define _j 1 "IMSS" 2 "ISSSTE" 3 "PEMEX" 4 "Seguro Popular" 5 "Institución privada" 6 "Otra" 7 "None" ;
	label values _j _j ;
	
	collapse (rawsum) institution, by(_j) ;
	
	egen total = sum(institution) ;
	gen frac = institution/total ;
	
	gen year = 2010 ;
	
	gen nombre = "." ;
	replace nombre = "IMSS" if _j == 1 ;
	replace nombre = "ISSSTE" if _j == 2 ;
	replace nombre = "PEMEX" if _j == 3 ;
	replace nombre = "Seguro Popular" if _j == 4 ;
	replace nombre = "Institución privada" if _j == 5 ;
	replace nombre = "Otra" if _j == 6 ;
	replace nombre = "None" if _j == 7 ;
	
	keep nombre year frac ;
	
	save "$directorio/Data Created/derechohabiencia_2010.dta", replace ;

} ;
	
/* ----------------------------------------------------------------------------
							Prepare data for year 2015
---------------------------------------------------------------------------- */

if (`prep_2015' == 1) { ;

	local bases : dir "$directorio/Data Original/eic2015" files "*.dta" ;

	foreach file of local bases { ;
		use "$directorio/Data Original/eic2015/`file'", clear ;
		keep dhsersal1 dhsersal2 factor ;
		save "$directorio/Data Created/eic2015/`file'", replace ;
	};
	
	/* Read in data from the census and save as dta for appending data from all 
		states */
	use "$directorio/Data Created/eic2015/tr_persona01.dta", clear ;
	forvalues j = 2/9 { ;
		append using "$directorio/Data Created/eic2015/tr_persona0`j'.dta" ;
	} ;
	forvalues k = 10/32 { ;
		append using "$directorio/Data Created/eic2015/tr_persona`k'.dta" ;
	} ;

	compress ;
	
	save "$directorio/Data Created/pre_derechohabiencia_2015.dta", replace ;
	
/* ----------------------------------------------------------------------------
								CLEAN VARIABLES
---------------------------------------------------------------------------- */
	
	clear ;
	use "$directorio/Data Created/pre_derechohabiencia_2015.dta" ;
	
	gen imss = 0 ;
	gen issste = 0 ;
	gen pemex = 0 ;
	gen sp = 0 ;
	gen priv = 0 ;
	gen otrins_v = 0 ; 
	gen no_derechohab = 0 ;
	
	replace imss = 1*factor if dhsersal1 == 2 | dhsersal2 == 2 ;
	replace issste = 1*factor if inrange(dhsersal1, 3, 4) | inrange(dhsersal2, 3, 4) ;
	replace pemex = 1*factor if dhsersal1 == 5 | dhsersal2 == 5 ;
	replace sp = 1*factor if dhsersal1 == 1 | dhsersal2 == 1 ;
	replace priv = 1*factor if dhsersal1 == 6 | dhsersal2 == 6 ;
	replace otrins_v = 1*factor if dhsersal1 == 7 | dhsersal2 == 7 ;
	replace no_derechohab = 1*factor if dhsersal1 == 8 | dhsersal2 == 8 ;
	
	// Generate labels for the institution names to appear in the graph
	rename (imss issste pemex sp priv otrins_v no_derechohab) (institution#), addnumber(1) ;
	gen double id = _n ;
	
	reshape long institution, i(id) ;
	label define _j 1 "IMSS" 2 "ISSSTE" 3 "PEMEX" 4 "Seguro Popular" 5 "Institución privada" 6 "Otra" 7 "None" ;
	label values _j _j ;
	
	collapse (rawsum) institution, by(_j) ;
	
	egen total = sum(institution) ;
	gen frac = institution/total ;
	
	gen year = 2015 ;
	
	gen nombre = "." ;
	replace nombre = "IMSS" if _j == 1 ;
	replace nombre = "ISSSTE" if _j == 2 ;
	replace nombre = "PEMEX" if _j == 3 ;
	replace nombre = "Seguro Popular" if _j == 4 ;
	replace nombre = "Institución privada" if _j == 5 ;
	replace nombre = "Otra" if _j == 6 ;
	replace nombre = "None" if _j == 7 ;
	
	keep nombre year frac ;
	
	save "$directorio/Data Created/derechohabiencia_2015.dta", replace ;
	
} ;
	
/* ----------------------------------------------------------------------------
							Prepare data for year 2020
---------------------------------------------------------------------------- */

if (`prep_2020' == 1) { ;

	// Read in dataset
	import delimited using "$directorio/Data Original/censo_pob_viv_2020/Personas00.csv", case(lower) clear ;
	
	keep dhsersal* factor ;
	
	destring factor, replace ;

/* ----------------------------------------------------------------------------
								CLEAN VARAIBLES
---------------------------------------------------------------------------- */

	gen imss = 0 ;
	gen issste = 0 ;
	gen pemex = 0 ;
	gen sp = 0 ;
	gen imss_pros = 0 ;
	gen priv = 0 ;
	gen otra = 0 ;
	gen no_derechohab = 0 ;
	
	replace imss = 1*factor if dhsersal1 == 1 | dhsersal2 == 1 ;
	replace issste = 1*factor if inrange(dhsersal1, 2, 3) | inrange(dhsersal2, 2, 3) ;
	replace pemex = 1*factor if dhsersal1 == 4 | dhsersal2 == 4 ;
	replace sp = 1*factor if dhsersal1 == 5 | dhsersal2 == 5 ;
	replace imss_pros = 1*factor if dhsersal1 == 6 | dhsersal2 == 6 ;
	replace priv = 1*factor if dhsersal1 == 7 | dhsersal2 == 7 ;
	replace otra = 1*factor if dhsersal1 == 8 | dhsersal2 == 8 ;
	replace no_derechohab = 1*factor if dhsersal1 == 9 | dhsersal2 == 9 ;
	
	// Generate labels for the institution names to appear in the graph
	rename (imss issste pemex sp imss_pros priv otra no_derechohab) (institution#), addnumber(1) ;
	gen double id = _n ;
	reshape long institution, i(id) ;
	label define _j 1 "IMSS" 2 "ISSSTE" 3 "PEMEX" 4 "Seguro Popular" 5 "IMSS-Prospera" 6 "Institución privada" 7 "Otra" 8 "None" ;
	label values _j _j ;
	
	collapse (rawsum) institution, by(_j) ;
	
	egen total = sum(institution) ;
	gen frac = institution/total ;
	
	gen year = 2020 ;
	
	gen nombre = "." ;
	replace nombre = "IMSS" if _j == 1 ;
	replace nombre = "ISSSTE" if _j == 2 ;
	replace nombre = "PEMEX" if _j == 3 ;
	replace nombre = "Seguro Popular" if _j == 4 ;
	replace nombre = "IMSS-Prospera" if _j == 5 ;
	replace nombre = "Institución privada" if _j == 6 ;
	replace nombre = "Otra" if _j == 7 ;
	replace nombre = "None" if _j == 8 ;
	
	keep nombre year frac ;
	
	save "$directorio/Data Created/derechohabiencia_2020.dta", replace ;

} ;

#delimit cr

/* ----------------------------------------------------------------------------
								Make the plot
---------------------------------------------------------------------------- */

use "$directorio/Data Created/derechohabiencia_2000.dta", clear 
append using "$directorio/Data Created/derechohabiencia_2005.dta" 
append using "$directorio/Data Created/derechohabiencia_2010.dta" 
append using "$directorio/Data Created/derechohabiencia_2015.dta" 
append using "$directorio/Data Created/derechohabiencia_2020.dta" 

drop if nombre == "."

replace frac = 100*frac if frac < 1
replace nombre = "Private institution" if nombre == "Institución privada"
replace nombre = "Other" if nombre == "Otra"

local imssprosp = 0.8430673
replace frac = frac + `imssprosp' if year == 2020 & nombre == "IMSS"
drop if nombre == "IMSS-Prospera"

// Aggregate PEMEX with Other
preserve 

keep if inlist(nombre, "PEMEX", "Other")

bysort year : egen pemex_other = total(frac)

drop frac

ren pemex_other frac

keep if nombre == "PEMEX"

replace nombre = "PEMEX or Other"

tempfile aux_pemex 
save `aux_pemex', replace

restore

drop if inlist(nombre, "PEMEX", "Other")

append using `aux_pemex'

sort year

save "$directorio/Data Created/derechohabiencia_2000_2020.dta", replace 

use "$directorio/Data Created/derechohabiencia_2000_2020.dta", clear

#delimit ;

graph hbar (mean) frac, over(nombre, label(labsize(vsmall))) legend(off)
	bar(1, color(navy)) bar(2, color(orange)) bar(3, color(black%75)) 
	bar(4, color(midgreen)) bar(5, color(gold)) bar(6, color(cranberry))
	over(year, gap(*3) label(labsize(small) angle(90))) bargap(15) 
	showyvars asyvars
	yscale(r(0 65) noline) 
	ylabel(0 (10) 65, labsize(vsmall) glcolor("224 224 224"))
	ytitle("Percentage", size(small)) 
	blabel(bar, pos(outside) size(vsmall) format(%5.1f)) 
	graphregion(fcolor(white)) ;

graph export "$directorio/Figuras/derechohabiencia.pdf", replace ;

#delimit cr 

// End of do file -------------------------------------------------------------
