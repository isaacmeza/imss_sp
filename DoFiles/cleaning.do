

local path1 "C:\Users\isaac\Downloads\114886-V1\luminosity-master\luminosity-master\data\municipios"
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



local path1 "C:\Users\isaac\Downloads\114886-V1\luminosity-master\luminosity-master\data\municipios"
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
save  "C:\Users\isaac\Downloads\114886-V1\luminosity-master\luminosity.dta" , replace
