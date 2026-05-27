# setup Eunomia, a dataset manager with demo OMOP data
# see https://github.com/OHDSI/Eunomia
library(Eunomia)
library(SqlRender)
library(DatabaseConnector)
connectionDetails <- getEunomiaConnectionDetails()
connection <- connect(connectionDetails)
querySql(connection, "SELECT COUNT(*) FROM person;")
#  COUNT(*)
#1     2694

getTableNames(connection,databaseSchema = 'main')
disconnect(connection)

# Download the Eunomia datasets (here the Synthea27Nj_5.4)
downloadEunomiaData(datasetName = "Synthea27Nj", cdmVersion = "5.4", pathToData = "./eunomia_data")

# Extract the data into a sqlite database
  # first make a folder
main_dir <- getwd()
sub_dir <- "synthea_db"
dir.create(file.path(main_dir, sub_dir), showWarnings = FALSE)
  # now extract
extractLoadData(from = "./eunomia_data/Synthea27Nj_5.4.zip", to = "/Users/michaelconlin/hades/synthea_db/synthea.db", cdmVersion = "5.4", verbose = TRUE)
  # note that you must provide a file name, in this case "synthea.db" even though that 
  # sqlite file does not yet exist
# connect to new database
connDeets <- createConnectionDetails(dbms = "sqlite", server = "/Users/michaelconlin/synthea100k/synthea100k.sqlite")
connection <- connect(connDeets)
querySql(connection, "SELECT COUNT(*) FROM person;")

library(CDMConnector)
exampleDatasets()
