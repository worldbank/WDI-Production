# ------------------------ VITAL REGISTRATION -----------------------------


# Start up ----------------------------------------------------------------

message('Collecting vital registrations (births, deaths and infant deaths) ',
        'for all countries from The UN\'s Population and Vital Statistics Report.',
        appendLF = TRUE)

# JAVA settings 
message(
  'Note: This script use the package \'tabulizer\' which depends on Java. ',
  'Make sure you have either Oracle JDK (https://www.oracle.com/java/technologies/javase-downloads.html) ',
  'or Open JDK (https://openjdk.java.net/) installed.\n')

# Set JAVA_HOME if it doesn't exist
message('Checking environmental variables for \'JAVA_HOME\'...')
 if(Sys.getenv('JAVA_HOME') == ''){
   message('No \'JAVA_HOME\' variable found.')
   message('Setting JAVA_HOME to ', Sys.getenv('JDK_PATH'))
   Sys.setenv(JAVA_HOME = Sys.getenv('JDK_PATH'))
   message('Added ', Sys.getenv('JDK_PATH'), ' to the PATH')
   Sys.setenv(PATH = sprintf('%s%s;', Sys.getenv('PATH'), Sys.getenv('JDK_PATH')))
 }
message('Done. Environmental variables have been set.')

# Load packages if needed 
if(!'tabulizer' %in% .packages()) library(tabulizer) 
if(!'magrittr' %in% .packages()) library(magrittr) 

# Load custom functions 
source('r-scripts/_common.R')

# Load dataset with ISO codes
iso <- load_iso()

# Extract the table -------------------------------------------------------

# Create a string with the URL
the_url <- 'https://unstats.un.org/unsd/demographic-social/products/vitstats/seratab3.pdf'
message('Extracting table from ', the_url)

# Extract the table (page 1 - 6)
the_tables <- extract_tables(the_url, pages = 1:6, encoding = 'UTF-8') 
                             #area = list(c(106, 43, 716, 590)))
# Convert to data frame 
dl <- lapply(the_tables, extract_df)
df <- do.call( 'rbind', dl)


# Data tranformations -----------------------------------------------------

# Replace '...' with NA 
df <- data.frame(df[1], 
                apply(df[2:ncol(df)], 2, function(x) 
                  gsub('[.]{3}', NA, x)
                  ), 
                stringsAsFactors = FALSE)


# Add variable for complete registration (Yes/NA)
df$complete <- with(df, ifelse(grepl('C', live.births.code) 
                               & grepl('C', deaths.code), 'Yes', ''))
# df$complete <- ifelse(apply(df, 1, function(x) any(is.na(x))),
#                       NA, 'Yes')

# Finalize the data frame -------------------------------------------------

# Add column with ISO codes
df <- merge(df, iso, by.x = 'country', 
                   by.y = 'Country_name', 
            all.x = TRUE)

# Rename columns 
names(df) <- firstup(gsub('[.]', ' ', names(df)))

# Rearrange columns 
df <- df[c(16, 1:15)]

# Assign to 'un_vitstats' object
un_vitstats <- df

# Clean workspace
rm(the_tables, dl, the_url, extract_df) 
rm(df, iso)

message('Done! UN Vital registration table collected. ',
        'It has been assigned to the object \'un_vitstats\' in your workspace.', 
        appendLF = TRUE)
