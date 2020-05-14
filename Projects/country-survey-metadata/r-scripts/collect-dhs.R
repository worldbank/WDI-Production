##### ----- COLLECT SURVEY TABLE FROM THE DHS PROGRAMME ---- #####


# Start up  ---------------------------------------------------------------

message('Collecting household survey table from the DHS Programme.', appendLF = TRUE)

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
the_url <- 'https://dhsprogram.com/What-We-Do/survey-search.cfm?pgtype=main&SrvyTp=year'
message('Scraping table from ', the_url, appendLF = TRUE)
the_html <- content(GET(the_url))

# Extract the correct table 
the_table <- the_html %>% 
  html_nodes('table') %>% 
  html_nodes('[bordercolor="whitesmoke"]') %>% 
  html_table() %>% 
  as.data.frame()

# Rename the column names
names(the_table) <- the_table[1,]
the_table <- the_table[-1,]

# Remove rows the that are just year seperators
the_table <- the_table[!grepl('^[0-9]{4}', the_table$`Country/Year`),]

# Split country name and survey period ------------------------------------

# Create a new column for the year/period 
the_table$Period <- 
  with(the_table, regmatches(`Country/Year`,
                             regexpr('[0-9]{4}(-[0-9]{2})?', 
                                     `Country/Year`)))

# Create a new column for the country names 
the_table$Country <- gsub('[0-9]{4}(-[0-9]{2})?', '',
                          the_table$`Country/Year`)

# Delete the old column 
the_table$`Country/Year` <- NULL

# Create a new column 'Year' with the latest year from the survey  --------

# Subset the latest year from the period variable 
final_year <- gsub('-', '', with(the_table, 
                                 regmatches(Period, 
                                            regexpr('-[0-9]{2}', Period))))
# Complete the year (1980/1990 if it starts with 8 or 9, otherwise 2000)
final_year <- ifelse(grepl('^[89]', final_year), 
                     sprintf('19%s', final_year), 
                     sprintf('20%s', final_year))

# Add an empty Year column 
the_table$Year <- NA

# Set the Year column to the final year if the survey period covers multiple years 
the_table[grepl('-[0-9]{2}', the_table$Period),]$Year <- final_year 

# Set Year equal to Period if there is only one year 
the_table$Year <- with(the_table, ifelse(is.na(Year), Period, Year))

# Add a column with footnotes  --------------------------------------------

# Extract footnotes from the HTML 
footnotes <- the_html %>% 
  html_nodes('.smalltext ol li') %>% 
  html_text()

# Slit the text by footnote number and text 
split_text <- strsplit(footnotes, ')')

# Create a data frame 
footnotes <- data.frame(id = sapply(split_text, function(x) x[[1]]),
                        footnote = sapply(split_text, function(x) x[[2]]),
                        stringsAsFactors = FALSE)
# Add the footnote number to the text 
footnotes$footnote <- with(footnotes, paste(id, footnote, sep = ') '))

# Add a temp. footnote id to the table
the_table$footnote_id <- the_table$Country %>% 
  gsub('.* ', '', .) %>%
  gsub('[()]|\\s', '', .)

# Merge footnotes into the table 
the_table <- merge(the_table, footnotes, by.x = 'footnote_id', by.y = 'id', all.x = T)

# Remove footnote id column 
the_table$footnote_id <- NULL

# Remove footnote id from the Country column
the_table$Country <- the_table$Country %>% 
  gsub('[(].*[()]|\\s\\s+', '', .) %>% 
  trimws()


# Add a column with type text ---------------------------------------------

# DHS surveys 
# the_table$TypeText <- with(the_table, ifelse(grepl(' DHS', Type),
#                                              sub('DHS', 'Demographic and Health Survey', Type),
#                                              ''))
the_table$TypeText <- with(the_table, ifelse(Type == 'Standard DHS', 
                                             'Demographic and Health Survey', 
                                             ''))
the_table$TypeText <- with(the_table, ifelse(Type == 'Continuous DHS', 
                                             'Continuous Demographic and Health Survey', 
                                             TypeText))
the_table$TypeText <- with(the_table, ifelse(Type == 'Interim DHS', 
                                             'Interim Demographic and Health Survey', 
                                             TypeText))
the_table$TypeText <- with(the_table, ifelse(Type == 'Special DHS', 
                                             'Special Demographic and Health Survey', 
                                             TypeText))

# Malaria Indicator Survey
the_table$TypeText <- with(the_table, ifelse(Type == 'MIS', 
                                             'Malaria Indicator Survey', 
                                             TypeText))
# Multiple Indicator Cluster Survey
the_table$TypeText <- with(the_table, ifelse(Type == 'MICS', 
                                             'Multiple Indicator Cluster Survey', 
                                             TypeText))
# AIDS Indicator Survey
the_table$TypeText <- with(the_table, ifelse(Type == 'Standard AIS', 
                                             'AIDS Indicator Survey', 
                                             TypeText))

# Service Provision Assessment Survey (not sure what these should be called )
the_table$TypeText <- with(the_table, ifelse(grepl('SPA', Type), 
                                             paste(Country, 'Service Provision Assessment Survey'), 
                                             TypeText))
# the_table$TypeText <- with(the_table, ifelse(Type == 'MCH SPA', 
#                                              'Maternal and Child Health Service Provision Assessment Survey', 
#                                              TypeText))
# the_table$TypeText <- with(the_table, ifelse(Type == 'HIV SPA', 
#                                              'HIV Service Provision Assessment Survey', 
#                                              TypeText))

# Knowledge, Attitude and Practices Survey
the_table$TypeText <- with(the_table, ifelse(Type == 'KAP', 
                                             'Knowledge, Attitude and Practices Survey', 
                                             TypeText))

# Special surveys (guessing these are national surveys) 
the_table$TypeText <- with(the_table, ifelse(Type == 'Special', 
                                             paste0(Country, sub('.*[)] ', '', sub('[(].*', '', footnote))),
                                             TypeText))

# In Depth and Experimental surveys (not sure what these are)
the_table$TypeText <- with(the_table, ifelse(Type %in% c('In Depth', 'Experimental'), 
                                             paste0(Country, Type),
                                             TypeText))

# Add period to the the type text 
the_table$TypeText <- with(the_table, paste(TypeText, sub('-', '/', Period), sep = ', '))


# Finalize data frame  ---------------------------------------------------

# Add column with ISO codes
the_table <- merge(the_table, iso, by.x = 'Country', by.y = 'Country_name', all.x = TRUE)

# Subselect and reorder the relevant columns 
the_table <- the_table[c('ISO3', 'Country', 'Year', 'Period', 'Type', 'Status', 
                         'Phase', 'Recode', 'Dates of Fieldwork', 'TypeText')]                       

# Remove surveys where the is no date for the field work (Note: affects Pakistan 2019)
the_table <- the_table[!grepl('--', the_table$`Dates of Fieldwork`),]

# Remove surveys where the survey date is set to a date in the future
dates <- paste('01/', gsub('.*- ', '', the_table$`Dates of Fieldwork`)) # Create a vector with dates to filter on 
dates <- as.Date(dates, format = '%d/%m/%Y')
the_table <- the_table[dates < Sys.Date(),]  # Remove dates lower then today's date

# select the last survey year for each country
the_table <- the_table %>%
  group_by(Country) %>%                           # Group by country
  filter(Year == max(Year, na.rm = TRUE)) %>%     # Select the latest survey year 
  ungroup() %>%
  as.data.frame()

# Assign table to dhs object
dhs <- the_table

# Clean workspace 
rm(the_url, the_html, the_table, footnotes,
   final_year, split_text, dates)
rm(iso)

message('Done! DHS Programme survey table collected. ',
        'It has been assigned to the object \'dhs\' in your workspace.', 
        appendLF = TRUE)
