# This is analysis code derived from the study package, which was created using Atlas.
# I have already created my TCO cohorts at the VA, and the first step is to add the negative
# controls.

# be sure to set the env variables and database connection details first
# requires the file "NegativeControlOutcomes.sql" and "negativeControls.csv"
#

library(DatabaseConnector)
library(SqlRender)

connection <- DatabaseConnector::connect(connectionDetails)

#### Add negative controls to the cohort table ####
# paths to the sql and csv files
sql_path <- "NegativeControlOutcomes.sql"
negativeControls <- read.csv("NegativeControls.csv")

# load the sql and render it with the appropriate parameters
sql <- SqlRender::readSql(sql_path)
sql <- SqlRender::render(
  sql,
  cdm_database_schema = cdmDatabaseSchema,
  target_database_schema = cohortDatabaseSchema,
  target_cohort_table = cohortTable,
  outcome_ids = unique(negativeControls$outcomeId)
)
sql <- SqlRender::translate(sql, targetDialect = connectionDetails$dbms)

# execute the sql to insert the negative controls into the cohort table
DatabaseConnector::executeSql(connection, sql)
DatabaseConnector::disconnect(connection)
