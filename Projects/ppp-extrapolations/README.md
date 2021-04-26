This folder contains the R script to extrapolate PPP conversion factors for GDP and private consumption for the years before 2011 and after 2017. The methodology with examples is further described [here](https://datahelpdesk.worldbank.org/knowledgebase/articles/665452-how-do-you-extrapolate-the-ppp-conversion-factors).

1.	Extract CPI ([FP.CPI.TOTL](https://data.worldbank.org/indicator/FP.CPI.TOTL)), GDP Deflator ([NY.GDP.DEFL.ZS.AD](https://data.worldbank.org/indicator/NY.GDP.DEFL.ZS.AD)) from 1990 to current year using the [wbstats](https://cran.r-project.org/web/packages/wbstats/wbstats.pdf) package from the [World Development Indicators (WDI)](https://datacatalog.worldbank.org/dataset/world-development-indicators) database. It also extracts the PPP conversion factors for the two recent [ICP](https://www.worldbank.org/en/programs/icp) benchmark years and the years in between, i.e. 2011-2017.

2.	Next, run the code *Basic_code_for_extrapolated_PPPs.R* which contains all the main steps and calculations along with annotations to produce the final output i.e. extrapolated PPP conversion factors for GDP and private consumption. This is stored under 02_programs. 

3.	The extrapolated PPPs are stored under 03_outputs folder. Compare the result with the data already stored in the WDI database [[PA.NUS.PPP](https://data.worldbank.org/indicator/PA.NUS.PPP) (GDP), [PA.NUS.PRVT.PP](https://data.worldbank.org/indicator/PA.NUS.PRVT.PP) (private consumption)] as a validation check to see if the code produced the correct results. 

