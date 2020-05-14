#### ---- COLLECT SURVEY TABLE FROM THE LSMS (THE WORLD BANK) ---- ####


# Start up  ---------------------------------------------------------------

message('Collecting LSMS survey table from The World Bank.', appendLF = TRUE)

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
the_url <- 'http://surveys.worldbank.org/lsms/our-work/data/data-table'
message('Extracting table from ', the_url)
the_html <- content(GET(the_url))

# Extract the correct table 
the_table <- the_html %>% 
  html_nodes('table') %>% 
  .[[2]] %>% 
  html_table(fill = TRUE)

# Fill empty rows with the previous country name 
for(i in 2:nrow(the_table)){ 
  the_table$Country[i] <- with(the_table, ifelse(Country[i] == '' | is.na(Country[i]),
                                                 Country[i - 1], Country[i]))
}
rm(i)


# Create new year and period variables ------------------------------------


# Create a new column for the survey period 
the_table$Period <- the_table$Year
the_table$Period <- gsub('[/]', '-', the_table$Period)

# Subset the latest year from the period variable 
final_year <- gsub('-', '', with(the_table, 
                                 regmatches(Period, 
                                            regexpr('-[0-9]+', 
                                                    Period))))

# Complete the year (1/2 means 1991/1992)
final_year <- ifelse(final_year %in% c('1', '2'), 
                     sprintf('199%s', final_year), 
                     final_year)


# Complete the year (1980/1990 if it starts with 8 or 9)
final_year <- ifelse(grepl('^[89]', final_year) & nchar(final_year) == 2, 
                     sprintf('19%s', final_year), 
                     final_year)

# Complete the year (2000/2010 if it starts with 0 or 1)
final_year <- ifelse(grepl('^[01]', final_year) & nchar(final_year) == 2, 
                     sprintf('20%s', final_year), 
                     final_year)

# Set the Year column to the final year if the survey period covers multiple years 
the_table[grepl('-[0-9]+', the_table$Period),]$Year <- final_year 


# Finalize the data frame  ------------------------------------------------

# Rename Burkina Faso
the_table$Country <- gsub('BURKINA FASO', 'Burkina Faso', the_table$Country)

# Remove surveys for Peru that only where conducted in Lima
the_table <- the_table[!grepl('Lima only', the_table$Country),]

# Remove other regional surveys 
the_table <- the_table[!grepl('India - Uttar Pradesh and Bihar|Tanzania - Kagera',
                              the_table$Country),]
# Change name of Tanzania 
the_table$Country <- sub('Tanzania - National', 
                         'Tanzania', 
                         the_table$Country)

# Add column with ISO codes
the_table <- merge(the_table, iso, by.x = 'Country', 
                   by.y = 'Country_name', all.x = TRUE)

# Add type text column 
the_table$TypeText <- with(the_table, paste('Living Standards Measurement Study',
                                            sub('-', '/', Period), sep = ', '))

# Subselect and reorder the relevant columns 
#names(the_table) <- sub(' ', '_', names(the_table))
the_table <- the_table[c('ISO3', 'Country', 'Year', 
                         'Period','Household Count', 'TypeText')]   

# Subselect rows with the last survey year for each country
the_table <- the_table %>%
  group_by(Country) %>%                           # Group by country
  filter(Year == max(Year, na.rm = TRUE)) %>%     # Select the latest survey year 
  ungroup() %>%
  as.data.frame()

# Assign table to dhs object

# Assing the table to an object named lsms
lsms <- the_table

# Clean workspace
rm(the_url, the_html, the_table, final_year)
rm(iso)

message('Done! LSMS survey table collected. ',
        'It has been assigned to the object \'lsms\' in your workspace.', 
        appendLF = TRUE)


