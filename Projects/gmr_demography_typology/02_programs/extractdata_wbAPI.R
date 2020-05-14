rm(list=ls()) # clean environment
library("rjson")
library("dplyr")
library("readxl")
# https://api.worldbank.org/v2/sources/40/
# https://api.worldbank.org/v2/country/all/indicator/SP.DYN.TFRT.IN?date=1990&source=40&per_page=300
# Fertility rate, total (births per woman) (SP.DYN.TFRT.IN)
# Population ages 15-64 (% of total population)(SP.POP.1564.TO.ZS)
ind_list = c("SP.DYN.TFRT.IN", "SP.POP.1564.TO.ZS")
year_list = c(1990, 2020, 2035)
full_ind <- data.frame() 

for (indicator in ind_list){ 
  for (year in year_list){
  indurl = paste("https://api.worldbank.org/v2/country/All/indicator/", indicator, 
                 "?date=", year, "&source=40&per_page=300&format=json", sep = "")
  ind_raw = RJSONIO::fromJSON(indurl, nullValue=NA)[[2]]
  ind = lapply(ind_raw, 
               function(j) cbind(as.character(j$indicator["id"]), as.character(j$indicator["value"]),
                                 as.character(j$country["value"]), as.character(j$country["id"]),
                                 j$date, j$value))
  ind = data.frame(do.call('rbind', ind), stringsAsFactors = FALSE)
  colnames(ind) = c( "IndicatorCode", "IndicatorName", "Country", "CountryID", "Year", "Value")
  full_ind<-rbind(full_ind, ind)
  }
}
# full_ind is the long format version of the extracted data

# covert long format data to wide format data
wide_ind <- reshape(full_ind, idvar = c( "IndicatorCode", "IndicatorName", "Country", "CountryID"), timevar = "Year", direction = "wide")
wide_ind_pop = wide_ind[wide_ind$IndicatorCode == "SP.POP.1564.TO.ZS",]
colnames(wide_ind_pop) = c( "IndicatorCode", "IndicatorName", "Country", "CountryID", "pop1990", "pop2020", "pop2035")
wide_ind_pop$growth_2020_2035 <- as.numeric(wide_ind_pop$pop2035)/as.numeric(wide_ind_pop$pop2020) - 1
#library(dplyr)
wide_ind_pop_growth <- wide_ind_pop %>% 
  select( "Country", "CountryID", "pop1990", "pop2020", "pop2035", "growth_2020_2035")

wide_ind_fer <- wide_ind[wide_ind$IndicatorCode == "SP.DYN.TFRT.IN",]
colnames(wide_ind_fer) = c( "IndicatorCode", "IndicatorName", "Country", "CountryID", "fer1990", "fer2020", "fer2035")
drops <- c("IndicatorCode", "IndicatorName")
wide_ind_fer<-wide_ind_fer[ , !(names(wide_ind_fer) %in% drops)]
fer_pop <- merge(wide_ind_pop_growth, wide_ind_fer, by = c("Country", "CountryID"), all = TRUE)

fer_pop$Classify<-ifelse(fer_pop["fer1990"]  <2.1 & fer_pop["growth_2020_2035"]<=0 , "Post-dividend",
               ifelse(fer_pop["fer1990"] >=2.1 & fer_pop["growth_2020_2035"]<=0, "Late-dividend",
               ifelse(fer_pop["fer2020"] < 4 & fer_pop["growth_2020_2035"]>0, "Early-dividend", 
               ifelse(fer_pop["fer2020"] >= 4 & fer_pop["growth_2020_2035"]>0, "Pre-dividend", 
               "None"))))
fer_pop$Group_2020<-ifelse(fer_pop["fer1990"]  <2.1 & fer_pop["growth_2020_2035"]<=0 , "PST",
                  ifelse(fer_pop["fer1990"] >=2.1 & fer_pop["growth_2020_2035"]<=0, "LTE",
                  ifelse(fer_pop["fer2020"] < 4 & fer_pop["growth_2020_2035"]>0, "EAR", 
                  ifelse(fer_pop["fer2020"] >= 4 & fer_pop["growth_2020_2035"]>0, "PRE", 
                  "None"))))

#library("readxl")
df <- read_excel("C:/Users/wb546131/OneDrive - WBG/GMR_typology/Trac.xls", sheet = "TRAC", col_names = FALSE)
colnames(df) = df[2, ] #name the columns based on the second row
df = df[-(1:2), ] # remove first 2 rows
n<-dim(df)[1]
df<-df[1:(n-6),] # remove last 6 rows
# df_H <- df %>% 
#   select( "Code", "Country", "LDC")
df_M <- df %>% 
  select( "Code", "Country", "Demo Div")
colnames(df_M) = c("Code", "Country_Trac", "Group_2015")

compare_results <- merge(fer_pop, df_M, by.x =  c("CountryID"), by.y = c("Code"), all = TRUE)
#compare_results_country <- merge(fer_pop, df_H, by.x =  c("CountryID"), by.y = c("Code"))

# dorp rows when Country_Trac = NA, which means drop regional/aggregate data points.
results = compare_results[!is.na(compare_results$Country_Trac), ]
rownames(results) <- NULL # make the index number in order

write.csv(results, "C:/Users/wb546131/OneDrive - WBG/GMR_typology/compare_final.csv")

