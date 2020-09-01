

# Start up ----------------------------------------------------------------

# Clean workspace 
rm(list = ls())

# Load packages
library(rvest)
library(openxlsx)

# Latest household survey -------------------------------------------------

# Source scripts 
source('r-scripts/collect-dhs.R')
source('r-scripts/collect-rhs.R', encoding = 'UTF-8')
source('r-scripts/collect-lsms.R')
source('r-scripts/collect-whs.R')
source('r-scripts/collect-mics.R')

# Subselect columns 
hs_vars <- c('ISO3', 'Year', 'TypeText')
dhs <- dhs[hs_vars]
rhs <- rhs[hs_vars]
lsms <- lsms[hs_vars]
whs <- whs[c(hs_vars)]
mics <- mics[hs_vars]

# Latest population census (from unstats.un.org) --------------------------

# Source script 
source('r-scripts/collect-unstat-census.R')

# Combine footnote and Year columns 
un_census$Year <- with(un_census, ifelse(is.na(Year), '', Year))
un_census$Year <- with(un_census, paste0(Year, Footnote))
un_census$Year <- gsub('[(][0-9][)]', '.', un_census$Year)
un_census$Footnote <- NULL

# Subselect columns
un_census <- un_census[c('ISO3', 'Year')]

# Rename Year to 'Latest population census'
names(un_census) <- sub('Year', 'Latest population census',
                        names(un_census))

# Vital registration from (from unstats.un.org)  --------------------------

# Source script
source('r-scripts/collect-unstat-vitstats.R')

# Subselect columns
un_vitstats <- un_vitstats[c('ISO3', 'Complete')]

# Rename 'Complete' to 'Vital registration complete'
names(un_vitstats) <- sub('Complete', 'Vital registration complete',
                        names(un_vitstats))

# Combine tables  ---------------------------------------------------------

# Combine household survey tables 
hs_survey <- merge(dhs, rhs, by = hs_vars, all = TRUE)
hs_survey <- merge(hs_survey, lsms, by = hs_vars, all = TRUE)
hs_survey <- merge(hs_survey, mics, by = hs_vars, all = TRUE)
hs_survey <- merge(hs_survey, whs, by = hs_vars, all = TRUE)

# Select latest survey year 
hs_survey <- hs_survey %>% 
  group_by(ISO3) %>% 
  filter(Year == max(Year)) %>% 
  ungroup() %>% 
  as.data.frame()

# Delete year variable
hs_survey$Year <- NULL

# Rename Year column
names(hs_survey) <- sub('TypeText', 'Latest household survey',
                        names(hs_survey))

# Merge the combined health survey table with the census table  
output <- merge(hs_survey, un_census,
                by = 'ISO3',
                all = TRUE)

# Merge the combined output with the vital registration table 
output <- merge(output, un_vitstats,
           by = 'ISO3',
           all = TRUE)

# Remove objects from workspace
rm(whs, rhs, dhs, lsms, mics, hs_survey,
   un_census, un_vitstats, hs_vars)


# Add offical contry names (from iban.com) --------------------------------

# Fetch table with coutry codes from iban.com
the_url <- 'https://www.iban.com/country-codes'
iban_cc <- the_url %>% 
  read_html() %>% 
  html_node('table') %>% 
  html_table() %>% 
  select(Country, `Alpha-3 code`)%>%  
  as.data.frame()

# Merge data frames 
output <- merge(output, iban_cc, by.x = 'ISO3', 
                by.y='Alpha-3 code', all = TRUE)

# Reorder columns
output <- output[c("ISO3", "Country", "Latest household survey", 
         "Latest population census", "Vital registration complete")]

# Add country code for Kosovo 
output$Country <- with(output, ifelse(ISO3 == 'XKX', 'Kosovo', Country)) 

# Add country code for Netherlands Antilles
output$Country <- with(output, ifelse(ISO3 == 'ANT', 'Netherlands Antilles', Country)) 

# Remove objects from workspace 
rm(iban_cc, the_url)

# Write to Excel ----------------------------------------------------------

# Rename columns 
names(output)[1:2] <- c('Country', 'Table name')

# Recode NA to empty string
output[is.na(output)] <- ''

output$`Latest population census`

# Write to Excel
wb <- createWorkbook()
addWorksheet(wb, 'Country_Table', gridLines = TRUE)
writeDataTable(wb, sheet = 'Country_Table', output, withFilter = TRUE)
setColWidths(wb, 'Country_Table', cols=1:5, widths = c(10, 55, 68, 25, 25))
saveWorkbook(wb, paste0('data/output/output-country-info-', Sys.Date(), '.xlsx'),
             overwrite = TRUE)
rm(wb)
