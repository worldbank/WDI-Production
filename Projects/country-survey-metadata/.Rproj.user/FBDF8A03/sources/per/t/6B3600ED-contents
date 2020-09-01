
# Custom function to read in ISO codes
load_iso <- function(path = 'data/input/iso3.csv'){
  message('Load ISO codes data frame')
  iso <-  read.csv(path, stringsAsFactors = FALSE, fileEncoding = 'UTF-8')
  iso
}

# Custom function to captialize a string
firstup <- function(x) {
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  x
}

# Custom function to extract the table from the UN Vitstats PDF 
extract_df <- function(t){
  
  x <- as.data.frame(t, stringsAsFactors = FALSE)
  x <- x[!grepl('AFRICA|AMERICA, NORTH|AMERICA, SOUTH|ASIA|EUROPE|OCEANIA',x$V1),]
  x <- x[!x$V1 %in% c('', 'Continent and country or area'),]
  x <- x[!x$V2 == '',]
  countries <- gsub('[0-9]+(,[0-9]+)?$', '',x$V1)
  countries <- ifelse(countries == 'Korea', 
                      'Democratic People\'s Republic of Korea',
                      countries)
  countries <- ifelse(countries == 'Northern Ireland', 
                      'United Kingdom of Great Britain and Northern Ireland',
                      countries)
  
  footnotes <- ifelse(
    grepl('[0-9]+(,[0-9]+)?$',x$V1),
    regmatches(x$V1, regexpr('[0-9]+(,[0-9]+)?$',x$V1)),
    '')
  live.births.year <- sapply(strsplit(x$V2, ' '), function(x) x[[1]])
  live.births.code <- sapply(strsplit(x$V2, ' '), function(x) x[[2]])
  live.births.number <- gsub(' ', '', x$V3)
  live.births.rate <- sapply(strsplit(x$V4, ' '), function(x) x[[1]])
  
  deaths.year <- sapply(strsplit(x$V4, ' '), function(x) x[[2]])
  deaths.code <- sapply(strsplit(x$V4, ' '), function(x) x[[3]])
  deaths.number <- 
    ifelse(sapply(strsplit(x$V4, ' '), length) == 4,
           sapply(strsplit(x$V4, ' '), function(x) x[[4]]),
           lapply(strsplit(x$V4, ' '), function(x) paste(x[4:5], collapse = ''))
    )
  deaths.number <- unlist(deaths.number)
  death.rate <- sapply(strsplit(x$V5, ' '), function(x) x[[1]])
  
  infant.deaths.year <- sapply(strsplit(x$V5, ' '), function(x) x[[2]])
  infant.deaths.code <- sapply(strsplit(x$V5, ' '), function(x) x[[3]])
  infant.deaths.number <- 
    ifelse(sapply(strsplit(x$V5, ' '), length) == 4,
           sapply(strsplit(x$V5, ' '), function(x) x[[4]]),
           lapply(strsplit(x$V5, ' '), function(x) paste(x[4:5], collapse = ''))
    )
  infant.deaths.number <- unlist(infant.deaths.number)
  infant.deaths.rate <- x$V6
  
  df <- data.frame(country = countries,
                   live.births.year,live.births.code, 
                   live.births.number, live.births.rate, 
                   deaths.year, deaths.code, deaths.number,death.rate,
                   infant.deaths.year, infant.deaths.code, 
                   infant.deaths.number,infant.deaths.rate, 
                   footnotes,
                   stringsAsFactors = FALSE)
  return(df)
}

