
# Start up ----------------------------------------------------------------

message('Collecting MICS survey table.')

# Load packages and functions
if(!'dplyr' %in% .packages()) library(dplyr) 
source('r-scripts/_common.R')

# Load dataset with ISO codes
iso <- load_iso()


# Extract the table  ------------------------------------------------------

# Read in dataset (downloaded manually)
message('Reading dataset from \'data/input/surveys_catalogue.csv\'. Note: This needs to be downloaded manually')
the_table <- read.csv('data/input/surveys_catalogue.csv', stringsAsFactors = FALSE, encoding = 'UTF-8')

# Data transformations ----------------------------------------------------

# Create period and final year columns
the_table$period <- the_table$year
the_table$year <- gsub('[0-9]{4}-', '', the_table$year)

# Filter surveys where data has been collected (either completed or in 'data processing' stage)
the_table <- with(the_table, the_table[status %in% c('Completed', 'Data processing / analysis'),])

# Remove rows that don't appear to be country wide surveys 
the_table <- the_table[!grepl('[(].*[)]', the_table$country),]

# Add column with type text 
the_table$typeText <- paste('Multiple Indicator Cluster Survey', 
                            sub('-', '/', the_table$period), sep = ', ')


# Finalize the data frame -------------------------------------------------

# Add column with ISO codes
the_table <- merge(the_table, iso, by.x = 'country', 
                   by.y = 'Country_name', all.x = TRUE)

# Captialize variable names 
names(the_table) <- firstup(names(the_table)) 

# Subselect and reorder columns
the_table <- the_table[c('ISO3', 'Country', 'Year', 'Period', 'Status', 'Datasets', 'Round', 'TypeText')]

# Subselect the last survey year for each country
the_table <- the_table %>%
  group_by(Country) %>%                           # Group by country
  filter(Year == max(Year, na.rm = TRUE)) %>%     # Select the latest survey year 
  ungroup() %>%
  as.data.frame()

# Assign to mics
mics <- the_table

# Clean up workspace
rm(iso, the_table, firstup)

message('Done! MICS survey table collected. ',
        'It has been assigned to the object \'mics\' in your workspace.', 
        appendLF = TRUE)
