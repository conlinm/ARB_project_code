# This script creates the negative control cohorts for the ARB study.
# This one creates each one by hand rather than using the the template version
# It uses the Capr package to define concept sets and cohorts.

library(Capr)

# --- concept sets ---
# Mania concept set
csMania <- cs(descendants(4333677), name = "Mania")

# Tooth Loss concept set
csToothLoss <- cs(4332446, name = "Tooth Loss")

# Frostbite concept set
csFrostbite <- cs(441487, name = "Frostbite")

# Fear of Flying concept set
csFearOfFlying <- cs(4085062, name = "Fear of Flying")

# Vesicoureteric Reflux concept set
csVesicouretericReflux <- cs(197036, name = "Vesicoureteric Reflux")

# Marfan's Syndrome concept set
csMarfans <- cs(258540, name = "Marfan's Syndrome")

# Post Viral Fatigue Syndrome concept set
csPostViralFatigueSyndrome <- cs(4202045, name = "Post Viral Fatigue Syndrome")

# Hiccoughs concept set
csHiccoughs <- cs(194475, name = "Hiccoughs")

# Homocystinuria concept set
csHomocystinuria <- cs(4012934, name = "Homocystinuria")

# Conjunctival Hyperemia concept set
csConjunctivalHyperemia <- cs(377283, name = "Conjunctival Hyperemia")

# Cohort definitions
# --- mania cohort ---
maniaCohortDef <- cohort(
  entry = entry(
    conditionOccurrence(csMania, firstOccurrence()),
    observationWindow = continuousObservation(priorDays = 0L, postDays = 0L),
    primaryCriteriaLimit = "First",
    qualifiedLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  ),
  era = era(eraDays = 30L)
)

# --- tooth loss cohort ---
toothLossCohortDef <- cohort(
  entry = entry(
    conditionOccurrence(csToothLoss, firstOccurrence()),
    observationWindow = continuousObservation(priorDays = 0L, postDays = 0L),
    primaryCriteriaLimit = "First",
    qualifiedLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  ),
  era = era(eraDays = 30L)
)

# --- frostbite cohort ---
frostbiteCohortDef <- cohort(
  entry = entry(
    conditionOccurrence(csFrostbite, firstOccurrence()),
    observationWindow = continuousObservation(priorDays = 0L, postDays = 0L),
    primaryCriteriaLimit = "First",
    qualifiedLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  ),
  era = era(eraDays = 30L)
)

# --- fear of flying cohort ---
fearOfFlyingCohortDef <- cohort(
  entry = entry(
    conditionOccurrence(csFearOfFlying, firstOccurrence()),
    observationWindow = continuousObservation(priorDays = 0L, postDays = 0L),
    primaryCriteriaLimit = "First",
    qualifiedLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  ),
  era = era(eraDays = 30L)
)

# --- vesicoureteric reflux cohort ---
vesicoureteralRefluxCohortDef <- cohort(
  entry = entry(
    conditionOccurrence(csVesicouretericReflux, firstOccurrence()),
    observationWindow = continuousObservation(priorDays = 0L, postDays = 0L),
    primaryCriteriaLimit = "First",
    qualifiedLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  ),
  era = era(eraDays = 30L)
)

# --- marfan's syndrome cohort ---
marfansCohortDef <- cohort(
  entry = entry(
    conditionOccurrence(csMarfans, firstOccurrence()),
    observationWindow = continuousObservation(priorDays = 0L, postDays = 0L),
    primaryCriteriaLimit = "First",
    qualifiedLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  ),
  era = era(eraDays = 30L)
)

# --- post viral fatigue syndrome cohort ---
postViralFatigueSyndromeCohortDef <- cohort(
  entry = entry(
    conditionOccurrence(csPostViralFatigueSyndrome, firstOccurrence()),
    observationWindow = continuousObservation(priorDays = 0L, postDays = 0L),
    primaryCriteriaLimit = "First",
    qualifiedLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  ),
  era = era(eraDays = 30L)
)

# --- hiccoughs cohort ---
hiccoughsCohortDef <- cohort(
  entry = entry(
    conditionOccurrence(csHiccoughs, firstOccurrence()),
    observationWindow = continuousObservation(priorDays = 0L, postDays = 0L),
    primaryCriteriaLimit = "First",
    qualifiedLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  ),
  era = era(eraDays = 30L)
)

# --- homocystinuria cohort ---
homocystinuriaCohortDef <- cohort(
  entry = entry(
    conditionOccurrence(csHomocystinuria, firstOccurrence()),
    observationWindow = continuousObservation(priorDays = 0L, postDays = 0L),
    primaryCriteriaLimit = "First",
    qualifiedLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  ),
  era = era(eraDays = 30L)
)

# --- conjunctival hyperemia cohort ---
conjunctivalHyperemiaCohortDef <- cohort(
  entry = entry(
    conditionOccurrence(csConjunctivalHyperemia, firstOccurrence()),
    observationWindow = continuousObservation(priorDays = 0L, postDays = 0L),
    primaryCriteriaLimit = "First",
    qualifiedLimit = "First"
  ),
  exit = exit(
    endStrategy = observationExit()
  ),
  era = era(eraDays = 30L)
)
### makeCohortSet function ###
# Now create the cohort set dataframe (a tibble) containing cohortid, name, sql, and json
# this tibble will be piped into the CohortGenerator function to create the actual cohorts
# in our database

### note, there is nowhere you can declare the cohort ids ahead of this step, and makeCohortSet
# assigns these automatically starting at 1. You can create the tibble by hand. See using-capr.pdf

negControlCohortsToCreate <- do.call(
  makeCohortSet,
  c(
    maniaCohortDef,
    toothLossCohortDef,
    frostbiteCohortDef,
    fearOfFlyingCohortDef,
    vesicoureteralRefluxCohortDef,
    marfansCohortDef,
    postViralFatigueSyndromeCohortDef,
    hiccoughsCohortDef,
    homocystinuriaCohortDef,
    conjunctivalHyperemiaCohortDef
  )
) |>
  VaTools::refactor()


### Now correct the cohortIds to account for prior 3 TCO cohorts already created ###
negControlCohortsToCreate$cohortId <- seq(
  4,
  length.out = nrow(negControlCohortsToCreate)
)

# get the cohort table names
ccohortTableNames <- CohortGenerator::getCohortTableNames(
  cohortTable = "cohort"
)
### create the cohort tables in the database ###
# First create the empty cohort tables in the database
CohortGenerator::createCohortTables(
  connectionDetails = connectionDetails,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTableNames = cohortTableNames
)
# generate the cohort and populate the tables in the database
cohortsGenerated <- CohortGenerator::generateCohortSet(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTableNames = cohortTableNames,
  cohortDefinitionSet = negControlCohortsToCreate
)

cohortCounts <- CohortGenerator::getCohortCounts(
  connectionDetails = connectionDetails,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTable = cohortTableNames$cohortTable
) |>
  inner_join(
    cohortsToCreate |> select(cohortId, cohortName),
    by = "cohortId"
  ) |>
  arrange(cohortId)
