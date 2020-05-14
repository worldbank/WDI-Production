# country-survey-metadata
Automated collection of metadata for household surveys (DHS, RHS, LSMS, MICS, WHS), censuses (UNSD) and vital registration statistics (UNSD).  


### Dependencies 

**R packages:**

To install the necessary R packages for the project run the script `'_setup.R`. Note that this only needs to be done once. 

```r
source('r-srcipts/_setup.R') 
```

**Oracle JDK / Open JDK:** 

One of the R packages used for this project, `tabulizer`, depends on Java. This means you either have to install [Oracle JDK](https://www.oracle.com/java/technologies/javase-downloads.html) or [Open JDK](https://openjdk.java.net/) on your system. On Windows you should also add the installation path to your System PATH environmental variable (if you are using OpenJDK the path you are adding should be similar to the following; `C:\<my-path>\jdk-<version>\bin\server`).  

**Manual downloads:** 

In order for the script `collect-mics.R` to run the survey data table needs to be manually downloaded from the [UNICEF MICS Surveys website](http://mics.unicef.org/surveys). Download the table using the Export button to the upper right and place the file in the `data/input` folder. The file should be named `surveys_catalogue.csv`. 


### Usage 

**Create a combined survey metadata table:**

To create a combined table with the latest survey and census, as well as the vital registration statistics, for each country you can run the script `create-survey-info-table.R`. The script collects all of the different tables, combines them together and then writes the output to an Excel file named `output-country-info-<yyyy>-<mm>-<dd>.xlsx`. The file is saved in the folder `data/output`. 

```r
source('r-scripts/create-survey-info-table.R') 
```

**Collect all tables:** 

To collect all tables at once you can run the script `create-all-tables.R`. This scripts collects all the tables and then writes each table to its own sheet in an Excel file named `output-all-tables-<yyyy>-<mm>-<dd>.xlsx`. The file is saved in the folder `data/output`. 

```r
source('r-scripts/create-all-tables.R') 
```

**Collect individual tables:**

Each table has its own script that can be run separately. 

Household surveys: 

- DHS: `collect-dhs.R`   
- RHS: `collect-rhs.R`
- WHS: `collect-Whs.R`
- LSMS: `collect-lsms.R`
- MICS: `collect-mics.R`

UN Stats: 

- Vital Statistics: `collect-unstat-vitstats.R`
- Census Dates:  `collect-unstat-census.R`



