# This is the R script to build the cohorts from the JSON created from Atlas. This is from a Capr fork
# "issue125-decompile" that allows for decompiling the JSON to R code.
# I just copied the file from the github repo, and then source them later.

library(SqlRender)
library(DatabaseConnector)
library(Capr)
library(jsonvalidate)
library(CirceR)
library(CohortGenerator)
# remotes::install_github("ohdsi/Capr", "issue125-decompile")

# create the database connection details
connDeets <- createConnectionDetails(
        dbms = "sqlite",
        server = "/Users/michaelconlin/synthea100k/synthea100k.sqlite"
)
connection <- connect(connDeets)
# test the connection
querySql(connection, "SELECT COUNT(*) FROM person;")

# get the table names in the database using the DatabaseConnector function
tableNames <- getTableNames(connection)
print(tableNames)


# build the cohorts
# load up the jsonToCapr function
source("/Users/michaelconlin/hades/jsonToCapr.R", echo = FALSE)

source("/Users/michaelconlin/hades/jsonToCapr_cohort_build.r", echo = TRUE)

# Now source the generated R scripts to build the cohorts
# ARBS cohort
source("/Users/michaelconlin/hades/cohort_build_arbs.r", echo = TRUE)
# create the json to generate the query for the ARBS cohort
arbsCohortJson <- as.json(cohortDef)
# generate the SQL query for the ARBS cohort, control, and outcome using CirceR
arbsCohortSql <- CirceR::buildCohortQuery(
        expression = cohortExpressionFromJson(arbsCohortJson),
        options = CirceR::createGenerateOptions(
                generateStats = FALSE
        )
)
# ARBS control cohort
source("/Users/michaelconlin/hades/cohort_build_arbs_control.r", echo = TRUE)
arbsControlCohortJson <- as.json(controlCohortDef)
arbsControlCohortSql <- CirceR::buildCohortQuery(
        expression = cohortExpressionFromJson(arbsControlCohortJson),
        options = CirceR::createGenerateOptions(
                generateStats = FALSE
        )
)
# ARBS outcome cohort
source("/Users/michaelconlin/hades/cohort_build_arbs_outcome.r", echo = TRUE)
arbsOutcomeCohortJson <- as.json(outcomeCohortDef)
arbsOutcomeCohortSql <- CirceR::buildCohortQuery(
        expression = cohortExpressionFromJson(arbsOutcomeCohortJson),
        options = CirceR::createGenerateOptions(
                generateStats = FALSE
        )
)
# create a tibble to hold the cohort information
cohortsToCreate <- tibble::tibble(
        cohortId = 0:2,
        cohortName = c("ARBS_control", "ARBS", "ARBS_outcome"),
        sql = c(arbsControlCohortSql, arbsCohortSql, arbsOutcomeCohortSql)
)
# get the cohort table names
cohortTableNames <- CohortGenerator::getCohortTableNames(
        cohortTable = "cohort"
)
CohortGenerator::createCohortTables(
        connectionDetails = connDeets,
        cohortDatabaseSchema = "main",
        cohortTableNames = cohortTableNames
)
# generate the cohort in the database
cohortsGenerated <- CohortGenerator::generateCohortSet(
        connectionDetails = connDeets,
        cdmDatabaseSchema = "main",
        cohortDatabaseSchema = "main",
        cohortTableNames = cohortTableNames,
        cohortDefinitionSet = cohortsToCreate
)

cohortCounts <- CohortGenerator::getCohortCounts(
        connectionDetails = connDeets,
        cohortDatabaseSchema = "main",
        cohortTableNames = cohortTableNames$cohortTable
)
