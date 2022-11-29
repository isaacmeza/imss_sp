/* ----------------------------------------------------------------------------
						  Effects of Seguro Popular
					Ph.D. Enrique Seira & MSc. Isaac Meza

    Code author: Roberto González
	Date: August 1, 2022
	
	Code modifications: 
		1. 
	Most recent modifications: 
	
	Code Objective: Create dataset with health-related out of pocket
		expenditure from the ENIGH survey
	
	Files used:
		Do Files:
			- 12_pocket_expenditure.do
		Data sets:
			- 
	
	Files produced:
---------------------------------------------------------------------------- */

// Control which parts of the script to run
local dataprep_00_05 = 1
local dataprep_06_20 = 1
local append_data 	 = 1
local collapse_data	 = 1

if (`dataprep_00_05' == 1) {
	/* ------------------------------------------------------------------------
						Data preparation from 2000 - 2005
	------------------------------------------------------------------------ */
						
	// Read in data from 2000-2005 and save it as dta to work with it easily
	// Also keep only the relevant variables needed for the analysis:
	// 	Namely: id municipality income health-expenditure and expansion factor
	foreach year in "2000" "2002" "2004" "2005" { 
		import dbase using "$data/enigh/concentrado_`year'.dbf", case(lower) ///
			clear 
		
		// Keep relevant variables
		keep folio hog ubica_geo ingcor salud aten_pri hospital medica
		
		// Rename to standard names across data sets
		ren (folio hog ubica_geo salud) (folio_hog factor_hog cvemun oop_salud) 
		ren medica med_sin_receta
			
		gen int year = `year' 
		
		// Save as dta for appending/merging with other relevant data
		tempfile concentrado_`year'_relevant
		save `concentrado_`year'_relevant' 
	} 
}


if (`dataprep_06_20' == 1) {
	/* ------------------------------------------------------------------------
						Data preparation from 2006 - 2020
	------------------------------------------------------------------------ */
	
	// Keep only the relevant variables needed for the analysis
	// 	Namely: id municipality income health-expenditure and expansion factor
	foreach year in "2006" "2008" "2010" "2012" "2014" "2016" "2018" "2020" {
		// Read in dataset
		di in red "Importing year = `year'"
		use "$data/enigh/concentrado_`year'.dta", clear 
		
		if "`year'" == "2006" {
			// Keep relevant variables
			keep folio hog ubica_geo ingcor salud aten_pri hospital medica
			
			// Rename to standard names across data sets
			ren (folio hog ubica_geo salud) ///
				(folio_hog factor_hog cvemun oop_salud)
			ren medica med_sin_receta
			
			gen int year = `year'
			
			// Save as dta 
			tempfile concentrado_`year'_relevant
			save `concentrado_`year'_relevant' 
		}
		else if inlist("`year'", "2008", "2010") {
			// Keep relevant variables
			keep folioviv foliohog factor ubica_geo ingcor salud aten_pri ///
				 hospital medica
			
			// Rename to standard names across data sets
			ren (folioviv foliohog factor ubica_geo salud) ///
				(folio_viv folio_hog factor_hog cvemun oop_salud)
			ren medica med_sin_receta
			
			gen int year = `year'
			
			// Save as dta
			tempfile concentrado_`year'_relevant
			save `concentrado_`year'_relevant' 
		}
		else if inlist("`year'", "2012", "2014") {
			// Keep relevant variables
			keep folioviv foliohog factor_hog ubica_geo ing_cor salud atenc_ambu ///
				 hospital medicinas
			
			// Rename to standard names across data sets
			ren (folioviv foliohog ubica_geo ing_cor salud) ///
				(folio_viv folio_hog cvemun ingcor oop_salud)
			ren (atenc_ambu medicinas) (aten_pri med_sin_receta)	
			
			gen year = `year'
			
			// Save as dta
			tempfile concentrado_`year'_relevant
			save `concentrado_`year'_relevant' 
		}
		else {
			// Keep relevant variables
			keep folioviv foliohog factor ubica_geo ing_cor salud atenc_ambu ///
				 hospital medicinas
			
			// Rename to standard names across data sets
			ren (folioviv foliohog factor ubica_geo ing_cor salud) ///
				(folio_viv folio_hog factor_hog cvemun ingcor oop_salud)
			ren (atenc_ambu medicinas) (aten_pri med_sin_receta)
				
			gen year = `year'
			
			// Save as dta
			tempfile concentrado_`year'_relevant
			save `concentrado_`year'_relevant' 
		}
	}
}

if (`append_data' == 1) {
	use `concentrado_2000_relevant', clear
	foreach year in "2002" "2004" "2005" "2006" "2008" "2010" "2012" ///
					"2014" "2016" "2018" "2020" {
		append using `concentrado_`year'_relevant'
	}
		
	// Clean cvemun as first five characters in string
	replace cvemun = substr(cvemun, 1, 5)
	destring cvemun, replace
	
	// Clean cdmx municipality
	replace cvemun = 9000 if inrange(cvemun, 9000, 9999)
	
	// Create vivienda + hogar id 
	// Need to create folio_viv for data prior to 2008
	destring folio_viv, replace
	replace folio_viv = _n if year < 2008
	egen hh_id = group(folio_viv folio_hog cvemun year)
	drop folio_viv folio_hog
	
	// Save dataset for final processing
	save "$processed/concentrado_enigh_00_2020.dta", replace	
}

if (`collapse_data' == 1) {
	// Read in dataset
	use "$processed/concentrado_enigh_00_2020.dta", clear
	
	// Add consumer price index (base july - 2018) for making amounts comparable
	gen byte inpc =.
	replace inpc = 0.46464 if year == 2000
	replace inpc = 0.51911 if year == 2002
	replace inpc = 0.56479 if year == 2004
	replace inpc = 0.59001 if year == 2005
	replace inpc = 0.60809 if year == 2006
	replace inpc = 0.66742 if year == 2008
	replace inpc = 0.72929 if year == 2010
	replace inpc = 0.78853 if year == 2012
	replace inpc = 0.84914 if year == 2014
	replace inpc = 0.89556 if year == 2016
	replace inpc = 1.00000 if year == 2018
	replace inpc = 1.07444 if year == 2020
	
	// Now make all quantities july2018-prices
	foreach var of varlist ingcor oop_salud aten_pri hospital med_sin_receta {
		replace `var' = inpc*`var'
	}
	
	drop inpc 
	
	// Compute ratio of health-expenditure as proportion of income
	// Also make expenditure/income yearly since it is quarterly as of now
	replace ingcor = 4*ingcor
	foreach var of varlist oop_salud aten_pri hospital med_sin_receta {
		replace `var' = 4*`var'
		gen p_`var' = 100*`var'/ingcor
	}
	
	
	// Save expansion factor
	preserve
		keep hh_id cvemun factor_hog
		tempfile exp_factor
		save `exp_factor'
	restore
	
	// Collapse at household year level
	collapse (mean) p_* oop_* aten_pri hospital med_sin_receta, by(hh_id year)
	
	// Add expansion factor and municipality
	merge 1:1 hh_id using `exp_factor', nogen
	
	order year cvemun hh_id factor*
	
	save "$processed/base_hh_year_health_expenditure.dta", replace
}


// End of do file -------------------------------------------------------------

