********************************************************************************
/*
*** Purpose: 	Syria use nominal GDP with CPI
*/
********************************************************************************
// Prepare WDI data
wbopendata, indicator(NY.GDP.PCAP.KD;NY.GDP.PCAP.CN) country(SYR) long clear
keep year ny_gdp*
drop if year<1981
tempfile wdi
save    `wdi'


// Prepare CPI data
*datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v10_M) filename(Yearly_CPI_Final.dta) clear
use "CPI_Yearly_Final_DLW_12.dta", clear						// updated data not yet public shared by Samuel
keep if code=="SYR" & inrange(year,2003,2022)
keep year yearly_cpi

// Merge the two
merge 1:1 year using `wdi', nogen
sort year

// Create CPI-deflated GDP series
gen gdpcpi = ny_gdp_pcap_cn/yearly_cpi
drop ny_gdp_pcap_cn yearly_cpi

// Append the two 
replace ny_gdp = ny_gdp[_n-1]*gdpcpi/gdpcpi[_n-1] if year>2003
drop gdpcpi

// Prepare for sna file format
gen countryname = "Syrian Arab Republic"
gen coverage    = "National"
gen countrycode = "SYR"
ren ny_gdp GDP
gen PCE = .
gen sourceGDP = "WDI (NY.GDP.PCAP.KD)"
replace sourceGDP = "WDI (NY.GDP.PCAP.CN) and price framework (CPI)" if inrange(year,2004,2022)
gen sourcePCE = ""
order countryname coverage countrycode year GDP PCE sourceGDP sourcePCE

// Export
export delimited using "sna.csv", replace