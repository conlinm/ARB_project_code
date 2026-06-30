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
outcomeCohortDef <- cohort(
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
outcomeCohortDef <- cohort(
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
outcomeCohortDef <- cohort(
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
outcomeCohortDef <- cohort(
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
outcomeCohortDef <- cohort(
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
outcomeCohortDef <- cohort(
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
outcomeCohortDef <- cohort(
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
outcomeCohortDef <- cohort(
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
outcomeCohortDef <- cohort(
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
outcomeCohortDef <- cohort(
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
