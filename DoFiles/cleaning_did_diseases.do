/* ----------------------------------------------------------------------------
                       Effects of Seguro Popular
	            Ph.D. Enrique Seira & MSc. Isaac Meza

    Code author: Roberto González 
	Date: July 25, 2022
	
	Code modifications: 
		1. 
	Most recent modifications: 
	
	Code Objective: Build dataset at the municipality - quarter level with the
		number of people who died because of a covered disease; 
	
	Files used:
		Do Files:
			- 
		Data sets:
			- 
	
	Files produced:
		Processed data:
			- 
---------------------------------------------------------------------------- */

// Read in the mortality data set
use "Data Created/mortality_refined.dta", clear
drop id

replace causa_muerte_mx = ustrfrom(causa_muerte_mx, "ASCII", 2)

/* ----------------------------------------------------------------------------
		Keep nationals and generate quarterly date for collapsing
---------------------------------------------------------------------------- */

// Keep only data from people with mexican nationality
keep if nacionalidad == "Mexicano"

// Generate cvemun for easier merge in the analysis
gen cvemun = ent_ocurr*1000 + mun_ocurr
drop if cvemun > 33000

// Generate quarterly date
replace anio_ocurr = anio_regis if anio_ocurr == 9999
replace mes_ocurr = mes_regis if mes_ocurr == 99

gen date = qofd(dofm(ym(anio_ocurr, mes_ocurr)))
format date %tq

cap drop year
gen year = yofd(dofq(date))
gen quarter = quarter(dofq(date))
drop if year < 2000

// Drop people with non-specified ages
drop if edad == 999

/* ----------------------------------------------------------------------------
			Aggregate deaths by municipality-quarter-age of death
---------------------------------------------------------------------------- */

keep cvemun year quarter edad causa_muerte_mx

// Generate death variable to collapse and get number of deaths per disease at 
// the municipality - quarter level
gen deaths = 1

replace causa_muerte_mx = "cancermama" if causa_muerte_mx == "tumor maligno de la mama"
replace causa_muerte_mx = "cancerutero" if causa_muerte_mx == "tumor maligno del cuello del tero"

foreach enfermedad in carcinoma obsttricas fetal diabetes recinnacid hipertensiva ///
	epilepsia postparto hemorragprecozdelembarazo hipertensin miocardio cardaca ///
	leucemia anemia puerperio cancermama cancerutero {
		
			preserve
			keep if strpos(causa_muerte_mx, "`enfermedad'")
			
			collapse (count) death_`enfermedad' = deaths, by(cvemun year quarter)
			
			tempfile temp_`enfermedad'
			save `temp_`enfermedad'', replace
			
			restore
}

// Merge all the files containing the diseases to a single wide dataset
use `temp_carcinoma', clear
foreach enfermedad in obsttricas fetal diabetes recinnacid hipertensiva ///
	epilepsia postparto hemorragprecozdelembarazo hipertensin miocardio cardaca ///
	leucemia anemia puerperio cancermama cancerutero {
			di in red "`enfermedad'"
			merge 1:1 cvemun year quarter using `temp_`enfermedad''
			tab _merge
			drop _merge
			
			save "Data Created/base_mun_quarter_muertesXenfermedad.dta", replace
}

foreach var of varlist death* {
	replace `var' = 0 if `var' == . 
}

sort cvemun year quarter
compress
save "Data Created/base_mun_quarter_muertesXenfermedad.dta", replace