/*

**  Isaac Meza, isaacmezalopez@g.harvard.edu


Master do file for tables and figures of the paper

	Did Seguro Popular Reduce Formal Jobs?

For further details see the notes in the paper and the dofile itself.	
*/		


*********************************** PATH  **************************************

*Directory
global directorio "C:\Users\isaac\Dropbox\Statistics\P27\IMSS"
cd "C:\Users\isaac\Dropbox\Statistics\P27\IMSS\" 

*Set scheme
set scheme white_tableau, perm

*Set significance
global star "star(* 0.1 ** 0.05 *** 0.01)"
*global star "nostar"


*********************************** TABLES *************************************

*Table 1: Effect of SP on Formal Jobs using IV strategy
do "$directorio\DoFiles\iv_sp.do"

*-------------------------------------------------------------------------------

*Table OA-1: Pre-time trends (1-year)
*do "$directorio\DoFiles\iv_sp.do"

*Table OA-2: Salary changes
do "$directorio\DoFiles\consequences_informal.do"



*********************************** FIGURES ************************************

*Figure 1:  Insurance affiliation 2000-2020
do "$directorio\DoFiles\insurance_affiliation.do"

*Figure 2:  Geographical coverage of SP by municipality
do "$directorio\DoFiles\sp_geo_coverage.do"

*Figure 3: Unemployment rate, labour force participation rate and fraction of workers without IMSS
do "$directorio\DoFiles\informal_time.do"

*Figure 4: Roll-out of Seguro Popular (replication)
do "$directorio\DoFiles\tsline_emp.do"

*Figure 5: Event studies - Employment
do "$directorio\DoFiles\did_es.do"

*Figure 6: Heterogeneous effects
do "$directorio\DoFiles\did_het.do"

*Figure 7:  Effect on the worker level probability of abandoning IMSS
do "$directorio\DoFiles\did_imss.do"

*Figure 8: Event studies - wages
*do "$directorio\DoFiles\did_es.do"

*Figure 9: Industrial and Geographical concentration of informality
do "$directorio\DoFiles\industrial_concentration.do"
do "$directorio\DoFiles\spmap_informality.do"

*Figure 10: Characteristics and likelihood of not having IMSS coverage
do "$directorio\DoFiles\characteristics_informal.do"

*-------------------------------------------------------------------------------

*Figure OA-1: Health expenditure as proportion of current income
do "$directorio\DoFiles\health_expenditures.do"

*Figure OA-2: TWFE weights
do "$directorio\DoFiles\weights_twfe_diagnostic.do"


*Figure OA-3: Event studies - Bosch & Campos-Vazquez (2014) replication
do "$directorio\DoFiles\did_bc.do"

*Figure OA-4: More municipalities
*do "$directorio\DoFiles\did_es.do"

*Figure OA-5: Flexible specification
*do "$directorio\DoFiles\did_es.do"

*Figure OA-6: Clinics in MX
do "$directorio\DoFiles\map_clinics.do"

*Figure OA-7: Trends of IMSS employment by terciles of the # of clinics
do "$directorio\DoFiles\trends_emp_clinics.do"

*Figure OA-8: First stage
*do "$directorio\DoFiles\iv_sp.do"

*Figure OA-9: Dynamic second stage
*do "$directorio\DoFiles\iv_sp.do"

