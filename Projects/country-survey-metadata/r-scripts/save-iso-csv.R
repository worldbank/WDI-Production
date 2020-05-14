rm(list =ls())

iso <- readxl::read_xlsx('data/input/ISO3.xlsx')
iso <- as.data.frame(iso)
iso <- iso[!duplicated(iso),]

write.csv(iso, 'data/input/iso3.csv', fileEncoding = 'UTF-8', row.names = FALSE)

