# Analysis Code
# TCO and negative controls are already in the cohort table

# be sure to set the env variables and database connection details first
source()

# Define the covariates (by eliminating the target and comparator concept_id s)
library(CohortMethod)

# Conncection, Schema, etc

# define the treatment and comparator concept_ids for elimination from covariates
arbs <- c(
  1308842,
  1317640,
  1346686,
  1347384,
  1351557,
  1367500,
  40226742,
  40235485
)

non_arbs <- c(21601783, 21601801, 21601744, 21601461, 21601665)

# Question - do I need to also eliminate the outcome (RCCA) and exclusion criteria from the
# covariates

covar_settings <- createDefaultCovariateSettings(
  excludedCovariateConceptIds = c(arbs, non_arbs),
  addDescendantsToExclude = TRUE
)

# Load the Data for analysis
#ToDo review this function below for consistancy with the schemas, tables, etc.

cmData <- getDbCohortMethodData(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  oracleTempSchema = NULL,
  targetId = 1,
  comparatorId = 2,
  outcomeIds = 3,
  studyStartDate = "",
  studyEndDate = "",
  exposureDatabaseSchema = cohortDbSchema,
  exposureTable = cohortTable,
  outcomeDatabaseSchema = cohortDbSchema,
  outcomeTable = cohortTable,
  cdmVersion = cdmVersion,
  firstExposureOnly = FALSE,
  removeDuplicateSubjects = FALSE,
  restrictToCommonPeriod = FALSE,
  washoutPeriod = 0,
  covariateSettings = covar_settings
)
# save the cohort data
saveCohortMethodData(cmData, "arb_study_data.zip")

# to load the data, use loadCohortMethodData() function

summary(cmData)

# Now create the study population
# review all these
studyPop <- createStudyPopulation(
  cohortMethodData = cmData,
  outcomeId = 3,
  firstExposureOnly = FALSE,
  restrictToCommonPeriod = FALSE,
  washoutPeriod = 0,
  removeDuplicateSubjects = "keep all", # or should this be FALSE
  removeSubjectsWithPriorOutcome = TRUE,
  minDaysAtRisk = 1,
  riskWindowStart = 1,
  startAnchor = "cohort start",
  riskWindowEnd = 0,
  endAnchor = "cohort end"
)

# Note that we’ve set firstExposureOnly and removeDuplicateSubjects to FALSE,
# and washoutPeriod to 0 because we already applied those criteria in the cohort definitions.
# We specify the outcome ID we will use, and that people with outcomes prior to the
# risk window start date will be removed. The risk window is defined as
# starting on the day after the cohort start date
# (riskWindowStart = 1 and startAnchor = "cohort start"),
# and the risk windows ends when the cohort exposure ends
# (riskWindowEnd = 0 and endAnchor = "cohort end"),
# which was defined as the end of exposure in the cohort definition.
# Note that the risk windows are automatically truncated at the end of
# observation or the study end date. We also remove subjects who have
# no time at risk. To see how many people are left in the study population
# we can always use the getAttritionTable function:

getAttritionTable(studyPop)

# Now create the propensity scores
#ToDo - figure out the best setting for creating the propensity scores, type, optimization, etc

ps <- createPs(cohortMethodData = cmData, population = studyPop)
