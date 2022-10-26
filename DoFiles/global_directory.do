*Directory

if "`c(username)'" == "isaac" {
	global directorio "C:\Users\isaac\Dropbox\Statistics\P27\IMSS"
	cd "$directorio"
}
if "`c(username)'" == "Roberto" {
	global directorio "C:/Users/Roberto/ITAM/CIE/imss_sp"
	cd "$directorio"
}

*Set scheme
set scheme white_tableau, perm

*Set significance
global star "star(* 0.1 ** 0.05 *** 0.01)"
*global star "nostar"