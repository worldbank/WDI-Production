clear
tempfile serfile catalog
save `catalog', emptyok replace

dlw_serverlist
levelsof serveralias, local(srvlist)
foreach ser of local srvlist {
	cap dlw_catalog, savepath(`serfile') server(`ser') fullonly	
	if _rc==0 {
		use `serfile', clear
		append using `catalog'
		save `catalog', replace
	}
}
use `catalog', clear
duplicates drop surveyid, force


*change directory
cd ..
cd ./03_outputs

export delimited using "datalibweb_contents.csv"