# Clean workspace
# rm(list = ls())

# Install packages if needed   --------------------------------------------

message('Checking for necessary packages...')

# Create vector with named packages 
pkgs <- c('httr', 'rvest', 'readxl', 'dplyr', 'rJava', 'tabulizer', 'openxlsx')

# Loop over 'pkgs' to install each package in the vector
for(i in 1:length(pkgs)){ 
  if(!pkgs[i] %in% installed.packages()) {
    message('Installing package ', pkgs[i])
    install.packages(pkgs[i])
  }
}
message('Done. All necessary packages are installed.')

# Remove objeckts from workspace
rm(pkgs, i)







