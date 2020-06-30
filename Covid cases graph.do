
// Daily bar or line chart for new cases, new deaths -- US, state, and county

// Note NYTimes data documentation is here:
// https://github.com/nytimes/covid-19-data

// Location for graphs to be saved
cd "C:\Users\spcor\Downloads"

*ssc install tsegen, replace
*ssc install g538schemes, replace all

// Choose a graph: US, state, or county
local graphus 0
local graphst 1
local graphco 1

// Designate your state (and county if desired)
local state "Tennessee"
local county "Davidson"

// Number of days for rolling average
local days 7

// First date (note: first US death was Feb 29)
local first "26feb2020"

// Bar and/or line graph
local bar 1
local line 1

clear
if `graphus'==1 {
	// get NYTimes US Covid-19 cases
	import delimited "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us.csv"

	// date as numeric
	encode date, gen(newdate)
	gen date2 = date(date,"YMD")
	format date2 %td

	// first date to use
	keep if date2>=td(`first')

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
	
	if `bar'==1 {
	graph bar (asis) newcases2, over(newdate, label(angle(ninety) labsize(tiny))) ///
		blabel(bar, size(tiny) orientation(vertical)) xsize(8) ysize(4) title("US new cases") ///
		name(UScases, replace)
	graph save USnewcases.gph, replace
	graph export USnewcases.png, replace as(png)

	graph bar (asis) newdeaths2, over(newdate, label(angle(ninety) labsize(tiny))) ///
		blabel(bar, size(tiny) orientation(vertical)) xsize(8) ysize(4) title("US new deaths") ///
		name(USdeaths, replace)
	graph save USnewdeaths.gph, replace
	graph export USnewdeaths.png, replace as(png)
	
	graph bar (asis) casesma, over(newdate, label(angle(ninety) labsize(tiny))) ///
		missing bar(1, fcolor(538p) fintensity(inten70) lcolor(538axis) lwidth(vvthin)) ///
		blabel(bar, size(tiny) format(%5.0f) orientation(vertical)) xsize(8) ysize(4) ///
		title("US `days'-day moving average of new cases") name(UScasesma, replace)
	graph save USnewcasesma.gph, replace
	graph export USnewcasesma.png, replace as(png)
		
	graph bar (asis) deathsma, over(newdate, label(angle(ninety) labsize(tiny))) ///
		missing bar(1, fcolor(538p) fintensity(inten70) lcolor(538axis) lwidth(vvthin)) ///
		blabel(bar, size(tiny) format(%5.0f) orientation(vertical)) xsize(8) ysize(4) ///
		title("US `days'-day moving average of deaths") name(USdeathsma, replace)
	graph save USnewdeathsma.gph, replace
	graph export USnewdeathsma.png, replace as(png)
	}
	
	if `line'==1 {
	local firstdate = date2[1]
	local lastdate = date2[_N]
	twoway (connected newcases2 date2, sort msize(small) msymbol(point) lwidth(thin)), ///
		xlabel(`firstdate'(5)`lastdate', angle(ninety) valuelabel) xsize(8) ysize(4) ///
		title("US new cases") xtitle("") ytitle("New cases") name(UScasesline, replace)
	graph save USnewcasesl.gph, replace
	graph export USnewcasesl.png, replace as(png)
	
	twoway (connected newdeaths2 date2, sort msize(small) msymbol(point) lwidth(thin)), ///
		xlabel(`firstdate'(5)`lastdate', angle(ninety) valuelabel) xsize(8) ysize(4) ///
		title("US new deaths") xtitle("") ytitle("New deaths") name(USdeathsline, replace)	
	graph save USnewdeathsl.gph, replace
	graph export USnewdeathsl.png, replace as(png)
	
	twoway (connected casesma date2, sort msize(small) msymbol(point) lwidth(thin)), ///
		xlabel(`firstdate'(5)`lastdate', angle(ninety) valuelabel) xsize(8) ysize(4) ///
		title("US `days'-day moving average of new cases") xtitle("") ///
		ytitle("New cases") name(UScasesmaline, replace)	
	graph save USnewcasesmal.gph, replace
	graph export USnewcasesmal.png, replace as(png)
	
	twoway (connected deathsma date2, sort msize(small) msymbol(point) lwidth(thin)), ///
		xlabel(`firstdate'(5)`lastdate', angle(ninety) valuelabel) xsize(8) ysize(4) ///
		title("US `days'-day moving average of new deaths") xtitle("") ///
		ytitle("New deaths") name(USdeahts7line, replace)	
	graph save USnewdeathsmal.gph, replace
	graph export USnewdeathsmal.png, replace as(png)
		}
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

	// first date to use
	keep if date2>=td(`first')

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

	if `bar'==1 {
	graph bar (asis) newcases2, over(newdate, label(angle(ninety) labsize(tiny))) ///
		blabel(bar, size(tiny) orientation(vertical)) xsize(8) ysize(4) title("`state' new cases") ///
		name(`state'cases, replace)
	graph save `state'newcases.gph, replace
	graph export `state'newcases.png, replace as(png)

	graph bar (asis) newdeaths2, over(newdate, label(angle(ninety) labsize(tiny))) ///
		blabel(bar, size(tiny) orientation(vertical)) xsize(8) ysize(4) title("`state' new deaths") ///
		name(`state'deaths, replace)
	graph save `state'newdeaths.gph, replace
	graph export `state'newdeaths.png, replace as(png)
	
	graph bar (asis) casesma, over(newdate, label(angle(ninety) labsize(tiny))) ///
		missing bar(1, fcolor(538p) fintensity(inten70) lcolor(538axis) lwidth(vvthin)) ///
		blabel(bar, size(tiny) format(%5.0f) orientation(vertical)) xsize(8) ysize(4) ///
		title("`state' `days'-day moving average of new cases") name(`state'casesma, replace)
	graph save `state'newcasesma.gph, replace
	graph export `state'newcasesma.png, replace as(png)
	
	graph bar (asis) deathsma, over(newdate, label(angle(ninety) labsize(tiny))) ///
		missing bar(1, fcolor(538p) fintensity(inten70) lcolor(538axis) lwidth(vvthin)) ///
		blabel(bar, size(tiny) format(%5.0f) orientation(vertical)) xsize(8) ysize(4) ///
		title("`state' `days'-day moving average of deaths") name(`state'deathsma, replace)
	graph save `state'newdeathsma.gph, replace
	graph export `state'newdeathsma.png, replace as(png)
	}
	if `line'==1 {
	local firstdate = date2[1]
	local lastdate = date2[_N]
	twoway (connected newcases2 date2, sort msize(small) msymbol(point) lwidth(thin)), ///
		xlabel(`firstdate'(5)`lastdate', angle(ninety) valuelabel) xsize(8) ysize(4) ///
		title("`state' new cases") xtitle("") ytitle("New cases") name(`state'casesline, replace)
	graph save `state'newcasesl.gph, replace
	graph export `state'newcasesl.png, replace as(png)
		
	twoway (connected newdeaths2 date2, sort msize(small) msymbol(point) lwidth(thin)), ///
		xlabel(`firstdate'(5)`lastdate', angle(ninety) valuelabel) xsize(8) ysize(4) ///
		title("`state' new deaths") xtitle("") ytitle("New deaths") name(`state'deathsline, replace)	
	graph save `state'newdeathsl.gph, replace
	graph export `state'newdeathsl.png, replace as(png)
	
	twoway (connected casesma date2, sort msize(small) msymbol(point) lwidth(thin)), ///
		xlabel(`firstdate'(5)`lastdate', angle(ninety) valuelabel) xsize(8) ysize(4) ///
		title("`state' `days'-day moving average of new cases") xtitle("") ///
		ytitle("New cases") name(`state'casesmaline, replace)	
	graph save `state'newcasesmal.gph, replace
	graph export `state'newcasesmal.png, replace as(png)
			
	twoway (connected deathsma date2, sort msize(small) msymbol(point) lwidth(thin)), ///
		xlabel(`firstdate'(5)`lastdate', angle(ninety) valuelabel) xsize(8) ysize(4) ///
		title("`state' `days'-day moving average of new deaths") xtitle("") ///
		ytitle("New deaths") name(`state'deahts7line, replace)	
	graph save `state'newdeathsmal.gph, replace
	graph export `state'newdeathsmal.png, replace as(png)
		}		
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

	// first date to use
	keep if date2>=td(`first')

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

	if `bar'==1 {
	graph bar (asis) newcases2, over(newdate, label(angle(ninety) labsize(tiny))) ///
		blabel(bar, size(tiny) orientation(vertical)) xsize(8) ysize(4) title("`county' County `state' new cases") ///
		name(`state'`county'cases, replace)
	graph save `state'`county'newcases.gph, replace
	graph export `state'`county'newcases.png, replace as(png)

	graph bar (asis) newdeaths2, over(newdate, label(angle(ninety) labsize(tiny))) ///
		blabel(bar, size(tiny) orientation(vertical)) xsize(8) ysize(4) title("`county' County `state' new deaths") ///
		name(`state'`county'deaths, replace)
	graph save `state'`county'newdeaths.gph, replace
	graph export `state'`county'newdeaths.png, replace as(png)
	
	graph bar (asis) casesma, over(newdate, label(angle(ninety) labsize(tiny))) ///
		missing bar(1, fcolor(538p) fintensity(inten70) lcolor(538axis) lwidth(vvthin)) ///
		blabel(bar, size(tiny) format(%5.0f) orientation(vertical)) xsize(8) ysize(4) ///
		title("`county' County `state' `days'-day moving average of new cases") name(`state'`county'casesma, replace)
	graph save `state'`county'newcasesma.gph, replace
	graph export `state'`county'newcasesma.png, replace as(png)
	
	graph bar (asis) deathsma, over(newdate, label(angle(ninety) labsize(tiny))) ///
		missing bar(1, fcolor(538p) fintensity(inten70) lcolor(538axis) lwidth(vvthin)) ///
		blabel(bar, size(tiny) format(%5.0f) orientation(vertical)) xsize(8) ysize(4) ///
		title("`county' County `state' `days'-day moving average of deaths") name(`state'`county'deathsma, replace)
	graph save `state'`county'newdeathsma.gph, replace
	graph export `state'`county'newdeathsma.png, replace as(png)
	}
	if `line'==1 {
	local firstdate = date2[1]
	local lastdate = date2[_N]
	twoway (connected newcases2 date2, sort msize(small) msymbol(point) lwidth(thin)), ///
		xlabel(`firstdate'(5)`lastdate', angle(ninety) valuelabel) xsize(8) ysize(4) ///
		title("`county' County `state' new cases") xtitle("") ytitle("New cases") name(`state'`county'casesline, replace)
	graph save `state'`county'newcasesl.gph, replace
	graph export `state'`county'newcasesl.png, replace as(png)

	twoway (connected newdeaths2 date2, sort msize(small) msymbol(point) lwidth(thin)), ///
		xlabel(`firstdate'(5)`lastdate', angle(ninety) valuelabel) xsize(8) ysize(4) ///
		title("`county' County `state' new deaths") xtitle("") ytitle("New deaths") name(`state'`county'deathsline, replace)	
	graph save `state'`county'newdeathsl.gph, replace
	graph export `state'`county'newdeathsl.png, replace as(png)
	
	twoway (connected casesma date2, sort msize(small) msymbol(point) lwidth(thin)), ///
		xlabel(`firstdate'(5)`lastdate', angle(ninety) valuelabel) xsize(8) ysize(4) ///
		title("`county' County `state' `days'-day moving average of new cases") xtitle("") ///
		ytitle("`days'-day moving average of new cases") name(`state'`county'casesmaline, replace)	
	graph save `state'`county'newcasesmal.gph, replace
	graph export `state'`county'newcasesmal.png, replace as(png)
			
	twoway (connected deathsma date2, sort msize(small) msymbol(point) lwidth(thin)), ///
		xlabel(`firstdate'(5)`lastdate', angle(ninety) valuelabel) xsize(8) ysize(4) ///
		title("`county' County `state' `days'-day moving average of new deaths") xtitle("") ///
		ytitle("`days'-day moving average of new deaths") name(`state'`county'deahts7line, replace)			
		}	
	graph save `state'`county'newdeathsmal.gph, replace
	graph export `state'`county'newdeathsmal.png, replace as(png)
	}
}

