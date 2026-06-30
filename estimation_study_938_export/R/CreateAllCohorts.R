library(Capr)
library(CohortGenerator)
library(DatabaseConnector)
library(tibble)

negativeControls <- read.csv("NegativeControls.csv")

# Build a Capr cohort definition for each negative control:
# entry = first occurrence of the condition concept (+ descendants),
# exit  = end of observation period
nc_cohort_defs <- lapply(seq_len(nrow(negativeControls)), function(i) {
  nc_cs <- cs(
    descendants(negativeControls$outcomeId[i]),
    name = negativeControls$outcomeName[i]
  )
  cohort(
    entry = entry(
      condition(nc_cs),
      primaryCriteriaLimit = "First"
    ),
    exit = exit(endStrategy = observationExit())
  )
})

# Assemble into a CohortGenerator cohort definition set
nc_cohort_def_set <- tibble(
  cohortId = negativeControls$outcomeId,
  cohortName = negativeControls$outcomeName,
  json = sapply(nc_cohort_defs, Capr::toJson)
)

# Insert negative controls into your existing cohort table
# (generateCohortSet appends; it does not drop/recreate the table)
connection <- DatabaseConnector::connect(connectionDetails)

CohortGenerator::generateCohortSet(
  connection = connection,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable),
  cohortDefinitionSet = nc_cohort_def_set
)

DatabaseConnector::disconnect(connection) # Copyright 2022 Observational Health Data Sciences and Informatics
#
# This file is part of ARB
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

createCohorts <- function(
  connectionDetails,
  cdmDatabaseSchema,
  cohortDatabaseSchema,
  cohortTableNames,
  tempEmulationSchema,
  outputFolder
) {
  if (!file.exists(outputFolder)) {
    dir.create(outputFolder)
  }

  connection <- DatabaseConnector::connect(connectionDetails)
  on.exit(DatabaseConnector::disconnect(connection))

  CohortGenerator::createCohortTables(
    connection = connection,
    cohortDatabaseSchema = cohortDatabaseSchema,
    cohortTableNames = cohortTableNames
  )
  cohortDefinitionSet <- CohortGenerator::getCohortDefinitionSet(
    packageName = "ARB",
    settingsFileName = "Cohorts.csv",
    cohortFileNameValue = "cohortId"
  )
  CohortGenerator::generateCohortSet(
    connection = connection,
    cohortDatabaseSchema = cohortDatabaseSchema,
    cohortTableNames = cohortTableNames,
    cdmDatabaseSchema = cdmDatabaseSchema,
    tempEmulationSchema = tempEmulationSchema,
    cohortDefinitionSet = cohortDefinitionSet
  )

  message("Creating negative control outcome cohorts")
  pathToCsv <- system.file("settings", "NegativeControls.csv", package = "ARB")
  negativeControls <- read.csv(pathToCsv)
  # Currently assuming all negative controls are outcome controls
  negativeControlOutcomes <- negativeControls
  sql <- SqlRender::loadRenderTranslateSql(
    "NegativeControlOutcomes.sql",
    "ARB",
    dbms = connectionDetails$dbms,
    tempEmulationSchema = tempEmulationSchema,
    cdm_database_schema = cdmDatabaseSchema,
    target_database_schema = cohortDatabaseSchema,
    target_cohort_table = cohortTableNames$cohortTable,
    outcome_ids = unique(negativeControlOutcomes$outcomeId)
  )
  DatabaseConnector::executeSql(connection, sql)

  # Check number of subjects per cohort:
  message("Counting cohorts")
  counts <- CohortGenerator::getCohortCounts(
    connection = connection,
    cohortDatabaseSchema = cohortDatabaseSchema,
    cohortTable = cohortTableNames$cohortTable
  )

  counts <- addCohortNames(counts)
  write.csv(
    counts,
    file.path(outputFolder, "CohortCounts.csv"),
    row.names = FALSE
  )
}

addCohortNames <- function(
  data,
  IdColumnName = "cohortId",
  nameColumnName = "cohortName"
) {
  pathToCsv <- system.file("Cohorts.csv", package = "ARB")
  cohortsToCreate <- read.csv(pathToCsv)
  pathToCsv <- system.file("settings", "NegativeControls.csv", package = "ARB")
  negativeControls <- read.csv(pathToCsv)

  idToName <- data.frame(
    cohortId = c(cohortsToCreate$cohortId, negativeControls$outcomeId),
    cohortName = c(
      as.character(cohortsToCreate$cohortName),
      as.character(negativeControls$outcomeName)
    )
  )
  idToName <- idToName[order(idToName$cohortId), ]
  idToName <- idToName[!duplicated(idToName$cohortId), ]
  names(idToName)[1] <- IdColumnName
  names(idToName)[2] <- nameColumnName
  data <- merge(data, idToName, all.x = TRUE)
  # Change order of columns:
  idCol <- which(colnames(data) == IdColumnName)
  if (idCol < ncol(data) - 1) {
    data <- data[, c(1:idCol, ncol(data), (idCol + 1):(ncol(data) - 1))]
  }
  return(data)
}
