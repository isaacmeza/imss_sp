
********************
version 17.0
********************
/* 
/*******************************************************************************
* Name of file:	
* Author:	Isaac M
* Machine:	Isaac M 											
* Date of creation:	
* Last date of modification: July. 07, 2022
* Modifications: 
* Files used:     
		- 
* Files created:  

* Purpose: Count gaps in employment with IMSS and frequency of 'attrition'

*******************************************************************************/
*/

use "$directorio/Data Created/panel_trabajadores_sample.dta", clear
sort idnss date



*Identify 'definitive' exits
	*because panel is balanced
by idnss : gen exits_ = 1 if missing(ta) & _n==_N	
by idnss : egen exits = max(exits_)
replace exits = 0 if missing(exits)

*Count (strict) gaps
by idnss : gen start_gap = 1 if missing(ta) & !missing(ta[_n-1])
by idnss : gen end_gap = 1 if missing(ta) & !missing(ta[_n+1])
by idnss : gen gap = 1 if !missing(start_gap) | !missing(end_gap)
by idnss : ipolate gap date if missing(ta), gen(gap_) 
by idnss : egen num_gaps = sum(gap_)
by idnss : gen nm_gap = sum(gap_)
replace num_gaps = num_gaps - 1 if exits==1
by idnss : replace num_gaps = . if _n!=1
by idnss : gen porc_gaps =  (num_gaps/_N)*100

by idnss : replace gap_ = . if num_gaps==nm_gap

*Average time span (by individual) not reporting
gen chunk = sum(start_gap)
sort chunk idnss date
by chunk : egen time = sum(gap_)
by chunk : replace time = . if _n!=1
replace time = . if time==0
bysort idnss : egen mn_timegaps = mean(time)
by idnss : replace mn_timegaps = . if _n!=1

*Number of times switched
gen ind_sw = !missing(time)
bysort idnss : egen times_switch = total(ind_sw)
by idnss : replace times_switch = . if _n!=1

*******************************************************************************
*******************************************************************************

*Histogram % gaps
twoway (hist porc_gaps, percent xtitle("% gaps"))
graph export "$directorio/Figuras/hist_gaps.pdf", replace	

*Histogram time span
twoway (hist mn_timegaps, percent xtitle("Avg time span not in IMSS (quarters)"))
graph export "$directorio/Figuras/hist_timespan.pdf", replace

*Histogram times switched
twoway (hist times_switch, discrete percent xtitle("# switches")) 
graph export "$directorio/Figuras/hist_timeswitch.pdf", replace