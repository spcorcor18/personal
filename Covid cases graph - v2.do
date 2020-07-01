
// Daily bar chart for new cases, new deaths -- US, state, and county
// Version 2 - overlays bars with 7-day rolling average line

// Note NYTimes data documentation is here:
// https://github.com/nytimes/covid-19-data

// Location for graphs to be saved
cd "C:\Users\spcor\Downloads"

*ssc install tsegen, replace
*ssc install g538schemes, replace all

// Choose a graph: US, state, or county
local graphus 0
local graphst 0
local graphco 1

// Designate your state (and county if desired)
local state "Tennessee"
local county "Davidson"

// Number of days for rolling average
local days 7

// First date (note: first US death was Feb 29)
local first "26feb2020"

clear
if `graphus'==1 {
	// get NYTimes US Covid-19 cases
	import delimited "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us.csv"

	// date as numeric
	encode date, gen(newdate)
	gen date2 = date(date,"YMD")
	format date2 %td
	
	// first date to use - and grab numeric first/last date for labeling graph
	keep if date2>=td(`first')
	sort date2
	local firstdate = date2[1]
	local lastdate = date2[_N]
	
	// new cases and deaths
	tsset date2
	gen newcases=cases-L.cases
	gen newdeaths=deaths-L.deaths

	// versions that ignore date gaps
	sort date2
	gen newcases2=cases-cases[_n-1]
	gen newdeaths2=deaths-deaths[_n-1]

	//x-day rolling average
	tsegen casesma=rowmean(newcases L(1/`days').newcases)
	tsegen deathsma=rowmean(newdeaths L(1/`days').newdeaths)

	// bar graph with rolling average line overlay--new cases
	twoway (bar newcases2 date2, sort fcolor(538b) fintensity(50) lwidth(thin) barwidth(0.8)) (line casesma date2,lwidth(medthick)) ///
		   (scatter newcases2 date2, msymbol(none) mlabel(newcases2) mlabsize(tiny) mlabcolor(538label) mlabposition(1) mlabangle(ninety)), ///
		   xlabel(`firstdate'(5)`lastdate', labsize(vsmall) angle(ninety) valuelabel) xmtick(`firstdate'(1)`lastdate') ///
		   legend(order(1 "New cases" 2 "`days'-day rolling average") position(11) ring(0)) ///
		   xsize(8) ysize(4) title("US new cases") xtitle("") ytitle("") name(UScases,replace)
    graph save UScases, replace
	graph export UScases.png, as(png) replace
		   
	// bar graph with rolling average line overlay--new deaths
	twoway (bar newdeaths2 date2, sort fcolor(538p) lcolor(538p) fintensity(70) lwidth(thin) barwidth(0.8)) (line deathsma date2, lwidth(medthick) lcolor(dknavy)) ///
		   (scatter newdeaths2 date2, msymbol(none) mlabel(newdeaths2) mlabsize(tiny) mlabcolor(538label) mlabposition(1) mlabangle(ninety)), ///
		   xlabel(`firstdate'(5)`lastdate', labsize(vsmall) angle(ninety) valuelabel) xmtick(`firstdate'(1)`lastdate') ///
		   legend(order(1 "New cases" 2 "`days'-day rolling average") position(11) ring(0)) ///
		   xsize(8) ysize(4) title("US new deaths") xtitle("") ytitle("") name(USdeaths,replace)
    graph save USdeaths, replace
	graph export USdeaths.png, as(png) replace
		}

clear
if `graphst'==1 {
	// get NYTimes US Covid-19 cases
	import delimited "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv"
    keep if state=="`state'"

	// date as numeric
	encode date, gen(newdate)
	gen date2 = date(date,"YMD")
	format date2 %td
	
	// first date to use - and grab numeric first/last date for labeling graph
	keep if date2>=td(`first')
	sort date2
	local firstdate = date2[1]
	local lastdate = date2[_N]

	// new cases and deaths
	tsset date2
	gen newcases=cases-L.cases	
	gen newdeaths=deaths-L.deaths

	// versions that ignore date gaps
	sort date2
	gen newcases2=cases-cases[_n-1]
	gen newdeaths2=deaths-deaths[_n-1]
	
	// last 3 days: set zeros to missing (so non-reports won't lower rolling average)
	// (done for state and county only)
	forvalues j=0/2 {
	   local tick = _N-`j'
	   replace newcases=. if _n==`tick' & newcases==0
	   replace newcases2=. if _n==`tick' & newcases2==0
	   replace newdeaths=. if _n==`tick' & newdeaths==0
	   replace newdeaths2=. if _n==`tick' & newdeaths2==0
	   }

	//x-day rolling average
	tsegen casesma=rowmean(newcases L(1/`days').newcases)
	tsegen deathsma=rowmean(newdeaths L(1/`days').newdeaths)

	// bar graph with rolling average line overlay--new cases
	twoway (bar newcases2 date2, sort fcolor(538b) fintensity(50) lwidth(thin) barwidth(0.8)) (line casesma date2, lwidth(medthick)) ///
		   (scatter newcases2 date2, msymbol(none) mlabel(newcases2) mlabsize(tiny) mlabcolor(538label) mlabposition(1) mlabangle(ninety)), ///
		   xlabel(`firstdate'(5)`lastdate', labsize(vsmall) angle(ninety) valuelabel) xmtick(`firstdate'(1)`lastdate') ///
		   legend(order(1 "New cases" 2 "`days'-day rolling average") position(11) ring(0)) ///
		   xsize(8) ysize(4) title("`state' new cases") xtitle("") ytitle("") name(`state'cases,replace)
    graph save `state'cases, replace
	graph export `state'cases.png, as(png) replace
	
	// bar graph with rolling average line overlay--new deaths
	twoway (bar newdeaths2 date2, sort fcolor(538p) lcolor(538p) fintensity(70) lwidth(thin) barwidth(0.8)) (line deathsma date2, lwidth(medthick) lcolor(dknavy)) ///
		   (scatter newdeaths2 date2, msymbol(none) mlabel(newdeaths2) mlabsize(tiny) mlabcolor(538label) mlabposition(1) mlabangle(ninety)), ///
		   xlabel(`firstdate'(5)`lastdate', labsize(vsmall) angle(ninety) valuelabel) xmtick(`firstdate'(1)`lastdate') ///
		   legend(order(1 "New cases" 2 "`days'-day rolling average") position(11) ring(0)) ///
		   xsize(8) ysize(4) title("`state' new deaths") xtitle("") ytitle("") name(`state'deaths,replace)
    graph save `state'deaths, replace
	graph export `state'deaths.png, as(png) replace
	}

clear
if `graphco'==1 {
	// get NYTimes US Covid-19 cases -- note there may be more recent data in "live"
	// file, so append these and delete duplicates
	import delimited "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv"
	keep if state=="`state'"
	keep if county=="`county'"
	tempfile cntydata
	save `cntydata'

	clear
	import delimited "https://raw.githubusercontent.com/nytimes/covid-19-data/master/live/us-counties.csv"
	keep if state=="`state'"
	keep if county=="`county'"
	append using `cntydata'
	duplicates drop date, force

	// date as numeric
	encode date, gen(newdate)
	gen date2 = date(date,"YMD")
	format date2 %td
	
	// first date to use - and grab numeric first/last date for labeling graph
	keep if date2>=td(`first')
	sort date2
	local firstdate = date2[1]
	local lastdate = date2[_N]
	
	// new cases and deaths
	tsset date2
	gen newcases=cases-L.cases
	gen newdeaths=deaths-L.deaths

	// versions that ignore date gaps
	sort date2
	gen newcases2=cases-cases[_n-1]
	gen newdeaths2=deaths-deaths[_n-1]

	// manually fill in county cases for most recent day (if needed)--Nashville
	// cases announced before NYTimes data is updated
	*qui sum date2
	*replace newcases2=343 if date2==r(max)

	// last 3 days: set zeros to missing (so non-reports won't lower rolling average)
	// (done for state and county only)
	forvalues j=0/2 {
	   local tick = _N-`j'
	   replace newcases=. if _n==`tick' & newcases==0
	   replace newcases2=. if _n==`tick' & newcases2==0
	   replace newdeaths=. if _n==`tick' & newdeaths==0
	   replace newdeaths2=. if _n==`tick' & newdeaths2==0
	   }

	//x-day rolling average
	tsegen casesma=rowmean(newcases L(1/`days').newcases)
	tsegen deathsma=rowmean(newdeaths L(1/`days').newdeaths)

	// bar graph with rolling average line overlay--new cases
	twoway (bar newcases2 date2, sort fcolor(538b) fintensity(50) lwidth(thin) barwidth(0.8)) (line casesma date2,lwidth(medthick)) ///
		   (scatter newcases2 date2, msymbol(none) mlabel(newcases2) mlabsize(tiny) mlabcolor(538label) mlabposition(1) mlabangle(ninety)), ///
		   xlabel(`firstdate'(5)`lastdate', labsize(vsmall) angle(ninety) valuelabel) xmtick(`firstdate'(1)`lastdate') ///
		   legend(order(1 "New cases" 2 "`days'-day rolling average") position(11) ring(0)) ///
		   xsize(8) ysize(4) title("`county' County `state' new cases") xtitle("") ytitle("") name(`state'`county'cases,replace)
    graph save `state'`county'cases, replace
	graph export `state'`county'cases.png, as(png) replace
	
	// bar graph with rolling average line overlay--new deaths
	twoway (bar newdeaths2 date2, sort fcolor(538p) lcolor(538p) fintensity(70) lwidth(thin) barwidth(0.8)) (line deathsma date2, lwidth(medthick) lcolor(dknavy)) ///
		   (scatter newdeaths2 date2, msymbol(none) mlabel(newdeaths2) mlabsize(tiny) mlabcolor(538label) mlabposition(1) mlabangle(ninety)), ///
		   xlabel(`firstdate'(5)`lastdate', labsize(vsmall) angle(ninety) valuelabel) xmtick(`firstdate'(1)`lastdate') ///
		   legend(order(1 "New cases" 2 "`days'-day rolling average") position(11) ring(0)) ///
		   xsize(8) ysize(4) title("`county' County `state' new deaths") xtitle("") ytitle("") name(`state'`county'deaths,replace)	
    graph save `state'`county'deaths, replace
	graph export `state'`county'deaths.png, as(png) replace
	}

