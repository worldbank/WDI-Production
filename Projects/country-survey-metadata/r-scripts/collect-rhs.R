##### ----- COLLECT TABLE FOR REPRODUCTIVE HEALTH SURVEYS FROM CDC ---- ####


# Start up ----------------------------------------------------------------

message('Collecting Reproductive health surveys from CDV.', appendLF = TRUE)

# Load packages if needed
if(!'httr' %in% .packages()) library(httr) 
if(!'rvest' %in% .packages()) library(rvest) 
if(!'dplyr' %in% .packages()) library(dplyr) 

# Load custom functions 
source('r-scripts/_common.R')

# Load dataset with ISO codes
iso <- load_iso()


# Extract the table -------------------------------------------------------

# Fetch the HTML content
the_url <- 'https://www.cdc.gov/reproductivehealth/global/tools/surveys.htm'
message('Extracting table from ', the_url)
the_html <- content(GET(the_url))

# Extract the table 
the_table <- the_html %>% 
  html_nodes('table') %>% 
  html_table() %>% 
  as.data.frame()

# Remove rows that are regions separators 
the_table <- the_table[!the_table$Country.Year %in% 
                         c('Africa', 'Eastern Europe & Central Asia', 'Latin America & the Caribbean',
                           'Middle East'),]

# Subselect the relevant columns
the_table <- the_table[c('Country.Year', 'Series')]

# Seperate year and country into separate columns 
the_table$Period <- with(the_table, regmatches(Country.Year, regexpr('[0-9]{4}(.[0-9]{4})?', Country.Year)))
the_table$Country <- gsub('[0-9]{4}(.[0-9]{4})?', '', the_table$Country.Year)
the_table$Country.Year <- NULL

# Remove trailing whitespace
the_table$Country <- gsub('\\s+$', '', the_table$Country)

# Create a new column 'Year' with the latest year from the survey  --------

# Subset the latest year from the period variable 
final_year <- gsub('–|-', '', with(the_table, 
                                 regmatches(Period, 
                                            regexpr('–[0-9]{4}|-[0-9]{4}', Period))))
# Add an empty Year column 
the_table$Year <- NA

# Set the Year column to the final year if the survey period covers multiple years 
the_table[grepl('[–-][0-9]{4}', the_table$Period),]$Year <- final_year 

# Set Year equal to Period if there is only one year 
the_table$Year <- with(the_table, ifelse(is.na(Year), Period, Year))


# Finalize the data frame -------------------------------------------------


# Remove regional country surveys 
the_table$Country <- enc2utf8(the_table$Country) # Recode country names to UTF-8
the_table <- the_table[!grepl('[A-Z][a-z]+—[A-Z][a-z]+',
                              the_table$Country),]
the_table <- the_table[!grepl('Brazil—São Paulo State|Tanzania – Kigoma Region',
                              the_table$Country),]

# Add column with Type text 
the_table$TypeText <- with(the_table, ifelse(Series == 'RHS', 
                                            paste(Country, 'Reproductive Health Survey'), 
                                             ''))
the_table$TypeText <- with(the_table, ifelse(Series == 'YARHS', 
                                             paste(Country, 'Young Adult Reproductive Health Survey'), 
                                             TypeText))
the_table$TypeText <- with(the_table, paste(TypeText, sub('-|–', '/', Period), sep = ', '))

# Add column with ISO codes
the_table <- merge(the_table, iso, by.x = 'Country', by.y = 'Country_name', all.x = TRUE)

# Subselect and reorder the relevant columns 
the_table <- the_table[c('ISO3', 'Country', 'Year', 'Period', 'Series', 'TypeText')]

# Subselect the last survey year for each country
the_table <- the_table %>%
  group_by(Country) %>%                           # Group by country
  filter(Year == max(Year, na.rm = TRUE)) %>%     # Select the latest survey year 
  ungroup() %>%
  as.data.frame()

# Assign the table to an object named cdc
rhs <- the_table

# Clean workspace
rm(the_url, the_html, the_table, final_year)
rm(iso)

message('Done! RHS survey table collected. ',
        'It has been assigned to the object \'rhs\' in your workspace.', 
        appendLF = TRUE)
