
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

* Purpose: Cleaning luminosity data

*******************************************************************************/
*/

local path1 "$directorio\Data Original\luminosity-master\luminosity-master\data\municipios"
local folderList : dir "`path1'" dirs "*"

* loop through folders
foreach folder of local folderList {

  * get list of files
  local fileList : dir "`path1'/`folder'" files "*.csv"

  * loop through files
  foreach file of local fileList {
    * do stuff to file

	di "`folder'"
	di "`file'"

	import delimited "`path1'/`folder'/`file'", clear 
	rename (mean sd median) (mean_lum sd_lum median_lum)
	foreach var of varlist mean sd median {
		destring `var', replace force
	}
	tostring edon, replace
	tostring munn, replace
	gen cvemun_ = edon + "0" + munn if length(munn)==2
	replace cvemun_ = edon + "00" + munn if length(munn)==1
	replace cvemun_ = edon + munn if length(munn)==3	
	destring cvemun_ , gen(cvemun)
	gen year_ = substr("`file'",4,4)
	destring year_ , gen(year)	
	keep cvemun mean_ sd_ median_ year
	local nme = substr("`file'",1,7)
	save  "`path1'/`folder'/`nme'.dta" , replace
    ** do more stuff
  }
}



local path1 "$directorio\Data Original\luminosity-master\luminosity-master\data\municipios"
local folderList : dir "`path1'" dirs "*"

* loop through folders
foreach folder of local folderList {

  * get list of files
  local fileList : dir "`path1'/`folder'" files "*.dta"

  * loop through files
  foreach file of local fileList {
    * do stuff to file

	di "`folder'"
	di "`file'"
	
	append using  "`path1'/`folder'/`file'"
  }
}

duplicates drop

*Interpolation
gen int time = yq(year, 1)
drop year
format time %tq

xtset cvemun time
tsfill
sort cvemun time

by cvemun : ipolate mean_lum time, gen(mean_lum_)
by cvemun : ipolate median_lum time, gen(median_lum_)
drop mean_lum median_lum 
rename (mean_lum_ median_lum_) (mean_lum median_lum)
gen ent = floor(cvemun/1000)
gen mun = cvemun-ent*1000
gen year = yofd(dofq(time))
gen quarter = quarter(dofq(time))
drop time

save  "$directorio\Data Created\luminosity.dta", replace
