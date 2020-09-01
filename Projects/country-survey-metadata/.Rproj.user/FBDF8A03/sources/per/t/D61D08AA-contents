
# Clean workspace 
rm(list = ls())

# Load packages
library(openxlsx)

# Latest household survey -------------------------------------------------

# Source scripts 
source('r-scripts/collect-dhs.R')
source('r-scripts/collect-rhs.R', encoding = 'UTF-8')
source('r-scripts/collect-lsms.R')
source('r-scripts/collect-whs.R')
source('r-scripts/collect-mics.R')


# Latest population census (from unstats.un.org) --------------------------

# Source script 
source('r-scripts/collect-unstat-census.R')


# Vital registration from (from unstats.un.org)  --------------------------

# Source script
source('r-scripts/collect-unstat-vitstats.R')


# Write to Excel ---------------------------------------------------------

# Create vector with sheet names
sheet_names <- c('DHS', 'RHS', 'WHS',  'LSMS', 'MICS', 
                 'UN Census', 'UN Vitstats')

# Create list objects with all tables 
the_list <- list(dhs, rhs, whs, lsms, mics, 
                 un_census, un_vitstats)

# Write to Excel
wb <- createWorkbook()
for(i in 1:7){
  addWorksheet(wb, sheet_names[i])
  writeDataTable(wb, sheet = sheet_names[i], the_list[[i]], withFilter = FALSE)
  setColWidths(wb, sheet = sheet_names[i], cols = 1:ncol(the_list[[i]]), widths = 'auto')
}
saveWorkbook(wb, paste0('data/output/output-all-tables-', Sys.Date(), '.xlsx'),
             overwrite = TRUE)


