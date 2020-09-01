#### ---- COLLECT UN POPULATION CENSUS TABLE ---- ####


# Start up  ---------------------------------------------------------------

message(
  'Collecting the latest poplulation census for all countries ',
  'from The UN\'s World Population and Housing Census Programme')

# Load packages if needed
if(!'httr' %in% .packages()) library(httr) 
if(!'rvest' %in% .packages()) library(rvest) 
if(!'dplyr' %in% .packages()) library(dplyr) 

# Load custom functions 
source('r-scripts/_common.R')

# Load dataset with ISO codes
iso <- load_iso()

# Extract the table  ------------------------------------------------------

# Create a string w/ the url for census tables 
the_url <- 'https://unstats.un.org/unsd/demographic-social/census/censusdates/'
message('Scraping table from ', the_url)

# Retrieve the HTML content 
the_html <- content(GET(the_url))

# Extract information from the footnotes tab 
h <- the_html %>% html_nodes('#Footnotes .row')
note <- h %>% html_nodes('[class^="col-md-"]:nth-child(1)') %>% html_text() %>% trimws()
text <- h %>% html_nodes('[class^="col-md-"]:nth-child(2)') %>% html_text() %>% trimws()
footnotes <- data.frame(note = note, text = text, stringsAsFactors = FALSE)
rm(h, note, text)

# Create a vector with HTML content to look for 
table_tabs <- sprintf('#%s .row', c('Africa', 'North', 'South', 'Asia', 'Europe', 'Oceania'))

# Extract information for the five continents 
dl <- list()
for(i in 1:length(table_tabs)){ 
  t <- the_html %>% html_nodes(table_tabs[i])
  dl[[i]] <- lapply(t, function(h){ 
    country <- h %>% html_nodes('[class^="col-md-"]:nth-child(1)') %>% html_text() %>% trimws() %>% gsub('.*\\r\\n +', '', .)
    round1990 <- h %>% html_nodes('[class^="col-md-"]:nth-child(2)') %>% html_text() %>% trimws() %>% gsub('.*\\r\\n +', '', .)
    round2000 <- h %>% html_nodes('[class^="col-md-"]:nth-child(3)') %>% html_text() %>% trimws() %>% gsub('.*\\r\\n +', '', .)
    round2010 <- h %>% html_nodes('[class^="col-md-"]:nth-child(4)') %>% html_text() %>% trimws() %>% gsub('.*\\r\\n +', '', .)
    round2020 <- h %>% html_nodes('[class^="col-md-"]:nth-child(5)') %>% html_text() %>% trimws() %>% gsub('.*\\r\\n +', '', .)
    out <- cbind(country, round1990, round2000, round2010, round2020)
    return(out)
  })
  # Bind the result for each tab together to a data frame
  dl[[i]] <- do.call('rbind', dl[[i]])
  # Remove the first row in each tab table (the header)
  #dl[[i]] <- dl[[i]][-1,]
}

# Convert to a single data frame 
df <- do.call('rbind', dl)
df <- data.frame(df, stringsAsFactors = FALSE)

# Clean objects from workspace
rm(i, t, dl, table_tabs)


# Data transformations  ---------------------------------------------------

# Fill empty rows with the previous country name 
for(i in 2:nrow(df)){ 
  df$country[i] <- with(df, ifelse(country[i] == '', country[i - 1], country[i]))
}
rm(i)

# Rename UK 
df$country <- with(df, ifelse(country %in%
                                c('- England and Wales', '- Scotland',  '- Northern Ireland'), 
                              'United Kingdom', 
                              country))

# Replace future survey dates with a string 'in the future' 
df$round2020 <- sub('[(].*[)]', 'in the future', df$round2020)

# Get the footnotes from each column 
footnote_df <- sapply(df, function(x){ 
  regmatches(x, gregexpr('[(][0-9]+[)]|[(][A-Z][)]', x)) %>% 
    ifelse(. == 'character(0)', '', .) %>% 
    as.character()
})

# Remove footnote from country name
df$country <- gsub('[(][0-9]+[)]', '', df$country)

# Remove trailing whitespace
df$country <- gsub('\\s+$', '', df$country)

# Replace day/month and other text with nothing (leaving only the year)
df[2:5] <- sapply(df[2:5], function(x){ 
  gsub('.* |.*[.]', '', x)
})

# Add a column with the latest survey year  
df$year <- apply(df, 1, function(x){ 
  # Convert row to numeric 
  row <- suppressWarnings(as.numeric(x))
  # Get the maximum value 
  m <- x[which.max(row)]
  # Convert to character
  m <- as.character(m)
  # Set value to NA if there is no survey year for any round 
  if(length(m) == 0) m <- NA
  return(m)
})
df$year <- as.numeric(df$year)


# Add footnotes -----------------------------------------------------------

# Footnote(s) from country column 
fn1 <- footnote_df[,1]

# Footnote(s) from the latest survey year 
t <- apply(df[2:5], 1, function(x){ 
  # Convert row to numeric 
  row <- suppressWarnings(as.numeric(x))
  # Get the maximum value 
  m <- which.max(row)
  if(length(m) == 0) m <- NA
  m[[1]]
})
fn2 <- list()
for(i in 1:nrow(footnote_df)){
  fn2[[i]] <- footnote_df[i, t[i]+1 ]
}
rm(i, t, footnote_df)

fn2 <- unname(unlist(fn2))
fn2 <- ifelse(is.na(fn2), '', fn2)

# Add footnote column to data frame
# df$footnote1 <- fn1
# df$footnote2 <- fn2
df$footnote <- ifelse(fn1 == '', fn2, fn1)
rm(fn1, fn2)

#Fix footnote for Germany
df$footnote <- ifelse(df$country == 'Germany', '(18)', df$footnote)

# Merge footnotes with df
df <- merge(df, footnotes, by.x = 'footnote', by.y = 'note', all.x = TRUE)

# Combine text and text columns 
df$text <- with(df, ifelse(is.na(text), '', text))
df$footnote <- with(df, paste(footnote, text))
df$text <- NULL

# Finalize the data frame -------------------------------------------------

# Add column with ISO codes
df <- merge(df, iso, by.x = 'country', by.y = 'Country_name', all.x = TRUE)

# Subselect the last survey year for each country
df <- df %>%
  group_by(country) %>%             # Group by country
  arrange(desc(year)) %>%           # Order by descending year
  slice(1) %>%                      # Select first row from each group
  ungroup() %>%
  as.data.frame()

# x <- df %>%
#   group_by(country) %>%             # Group by country
#   filter(year == max(year, na.rm = TRUE)) %>%     # Select the survey(s) from the latest year 
#   ungroup() %>%
#   as.data.frame()


# Rename columns
names(df) <- firstup(names(df))

# Rearrange columns 
df <- df[c('ISO3', 'Country', 'Year', 'Footnote')] # 'Round1990', 'Round2000', 'Round2010', 'Round2020',

# Assign to 'un_census' object 
un_census <- df 

# Clean workspace 
rm(footnotes, the_html, the_url)
rm(df, iso)

message('Done! UN Census table collected. ',
        'It has been assigned to the object \'un_census\' in your workspace.', 
        appendLF = TRUE)
