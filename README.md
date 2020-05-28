# WDI-Production
The World Development Indicators is a compilation of relevant, high-quality, and internationally comparable statistics about global development and the fight against poverty. The database contains 1,600 time series indicators for 217 economies and more than 40 country groups, with data for many indicators going back more than 50 years.

# Goals

This repo is a common resource for those working on the WDI to promote automation and consolidate key information into one place.  It is also a place to do experimental data collection or aggregations, such as by quintiles or subnational areas.

# Rules

A few rules for this repository.

1. Data ingestion, validation, and production: Data from different sources in different formats will be converted into a unified format: CSV.  CSV files are readable by nearly any software and trackable in Git.  All data that is produced in this repo, particularly final datasets should have at least a copy in CSV.  There can be other data formats as well used, but please keep a copy of the data in csv.
2. Master, Develop, and other branches: There will be two permanent branches in this repository: Master and Develop.  The Master branch will be relatively stable with only infrequent changes.  The Develop branch will contain less mature code and will be updated more frequently.  Any new work (for instance a new project looking at subnational data) should take place in a seperate branch from Develop.  Once that work is completed, this new branch can be merged into Develop, so that the Develop branch will always be updated when a task is completed.  At infrequent intervals (say every 3-6 months or when work slows down) the Develop branch will then be merged into Master.

# Organization

There are two folders in the root of the repository: Resources and Projects.  The difference between these two folders is as follows.  The Projects folder contains code and data for projects that will feed into the WDI.  The final outputs for these projects should be indicators or metadata for the WDI indicators.  For instance, a project to add subnational data to the WDI would be included here.  So would a code and data related to the metadata fields for countries.  

In contrast, the Resources folder contains common goods that could be useful for work related to the WDI, but will not directly feed into it.  For instance, the folder contains code to scrape the contents of the World Bank and IHSN microdata libraries and datalibweb.  These items will likely never be published in the WDI.  They are mostly tips or tricks that may be useful for the WDI team.  

## Organization for subfolders

The organization specified below is not necessarily mandatory.  Individuals have their own styles.  However, some form of the following (perhaps with name differences or slight changes ot the organization) is mandatory.  Having a common set of organizational practices will make it easier for others to understand the organization of your project.  Every project should have four components:

1. 01_rawdata folder
2. 02_programs folder
3. 03_outputs folder  
4. README.md

01_rawdata contains any input files that are needed for the work.  For instance, this may include a csv file containing data that a World Bank colleague shared with you for this project.

02_programs contains all code used to produce the final output.  If multiple scripts are included, please include some sort of documentation on how to run the files in the README.md.

03_outputs contains the final data produced for the project.  Again, this should be in csv form or have at least a copy of the data in csv format.

README.md should contain a brief description of what the project is, how to run the code, and what the final output is.  This doesn't need to be long, but should provide some information.
