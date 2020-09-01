##Make sure the R version is updated to R 4.0.2 before running the code

#Uncomment the next line to install the required packages. 
#install.packages(c("readxl","tidyverse","foreign","wbstats","countrycode"))

library(readxl)
library(tidyverse)
library(foreign)
library(wbstats)
library(countrycode)
library(here)

dir <- here()
#############################PPP EXTRAPOLATION_GDP############################

#######################Two sets of extrapolations######################### 

###############Extrapolating backwards from the year 2011#################

#Indicators for PPP EXTRAPOLATION_GDP
indicators_PPP_GDP= c("PA.NUS.PPP","NY.GDP.DEFL.ZS.AD")


#Pull Data from WDI using the package wbstats 
#documentation: "https://cran.r-project.org/web/packages/wbstats/vignettes/Using_the_wbstats_package.html"
df_2011 <- wb(country = "all",indicators_PPP_GDP,startdate = 1990,enddate = 2011,
         return_wide = T)

#Drop NA values
df_2011 <- drop_na(df_2011)

#Add in the WB regions
all_countries <- wb_countries()
all_countries <- all_countries[,c(1,7)]

df_2011 <- df_2011 %>% 
  left_join(all_countries)



#NOTE: For the European and non-European OECD countries, 
#we incorporate annual PPPs from the Eurostat-OECD PPP Programme and
#we drop their values from  this extrapolation. We also drop some countries 
#that are considered a special case. 
#Drop EUO, OECD, CRI and COL 

df_2011 <- subset(df_2011, region_iso3c!="ECS") 

df_2011 <- subset(df_2011, iso3c != "COL"& iso3c != "CRI" & iso3c != "AUS"
                  & iso3c != "CAN" & iso3c != "CHL" & iso3c != "ISR"
                  & iso3c != "JPN" & iso3c != "KOR" & iso3c != "MEX"
                  & iso3c != "MLT" & iso3c != "NZL")



df_2011$date <- as.numeric(df_2011$date)
df_2011$iso3c <- as.factor(df_2011$iso3c)

#Divide linked GDP deflator for each year by 2011 for all countries
df_2011 <- df_2011 %>%
  group_by(iso3c)%>%
  mutate(ratio=NY.GDP.DEFL.ZS.AD/NY.GDP.DEFL.ZS.AD[date==2011])

#The ratio generated for each country is then divided with the ratio for USA for each year
df_2011<- df_2011 %>%
  group_by(date) %>%
  mutate(multiplier=ratio/ratio[iso3c=="USA"])

#The resulting multiplier is then multiplied by benchmark PPP for the year 2011
df_2011 <- df_2011 %>% 
  group_by(iso3c) %>%
  mutate(PPP= multiplier*PA.NUS.PPP[date=="2011"])

#Check: Calculation matches the WDI data
df_2011$check <- df_2011$PA.NUS.PPP/df_2011$PPP

##########Extrapolating forwards from the year 2017######################

#Pull Data from WDI using the package wbstats (documentation above)
df_2017 <- wb(country="all",indicators_PPP_GDP,startdate = 2017,enddate = 2019,return_wide = T)

#Drop NA values
df_2017 <- drop_na(df_2017)

#Add in the WB regions
df_2017 <- df_2017 %>% 
  left_join(all_countries)



##Drop EUO,OECD,CRI and COL (special cases as explained above)

df_2017 <- subset(df_2017, region_iso3c!="ECS") 
df_2017 <- subset(df_2017, iso3c != "COL"& iso3c != "CRI" & iso3c != "AUS"
                         & iso3c != "CAN" & iso3c != "CHL" & iso3c != "ISR"
                         & iso3c != "JPN" & iso3c != "KOR" & iso3c != "MEX"
                         & iso3c != "MLT" & iso3c != "NZL")


df_2017$date <- as.numeric(df_2017$date)
df_2017$iso3c <- as.factor(df_2017$iso3c)

#Divide linked GDP deflator for each year by 2017 for all countries
df_2017<- df_2017%>%
  group_by(iso3c) %>%
  mutate(ratio=NY.GDP.DEFL.ZS.AD/NY.GDP.DEFL.ZS.AD[date==2017])

#The ratio generated for each country is then divided with the ratio for USA for each year
df_2017<- df_2017 %>%
  group_by(date) %>%
  mutate(multiplier=ratio/ratio[iso3c=="USA"])

#The resulting multiplier is then multiplied by benchmark PPP for the year 2017
df_2017<- df_2017 %>% 
  group_by(iso3c) %>%
  mutate(PPP= multiplier*PA.NUS.PPP[date==2017])

#Check: Calculation matches the WDI data
df_2017$check <- df_2017$PA.NUS.PPP/df_2017$PPP

#Combining both datasets
data_GDP <- rbind(df_2011,df_2017)

#Exporting it to excel for further validation 
write_csv(data_GDP,paste(dir, "Projects/icp/03_outputs/PPP_EXTRAPOLATION_GDP.csv", sep="/"))

###########################PPP EXTRAPOLATION _Private Consumption#######################################################
# The same process is applied for private consumption 

#Indicators required for PPP EXTRAPOLATION _Private Consumption
indicators_PPP_private= c("PA.NUS.PRVT.PP","FP.CPI.TOTL")

#Pull Data from WDI using the package wbstats (documentation link above)
df_2011 <- wb(country="all",indicators_PPP_private,startdate = 1990,enddate = 2011,
              return_wide = T)

#Drop NA values
df_2011 <- drop_na(df_2011)

#Add in the WB regions
df_2011 <- df_2011 %>% 
  left_join(all_countries)


#Drop EUO,OECD,CRI,COL and PSE (special cases as explained above) 


df_2011 <- subset(df_2011, region_iso3c!="ECS") 

df_2011 <- subset(df_2011, iso3c != "COL"& iso3c != "CRI" & iso3c != "AUS"
                  & iso3c != "CAN" & iso3c != "CHL" & iso3c != "ISR"
                  & iso3c != "JPN" & iso3c != "KOR" & iso3c != "MEX"
                  & iso3c != "MLT" & iso3c != "NZL" & iso3c != "PSE")


df_2011$date <- as.numeric(df_2011$date)
df_2011$iso3c <- as.factor(df_2011$iso3c)

#Divide Consumer Price Index for each year by 2011 for all countries
df_2011 <- df_2011 %>%
  group_by(iso3c)%>%
  mutate(ratio=FP.CPI.TOTL/FP.CPI.TOTL[date==2011])

#The ratio generated for each country is then divided with the ratio for USA for each year
df_2011<- df_2011 %>%
  group_by(date) %>%
  mutate(multiplier=ratio/ratio[iso3c=="USA"])

#The resulting multiplier is then multiplied by benchmark PPP for the year 2011
df_2011 <- df_2011 %>% 
  group_by(iso3c) %>%
  mutate(PPP= multiplier*PA.NUS.PRVT.PP[date=="2011"])

#Check: Calculation matches the WDI data
df_2011$check <- df_2011$PA.NUS.PRVT.PP/df_2011$PPP

##########Extrapolating forwards from the year 2017######################

#Pull Data from WDI using the package wbstats (documentation)
df_2017 <- wb(country="all",indicators_PPP_private,startdate = 2017,enddate = 2019,return_wide = T)

#Drop all NA values
df_2017 <- drop_na(df_2017)

#Add in the WB regions
df_2017 <- df_2017 %>% 
  left_join(all_countries)

#Drop EUO,OECD,CRI,COL and PSE (special cases as explained above)

df_2017 <- subset(df_2017, region_iso3c!="ECS") 

df_2017 <- subset(df_2017, iso3c != "COL"& iso3c != "CRI" & iso3c != "AUS"
                  & iso3c != "CAN" & iso3c != "CHL" & iso3c != "ISR"
                  & iso3c != "JPN" & iso3c != "KOR" & iso3c != "MEX"
                  & iso3c != "MLT" & iso3c != "NZL" & iso3c != "PSE")


df_2017$date <- as.numeric(df_2017$date)
df_2017$iso3c <- as.factor(df_2017$iso3c)

#Divide Consumer Price Index for each year by 2011 for all countries
df_2017<- df_2017%>%
  group_by(iso3c) %>%
  mutate(ratio=FP.CPI.TOTL/FP.CPI.TOTL[date==2017])

#The ratio generated for each country is then divided with the ratio for USA for each year
df_2017<- df_2017 %>%
  group_by(date) %>%
  mutate(multiplier=ratio/ratio[iso3c=="USA"])

#The resulting multiplier is then multiplied by benchmark PPP for the year 2017
df_2017<- df_2017 %>% 
  group_by(iso3c) %>%
  mutate(PPP= multiplier*PA.NUS.PRVT.PP[date==2017])

#Check: Calculation matches the WDI data
df_2017$check <- df_2017$PA.NUS.PRVT.PP/df_2017$PPP

#Combining both datasets
data_HHC <- rbind(df_2011,df_2017)

#Exporting it to excel for further validation 
write_csv(data_HHC,paste(dir, "Projects/icp/03_outputs/PPP_EXTRAPOLATION _Private Consumption.csv", sep="/"))



