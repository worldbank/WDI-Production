##### ----- COLLECT COUNTRIES IN THE WOLRD HEALTH SURVEY FROM 2003 ---- #####



# Start up ----------------------------------------------------------------

message('Collecting countries that were included in the World Health Survey in 2003', appendLF = TRUE)

# Load custom functions 
source('r-scripts/_common.R')

# Load dataset with ISO codes
iso <- load_iso()


# Extract the countries ---------------------------------------------------

# Fetch HTML
the_url <- 'https://www.who.int/healthinfo/survey/countries/en/'
message('Extracting text from ', the_url)
the_html <- content(GET(the_url))

# Get the country names 
the_countries <- the_html %>%
  html_nodes('ul.disc li') %>% 
  html_text() %>% 
  sort()

# Finalize the data frame -------------------------------------------------

# Create data frame 
the_table <- data.frame(Country = the_countries)

# Add year column
the_table$Year <- 2003

# Add column with ISO codes
the_table <- merge(the_table, iso, by.x = 'Country', by.y = 'Country_name', all.x = TRUE)

# Subselect and reorder the relevant columns 
the_table <- the_table[c('ISO3', 'Country', 'Year')] 

# Add Type text column 
the_table$TypeText <- 'World Health Survey, 2003'

# Assing to whs object
whs <- the_table

# Clean workspace
rm(the_html, the_url, the_countries, the_table)
rm(iso)


message('Done! WHS survey table collected. ',
        'It has been assigned to the object \'whs\' in your workspace.', 
        appendLF = TRUE)
