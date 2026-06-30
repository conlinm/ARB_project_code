# This script creates the negative control cohorts for the ARB study.
# this one creates the cohorts using the template approach

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
      conditionOccurrence(nc_cs, firstOccurrence()),
      primaryCriteriaLimit = "First",
      qualifiedLimit = "First"
    ),
    exit = exit(endStrategy = observationExit()),
    era = era(eraDays = 30L)
  )
})

# Assemble into a CohortGenerator cohort definition set
nc_cohort_def_set <- tibble(
  cohortId   = negativeControls$outcomeId,
  cohortName = negativeControls$outcomeName,
  json       = sapply(nc_cohort_defs, Capr::toJson)