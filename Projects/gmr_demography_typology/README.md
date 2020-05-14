This folder contains an R script to classify countries into four groups

1.	Extract data for 1990, 2020, and 2035 via API (https://api.worldbank.org/v2/sources/40/) from the Population estimates and projections database.
•	Fertility rate, total (births per woman) (SP.DYN.TFRT.IN)
•	Population ages 15-64 (% of total population)(SP.POP.1564.TO.ZS)

2.	Classify countries based on the criteria below. For example, when a country has a zero or positive percent change in the working-age population between 2020 and 2035, and the total fertility rate was less than 2.1 percent in 1990, the country belongs to the post-dividend.

![GMR_typology](https://github.com/worldbank/WDI-Production/blob/Develop/Projects/gmr_demography_typology/01_rawdata/GMR_typology.png?raw=true "GMR Typology")


3.	Compare the result with the current member composition
