# Analysis Code
# TCO and negative controls are already in the cohort table

# ---------------------------------------------------------------------------
# EXPLICIT COVARIATES VERSION (fallback, try this if optimized.R still fails)
# Based on create_cohort_method_data_optimized.R. That script started from
# createDefaultCovariateSettings() (a broad default set) and then disabled
# specific flags after the fact. This version instead calls
# createCovariateSettings() directly, which defaults EVERY covariate flag to
# FALSE, so only the domains explicitly turned on below are ever built. If
# create_cohort_method_data_optimized.R still gets terminated by VINCI DBA,
# try this version next - it builds a smaller, fully-enumerated covariate
# set, so it's both cheaper and easier to trim further by eye if needed.
#
# Domain choices below were confirmed with the study lead on 2026-08-18:
# core PS covariates only (Demographics, Condition, Drug, plain Measurement),
# long-term (365-day) window only. Procedure Occurrence, Device Exposure,
# Observation, and comorbidity index scores (Charlson/DCSI/CHADS2) are
# intentionally NOT included in this version - see the comment above
# covar_settings below.
#
# All other changes carried over unchanged from create_cohort_method_data_optimized.R
# (OPTIMIZATION 3: firstExposureOnly/removeDuplicateSubjects) are marked as before.
# ---------------------------------------------------------------------------

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

# NOTE: addDescendantsToExclude = TRUE expands this concept list via
# concept_ancestor before it's used in the covariate SQL's exclusion filter
# (see corhotMethodGenerated.sql, "NOT IN (SELECT id FROM #id_set_1)"). If
# the resulting exclusion set is large, ask VINCI DBA to confirm that
# temp table is indexed - an unindexed NOT IN against a large set can force
# a nested-loop anti-join across the full measurement/condition/drug tables
# instead of a cheap hash lookup, adding to the TempDB pressure seen in
# queryErrorEmail.txt.

# EXPLICIT COVARIATES: createCovariateSettings() defaults every "use*" flag
# to FALSE. Only the domains listed as TRUE below will ever be built -
# nothing is computed and then discarded. Compare to
# create_cohort_method_data_optimized.R, which builds from the full default
# set and disables flags afterward.
#
# Included (core PS covariate set, long-term/365-day window only):
#   - Demographics: gender, age group, race, ethnicity
#   - Condition Occurrence + Condition Era
#   - Drug Exposure + Drug Era (excluding ARBs/non-ARBs via excludedCovariateConceptIds)
#   - Measurement, plain presence/value (NOT MeasurementRangeGroup - that's
#     the analysis that was killed, see corhotMethodGenerated.sql)
#
# Deliberately excluded (not needed for a standard PS model per study lead,
# and each one is another full table join/cost to avoid while stabilizing
# the query): Procedure Occurrence, Device Exposure, Observation,
# comorbidity index scores (Charlson/DCSI/CHADS2). Add back in individually
# (as additional useXyzLongTerm = TRUE lines) if the PS model needs them and
# TempDB usage allows it.
covar_settings <- createCovariateSettings(
  useDemographicsGender = TRUE,
  useDemographicsAgeGroup = TRUE,
  useDemographicsRace = TRUE,
  useDemographicsEthnicity = TRUE,

  useConditionOccurrenceLongTerm = TRUE,
  useConditionEraLongTerm = TRUE,

  useDrugExposureLongTerm = TRUE,
  useDrugEraLongTerm = TRUE,

  useMeasurementLongTerm = TRUE,
  useMeasurementValueLongTerm = TRUE,

  longTermStartDays = -365,
  endDays = 0,

  excludedCovariateConceptIds = c(arbs, non_arbs),
  addDescendantsToExclude = TRUE
)

# Load the Data for analysis
#ToDo review this function below for consistancy with the schemas, tables, etc.

# OPTIMIZATION 3 (carried over from create_cohort_method_data_optimized.R):
# firstExposureOnly = TRUE and removeDuplicateSubjects = "keep first"
# (changed from the original script's FALSE/FALSE). If a subject can have
# more than one row in the cohort table (multiple exposure episodes), each
# row gets its own covariate lookup window, multiplying join cost. This is
# a safety net in case the "already deduplicated" cohort table assumption
# (see comment at top of file) doesn't hold for every subject. This must
# stay consistent with the same settings used in createStudyPopulation()
# below.
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
  firstExposureOnly = TRUE,
  removeDuplicateSubjects = "keep first",
  restrictToCommonPeriod = FALSE,
  washoutPeriod = 0,
  covariateSettings = covar_settings
)

# RECOMMENDATION: before running this against the full cohort, consider a
# small pilot (e.g., a subject subsample) to sanity-check runtime/TempDB
# usage against this database, given the prior termination. Check the
# estimated query plan as VINCI DBA suggested in queryErrorEmail.txt before
# rerunning at full scale.

# save the cohort data
saveCohortMethodData(cmData, "arb_study_data.zip")

# to load the data, use loadCohortMethodData() function

summary(cmData)

# Now create the study population
# review all these
# OPTIMIZATION 3 (cont'd): firstExposureOnly and removeDuplicateSubjects here
# are kept consistent with the values used in getDbCohortMethodData() above
# (TRUE / "keep first"). This also resolves the "or should this be FALSE"
# question that was previously here - "keep all" (which allowed multiple
# rows per subject) was the mismatch driving up covariate cost upstream.
studyPop <- createStudyPopulation(
  cohortMethodData = cmData,
  outcomeId = 3,
  firstExposureOnly = TRUE,
  restrictToCommonPeriod = FALSE,
  washoutPeriod = 0,
  removeDuplicateSubjects = "keep first",
  removeSubjectsWithPriorOutcome = TRUE,
  minDaysAtRisk = 1,
  riskWindowStart = 1,
  startAnchor = "cohort start",
  riskWindowEnd = 0,
  endAnchor = "cohort end"
)

# Note that we've set firstExposureOnly and removeDuplicateSubjects to TRUE /
# "keep first" (see OPTIMIZATION 3 above) rather than FALSE, because we can no
# longer assume the cohort definitions alone guarantee one row per subject -
# doing so protects against the TempDB blowup described in queryErrorEmail.txt.
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
