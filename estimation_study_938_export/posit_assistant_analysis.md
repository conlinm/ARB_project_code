# OHDSI ARB/RCCa study: negative controls and cohort ID mapping guidance



## Summary of Findings

Based on my comprehensive exploration of the ARB (ARBs Study Cohort) project codebase, here are my detailed findings:

### **Project Overview**

**ARB** is an R package designed to conduct a **comparative effectiveness study** using the OHDSI framework (Observational Health Data Sciences and Informatics). It's specifically structured as a skeleton package for comparative effectiveness research, following the OHDSI standards for distributed research networks.

---

### **Core Purpose**

The ARB package implements a complete pipeline for:
1. **Cohort Creation** - Define and instantiate patient cohorts from OMOP CDM (Common Data Model) databases
2. **Comparative Analysis** - Compare treatment effectiveness (exposures) on health outcomes
3. **Propensity Score Matching** - Use the CohortMethod package for causal analysis
4. **Negative & Positive Controls** - Validate analysis methods using negative controls and optionally synthesize positive controls
5. **Results Export & Sharing** - Package and export results in a standardized format for multi-site studies
6. **Evidence Exploration** - Interactive Shiny app to explore results across multiple databases

---

### **Project Structure**

```
estimation_study_938_export/
├── R/                           # Core R functions
│   ├── Main.R                   # Main execute() orchestration function
│   ├── CreateAllCohorts.R       # Cohort generation logic
│   ├── CohortMethod.R           # Propensity score & outcome analysis
│   ├── SynthesizePositiveControls.R  # Synthetic control generation
│   ├── Export.R                 # Results packaging & export (52.5KB - largest file)
│   ├── MetaAnalysis.R           # Multi-site meta-analysis
│   ├── ShinyApps.R              # Evidence Explorer Shiny interface
│   ├── SubmitResults.R          # SFTP upload functionality
│   ├── VerifyDependencies.R     # Package validation
│   └── Package.R                # Package metadata
│
├── inst/                        # Package data & configuration
│   ├── cohorts/                 # Cohort definitions (JSON format)
│   │   ├── 1794964.json         # ARBs Study Cohort
│   │   ├── 1797490.json         # ARB Control Cohort
│   │   └── 1795536.json         # RCCa Outcome Cohort
│   ├── settings/                # Analysis configuration
│   │   ├── TcosOfInterest.csv   # Target-Comparator-Outcomes (1MB+)
│   │   ├── NegativeControls.csv # Negative control outcomes
│   │   ├── cmAnalysisList.json  # CohortMethod analysis specs (2.1MB)
│   │   └── StudySpecification.json  # Complete study spec (5.1MB)
│   ├── sql/sql_server/          # SQL cohort definitions
│   ├── shiny/EvidenceExplorer/  # Interactive visualization app
│   └── Cohorts.csv              # Metadata for 3 cohorts
│
├── man/                         # Documentation files
├── documents/                   # Study protocol & documentation
├── extras/                      # Helper scripts
│   ├── CodeToRun.R              # Example execution code
│   └── PackageMaintenance.R     # Build & maintenance scripts
│
└── Config Files:
    ├── DESCRIPTION              # Package metadata (v0.0.1)
    ├── NAMESPACE                # Exported functions
    ├── HydraConfig.json         # Hydra skeleton configuration
    ├── renv.lock                # Dependency pinning
    └── README.md                # Installation & execution guide
```

---

### **Key Functionality**

#### **1. Orchestration (Main.R - execute() function)**
The main `execute()` function coordinates the entire study pipeline with these steps:
- **Verify Dependencies** - Checks package versions match renv.lock
- **Create Cohorts** - Instantiates patient cohorts in CDM database
- **Synthesize Positive Controls** (optional) - Injects synthetic effects for validation
- **Run Analyses** - Executes propensity score analyses via CohortMethod
- **Package Results** - Exports results in standardized format for sharing

#### **2. Cohort Management (CreateAllCohorts.R)**
- Uses `CohortGenerator` package to create cohorts from JSON definitions
- Creates inclusion rule statistics tables
- Generates negative control outcome cohorts
- Produces cohort count summaries (CohortCounts.csv)

#### **3. Comparative Analysis (CohortMethod.R)**
- Defines **Target-Comparator-Outcome (TCO)** pairs:
  - **Target**: ARBs Study Cohort (1794964)
  - **Comparator**: ARB Control Cohort (1797490)
  - **Outcomes**: RCCa Outcome Cohort (1795536) + 10 negative controls
- Runs propensity score matching/stratification
- Fits outcome models
- Computes covariate balance metrics

#### **4. Results Export (Export.R - 52.5KB)**
Generates multiple CSV exports:
- `cohort_method_analysis.csv` - Analysis specifications
- `covariate_analysis.csv` - Covariate definitions
- `exposure_of_interest.csv` - Target & comparator definitions
- `outcome_of_interest.csv` - Outcome definitions
- `negative_control_outcome.csv` - Negative controls for validation
- `positive_control_outcome.csv` - Synthetic controls (if generated)
- `database.csv` - Database metadata (vocabulary version, observation periods)
- `exposure_summary.csv` - Exposure statistics
- `outcome_summary.csv` - Outcome statistics
- `covariate_balance.csv` - Pre/post-matching balance metrics
- Main results: effect estimates, confidence intervals, p-values
- Diagnostics: propensity score distributions, Kaplan-Meier curves

#### **5. Meta-Analysis (MetaAnalysis.R)**
- Combines results from multiple databases
- Supports two methods:
  - **DerSimonian-Laird** (traditional random-effects meta-analysis)
  - **Bayesian Non-Normal** (Schuemie et al. 2021 - robust to sparse data)
- Requires ≥2 result sets for synthesis

#### **6. Evidence Explorer (ShinyApps.R)**
- Interactive Shiny application for visualizing results
- Supports blinding/unblinding of results
- Allows splitting of large result sets by target-comparator pair
- Can aggregate results from multiple databases

---

### **Study Configuration**

**Study Cohorts (3 total):**
1. **1794964** - "ARBs Study Cohort" (Target/Exposure)
   - ARB drugs (valsartan, telmisartan, etc.)
   - Complex inclusion/exclusion criteria
2. **1797490** - "ARB_control_cohort" (Comparator)
3. **1795536** - "RCCa Outcome Cohort" (Primary Outcome)

**Study Design:**
- **Negative Controls**: 10 implausible outcomes (mania, tooth loss, frostbite, etc.) for validation
- **Analysis Configurations**: Multiple propensity score & outcome model specifications
- **Covariates**: 700+ covariate concept IDs included, 30+ excluded

---

### **Dependencies & Technology Stack**

**Key OHDSI Packages:**
- `DatabaseConnector` - Database connectivity
- `CohortGenerator` - Cohort instantiation
- `CohortMethod` - Comparative effectiveness analysis
- `FeatureExtraction` - Covariate extraction
- `EmpiricalCalibration` - Statistical calibration
- `MethodEvaluation` - Positive control synthesis
- `OhdsiSharing` - SFTP result upload

**Supporting Packages:**
- `dplyr`, `tibble`, `readr` - Data manipulation
- `Andromeda` - Out-of-core data handling
- `SqlRender` - Cross-platform SQL translation
- `ParallelLogger` - Logging & parallelization
- `ggplot2` - Visualization

**Database Support:**
- SQL Server, Oracle, PostgreSQL, Netezza, Impala, RedShift, BigQuery, Spark, APS

---

### **Workflow Execution**

1. **Setup**: Initialize R environment with `renv::init()` (captures dependencies in renv.lock)
2. **Database Connection**: Create connection details for CDM database
3. **Execute Study**: Run `execute()` with configuration parameters
4. **Results Review**: 
   - Local: View CSV files and CohortCounts.csv
   - Interactive: Use `prepareForEvidenceExplorer()` + `launchEvidenceExplorer()` for Shiny app
5. **Multi-site Synthesis**: Use `synthesizeResults()` to combine results across sites
6. **Submit Results**: Upload `Results_<databaseId>.zip` via `uploadResults()` to coordinating center

---

### **Study-Specific Details**

- **Package Version**: 0.0.1 (2022-03-23)
- **Author**: Martijn Schuemie (OHDSI)
- **Study Package Name**: ARB
- **Skeleton Type**: ComparativeEffectStudy (v0.0.1)
- **Generated by**: Hydra framework (automated skeleton generation from ATLAS)
- **License**: Apache License 2.0

---

### **Key Innovation**

This is a **distributable research study package** - it's designed to be executed independently at multiple healthcare organizations without sharing patient-level data. Results from each site are aggregated for meta-analysis, enabling large-scale comparative effectiveness research while maintaining data privacy.


---

## What it is

This is an **OHDSI comparative effectiveness research study package** (study ID 938, package name `ARB`) investigating the association between **angiotensin receptor blockers (ARBs)** and **renal cell carcinoma (RCCa)**. It was generated using OHDSI's Hydra framework from a study design defined in ATLAS, and is structured as a distributable R package meant to run at multiple healthcare sites without sharing patient-level data.

---

## The Scientific Question

The study compares:
- **Target**: An "ARBs Study Cohort" (cohort 1794964) — patients initiating ARB drugs
- **Comparator**: An "ARB Control Cohort" (cohort 1797490) — an active comparator
- **Primary Outcome**: "RCCa Outcome Cohort" (cohort 1795536) — incident renal cell carcinoma

The idea is a **new-user active comparator design**: rather than comparing ARB users to non-users (which would introduce healthy user bias), it compares them against another drug class. This is the OHDSI standard for observational drug safety research.

---

## The Pipeline

The main entry point is `execute()` in [R/Main.R](R/Main.R), which orchestrates five sequential steps controlled by boolean flags:

1. **`verifyDependencies`** — Checks that installed package versions match the `renv.lock` snapshot to ensure reproducibility.

2. **`createCohorts`** — Connects to an OMOP CDM database, instantiates the three cohorts (exposure, comparator, outcome) plus 10 **negative control outcomes** (conditions biologically implausible to be caused by ARBs: mania, tooth loss, frostbite, fear of flying, Marfan's syndrome, etc.). These are used to detect residual confounding and calibrate p-values.

3. **`synthesizePositiveControls`** — (Currently disabled via `doPositiveControlSynthesis = FALSE` in the code) Would inject synthetic signal on top of negative controls to create outcomes with known effect sizes, for method validation.

4. **`runAnalyses`** — Runs the `CohortMethod` propensity score pipeline: extracts covariates, fits propensity score models, matches/stratifies patients, fits outcome models, and estimates hazard ratios with confidence intervals for each Target-Comparator-Outcome combination and analysis variant.

5. **`packageResults`** — Bundles all results into a `Results_<databaseId>.zip` for submission to the study coordinator. Cell counts below `minCellCount` (default: 5) are censored to protect patient privacy.

---

## Key Design Details

- **TcosOfInterest.csv** is a massive 1MB file specifying hundreds of covariate concept IDs to include/exclude from the propensity model — this controls exactly which patient characteristics are and aren't used in the PS model for the RCCa analysis.
- **Multiple analysis variants** are defined in `cmAnalysisList.json` (2.1MB) — these likely vary propensity score method (matching vs. stratification), trimming thresholds, outcome model type, etc.
- The `minCellCount = 5` privacy threshold means any count under 5 patients is redacted before export.

---

## After the Analysis

Once a site runs `execute()`, they get a zip file. Then:

- **Shiny app**: `prepareForEvidenceExplorer()` + `launchEvidenceExplorer()` lets researchers interactively browse results locally, with an optional blind mode.
- **Multi-site meta-analysis**: `MetaAnalysis.R` can combine results from multiple sites using either DerSimonian-Laird or a Bayesian method (Schuemie et al. 2021).
- **Upload**: `uploadResults()` sends the zip to an SFTP server at the coordinating center.

---

## Technology Stack

The package is built on the OHDSI [HADES](https://ohdsi.github.io/Hades/) ecosystem: `DatabaseConnector` for database I/O, `CohortGenerator` for cohort creation, `CohortMethod` for the causal analysis, `FeatureExtraction` for covariates, `EmpiricalCalibration` for p-value calibration using negative controls, and `Andromeda` for out-of-memory data handling. It supports 9 database platforms (SQL Server, PostgreSQL, Redshift, BigQuery, Oracle, etc.).

---

In short: this is a complete, self-contained pharmacoepidemiology study designed to answer "do ARBs cause renal cell carcinoma?" using real-world data from electronic health records/claims, with rigorous propensity score methods and negative control validation, structured to run in a federated network without centralizing patient data.

I'll suggest some questions below.


<span class="suggestion">Walk through the cohort definitions in detail to understand the inclusion/exclusion criteria for the ARBs and RCCa cohorts.</span>


<span class="suggestion">Examine the `CohortMethod.R` and `cmAnalysisList.json` to understand the specific propensity score analysis variants being run.</span>


<span class="suggestion">Examine the `Export.R` file to understand exactly what result tables are produced and their schemas.</span>





## User

If I already created my target, comparator, and outcome cohorts (with cohort_ids 1,2,3 in my cohort table) how can I create just the negative control outcomes (do these go in the cohort table?) and then move onto the analysis?

## Assistant



<div><thinking id="thinking-1782411048933-cq3ly">
The user wants to:
1. Skip cohort creation for their main cohorts (already done with cohort_ids 1, 2, 3)
2. Create just the negative control outcomes
3. Run the analysis

Let me look at `CreateAllCohorts.R` to understand how negative controls are created, and `CohortMethod.R` to understand how to run the analysis with custom cohort IDs.
</thinking><span data-thinking-duration-ms="2684"></span></div>



<div><tool-call id="toolu_019eW3qFB353vTv8ryDzo2Gf"><script type="application/json">{"version":1,"name":"read","input":{"file_path":"R/CreateAllCohorts.R"},"caption":"R/CreateAllCohorts.R","captionLink":"R/CreateAllCohorts.R"}</script></tool-call></div>

<div><tool-call id="toolu_0178LrVSvfSP51nXHj5tF5Zp"><script type="application/json">{"version":1,"name":"read","input":{"file_path":"R/CohortMethod.R"},"caption":"R/CohortMethod.R","captionLink":"R/CohortMethod.R"}</script></tool-call></div>

<div><tool-result call-id="toolu_019eW3qFB353vTv8ryDzo2Gf"><script type="application/json">{"version":1,"status":"success","result":{"type":"text","value":"[File: 4.4KB, 89 lines, showing lines 1-89]\n     1→# Copyright 2022 Observational Health D...[truncated, total 5218 chars]"},"resultPreview":{"type":"code","value":"[File: 4.4KB, 89 lines, showing lines 1-89]\n# Copyright 2022 Observational Health Data Sciences and Informatics\n#\n# This file is part of ARB\n#\n# Licensed under the Apache License, Version 2.0 (the \"License\");\n# you may not use this file except in compliance with the License.\n# You may obtain a copy of the License at\n#\n#     http://www.apache.org/licenses/LICENSE-2.0\n#\n# Unless required by applicable law or agreed to in writing, software\n# distributed under the License is distributed on an \"AS IS\" BASIS,\n# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n# See the License for the specific language governing permissions and\n# limitations under the License.\n\ncreateCohorts <- function(connectionDetails,\n                          cdmDatabaseSchema,\n                          cohortDatabaseSchema,\n                          cohortTableNames,\n                          tempEmulationSchema,\n                          outputFolder) {\n  if (!file.exists(outputFolder))\n    dir.create(outputFolder)\n  \n  connection <- DatabaseConnector::connect(connectionDetails)\n  on.exit(DatabaseConnector::disconnect(connection))\n  \n  CohortGenerator::createCohortTables(connection = connection,\n                                      cohortDatabaseSchema = cohortDatabaseSchema,\n                                      cohortTableNames = cohortTableNames)\n  cohortDefinitionSet <- CohortGenerator::getCohortDefinitionSet(packageName = \"ARB\",\n                                                                 settingsFileName = \"Cohorts.csv\",\n                                                                 cohortFileNameValue = \"cohortId\")\n  CohortGenerator::generateCohortSet(connection = connection,\n                                     cohortDatabaseSchema = cohortDatabaseSchema,\n                                     cohortTableNames = cohortTableNames,\n                                     cdmDatabaseSchema = cdmDatabaseSchema,\n                                     tempEmulationSchema = tempEmulationSchema,\n                                     cohortDefinitionSet = cohortDefinitionSet)\n  \n  message(\"Creating negative control outcome cohorts\")\n  pathToCsv <- system.file(\"settings\", \"NegativeControls.csv\", package = \"ARB\")\n  negativeControls <- read.csv(pathToCsv)\n  # Currently assuming all negative controls are outcome controls\n  negativeControlOutcomes <- negativeControls\n  sql <- SqlRender::loadRenderTranslateSql(\"NegativeControlOutcomes.sql\",\n                                           \"ARB\",\n                                           dbms = connectionDetails$dbms,\n                                           tempEmulationSchema = tempEmulationSchema,\n                                           cdm_database_schema = cdmDatabaseSchema,\n                                           target_database_schema = cohortDatabaseSchema,\n                                           target_cohort_table = cohortTableNames$cohortTable,\n                                           outcome_ids = unique(negativeControlOutcomes$outcomeId))\n  DatabaseConnector::executeSql(connection, sql)\n  \n  # Check number of subjects per cohort:\n  message(\"Counting cohorts\")\n  counts <- CohortGenerator::getCohortCounts(connection = connection,\n                                             cohortDatabaseSchema = cohortDatabaseSchema,\n                                             cohortTable = cohortTableNames$cohortTable)\n  \n  counts <- addCohortNames(counts)\n  write.csv(counts, file.path(outputFolder, \"CohortCounts.csv\"), row.names = FALSE)\n}\n\naddCohortNames <- function(data, IdColumnName = \"cohortId\", nameColumnName = \"cohortName\") {\n  pathToCsv <- system.file(\"Cohorts.csv\", package = \"ARB\")\n  cohortsToCreate <- read.csv(pathToCsv)\n  pathToCsv <- system.file(\"settings\", \"NegativeControls.csv\", package = \"ARB\")\n  negativeControls <- read.csv(pathToCsv)\n  \n  idToName <- data.frame(cohortId = c(cohortsToCreate$cohortId,\n                                      negativeControls$outcomeId),\n                         cohortName = c(as.character(cohortsToCreate$cohortName),\n                                        as.character(negativeControls$outcomeName)))\n  idToName <- idToName[order(idToName$cohortId), ]\n  idToName <- idToName[!duplicated(idToName$cohortId), ]\n  names(idToName)[1] <- IdColumnName\n  names(idToName)[2] <- nameColumnName\n  data <- merge(data, idToName, all.x = TRUE)\n  # Change order of columns:\n  idCol <- which(colnames(data) == IdColumnName)\n  if (idCol < ncol(data) - 1) {\n    data <- data[, c(1:idCol, ncol(data) , (idCol + 1):(ncol(data) - 1))]\n  }\n  return(data)\n}\n"},"elapsedMs":7}</script></tool-result></div>

<div><tool-result call-id="toolu_0178LrVSvfSP51nXHj5tF5Zp"><script type="application/json">{"version":1,"status":"success","result":{"type":"text","value":"[File: 8.8KB, 168 lines, showing lines 1-168]\n     1→# Copyright 2022 Observational Health...[truncated, total 10183 chars]"},"resultPreview":{"type":"code","value":"[File: 8.8KB, 168 lines, showing lines 1-168]\n# Copyright 2022 Observational Health Data Sciences and Informatics\n#\n# This file is part of ARB\n#\n# Licensed under the Apache License, Version 2.0 (the \"License\");\n# you may not use this file except in compliance with the License.\n# You may obtain a copy of the License at\n#\n#     http://www.apache.org/licenses/LICENSE-2.0\n#\n# Unless required by applicable law or agreed to in writing, software\n# distributed under the License is distributed on an \"AS IS\" BASIS,\n# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n# See the License for the specific language governing permissions and\n# limitations under the License.\n\nrunCohortMethod <- function(connectionDetails,\n                            cdmDatabaseSchema,\n                            cohortDatabaseSchema,\n                            cohortTable,\n                            tempEmulationSchema,\n                            outputFolder,\n                            maxCores) {\n  cmOutputFolder <- file.path(outputFolder, \"cmOutput\")\n  if (!file.exists(cmOutputFolder)) {\n    dir.create(cmOutputFolder)\n  }\n  cmAnalysisListFile <- system.file(\"settings\",\n                                    \"cmAnalysisList.json\",\n                                    package = \"ARB\")\n  cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)\n  tcosList <- createTcos(outputFolder = outputFolder)\n  outcomesOfInterest <- getOutcomesOfInterest()\n  results <- CohortMethod::runCmAnalyses(connectionDetails = connectionDetails,\n                                         cdmDatabaseSchema = cdmDatabaseSchema,\n                                         exposureDatabaseSchema = cohortDatabaseSchema,\n                                         exposureTable = cohortTable,\n                                         outcomeDatabaseSchema = cohortDatabaseSchema,\n                                         outcomeTable = cohortTable,\n                                         outputFolder = cmOutputFolder,\n                                         tempEmulationSchema = tempEmulationSchema,\n                                         cmAnalysisList = cmAnalysisList,\n                                         targetComparatorOutcomesList = tcosList,\n                                         getDbCohortMethodDataThreads = min(3, maxCores),\n                                         createStudyPopThreads = min(3, maxCores),\n                                         createPsThreads = max(1, round(maxCores/10)),\n                                         psCvThreads = min(10, maxCores),\n                                         trimMatchStratifyThreads = min(10, maxCores),\n                                         fitOutcomeModelThreads = max(1, round(maxCores/4)),\n                                         outcomeCvThreads = min(4, maxCores),\n                                         refitPsForEveryOutcome = FALSE,\n                                         outcomeIdsOfInterest = outcomesOfInterest)\n  \n  message(\"Summarizing results\")\n  analysisSummary <- CohortMethod::summarizeAnalyses(referenceTable = results, \n                                                     outputFolder = cmOutputFolder)\n  analysisSummary <- addCohortNames(analysisSummary, \"targetId\", \"targetName\")\n  analysisSummary <- addCohortNames(analysisSummary, \"comparatorId\", \"comparatorName\")\n  analysisSummary <- addCohortNames(analysisSummary, \"outcomeId\", \"outcomeName\")\n  analysisSummary <- addAnalysisDescription(analysisSummary, \"analysisId\", \"analysisDescription\")\n  write.csv(analysisSummary, file.path(outputFolder, \"analysisSummary.csv\"), row.names = FALSE)\n  \n  message(\"Computing covariate balance\") \n  balanceFolder <- file.path(outputFolder, \"balance\")\n  if (!file.exists(balanceFolder)) {\n    dir.create(balanceFolder)\n  }\n  subset <- results[results$outcomeId %in% outcomesOfInterest,]\n  subset <- subset[subset$strataFile != \"\", ]\n  if (nrow(subset) > 0) {\n    subset <- split(subset, seq(nrow(subset)))\n    cluster <- ParallelLogger::makeCluster(min(3, maxCores))\n    ParallelLogger::clusterApply(cluster, subset, computeCovariateBalance, cmOutputFolder = cmOutputFolder, balanceFolder = balanceFolder)\n    ParallelLogger::stopCluster(cluster)\n  }\n}\n\ncomputeCovariateBalance <- function(row, cmOutputFolder, balanceFolder) {\n  outputFileName <- file.path(balanceFolder,\n                              sprintf(\"bal_t%s_c%s_o%s_a%s.rds\", row$targetId, row$comparatorId, row$outcomeId, row$analysisId))\n  if (!file.exists(outputFileName)) {\n    ParallelLogger::logTrace(\"Creating covariate balance file \", outputFileName)\n    cohortMethodDataFile <- file.path(cmOutputFolder, row$cohortMethodDataFile)\n    cohortMethodData <- CohortMethod::loadCohortMethodData(cohortMethodDataFile)\n    strataFile <- file.path(cmOutputFolder, row$strataFile)\n    strata <- readRDS(strataFile)\n    balance <- CohortMethod::computeCovariateBalance(population = strata, cohortMethodData = cohortMethodData)\n    saveRDS(balance, outputFileName)\n  }\n}\n\naddAnalysisDescription <- function(data, IdColumnName = \"analysisId\", nameColumnName = \"analysisDescription\") {\n  cmAnalysisListFile <- system.file(\"settings\",\n                                    \"cmAnalysisList.json\",\n                                    package = \"ARB\")\n  cmAnalysisList <- CohortMethod::loadCmAnalysisList(cmAnalysisListFile)\n  idToName <- lapply(cmAnalysisList, function(x) data.frame(analysisId = x$analysisId, description = as.character(x$description)))\n  idToName <- do.call(\"rbind\", idToName)\n  names(idToName)[1] <- IdColumnName\n  names(idToName)[2] <- nameColumnName\n  data <- merge(data, idToName, all.x = TRUE)\n  # Change order of columns:\n  idCol <- which(colnames(data) == IdColumnName)\n  if (idCol < ncol(data) - 1) {\n    data <- data[, c(1:idCol, ncol(data) , (idCol + 1):(ncol(data) - 1))]\n  }\n  return(data)\n}\n\ncreateTcos <- function(outputFolder) {\n  pathToCsv <- system.file(\"settings\", \"TcosOfInterest.csv\", package = \"ARB\")\n  tcosOfInterest <- read.csv(pathToCsv, stringsAsFactors = FALSE)\n  allControls <- getAllControls(outputFolder)\n  tcs <- unique(rbind(tcosOfInterest[, c(\"targetId\", \"comparatorId\")],\n                      allControls[, c(\"targetId\", \"comparatorId\")]))\n  createTco <- function(i) {\n    targetId <- tcs$targetId[i]\n    comparatorId <- tcs$comparatorId[i]\n    outcomeIds <- as.character(tcosOfInterest$outcomeIds[tcosOfInterest$targetId == targetId & tcosOfInterest$comparatorId == comparatorId])\n    outcomeIds <- as.numeric(strsplit(outcomeIds, split = \";\")[[1]])\n    outcomeIds <- c(outcomeIds, allControls$outcomeId[allControls$targetId == targetId & allControls$comparatorId == comparatorId])\n    excludeConceptIds <- as.character(tcosOfInterest$excludedCovariateConceptIds[tcosOfInterest$targetId == targetId & tcosOfInterest$comparatorId == comparatorId])\n    if (length(excludeConceptIds) == 1 && is.na(excludeConceptIds)) {\n      excludeConceptIds <- c()\n    } else if (length(excludeConceptIds) > 0) {\n      excludeConceptIds <- as.numeric(strsplit(excludeConceptIds, split = \";\")[[1]])\n    }\n    includeConceptIds <- as.character(tcosOfInterest$includedCovariateConceptIds[tcosOfInterest$targetId == targetId & tcosOfInterest$comparatorId == comparatorId])\n    if (length(includeConceptIds) == 1 && is.na(includeConceptIds)) {\n      includeConceptIds <- c()\n    } else if (length(includeConceptIds) > 0) {\n      includeConceptIds <- as.numeric(strsplit(includeConceptIds, split = \";\")[[1]])\n    }\n    tco <- CohortMethod::createTargetComparatorOutcomes(targetId = targetId,\n                                                        comparatorId = comparatorId,\n                                                        outcomeIds = outcomeIds,\n                                                        excludedCovariateConceptIds = excludeConceptIds,\n                                                        includedCovariateConceptIds = includeConceptIds)\n    return(tco)\n  }\n  tcosList <- lapply(1:nrow(tcs), createTco)\n  return(tcosList)\n}\n\ngetOutcomesOfInterest <- function() {\n  pathToCsv <- system.file(\"settings\", \"TcosOfInterest.csv\", package = \"ARB\")\n  tcosOfInterest <- read.csv(pathToCsv, stringsAsFactors = FALSE) \n  outcomeIds <- as.character(tcosOfInterest$outcomeIds)\n  outcomeIds <- do.call(\"c\", (strsplit(outcomeIds, split = \";\")))\n  outcomeIds <- unique(as.numeric(outcomeIds))\n  return(outcomeIds)\n}\n\ngetAllControls <- function(outputFolder) {\n  allControlsFile <- file.path(outputFolder, \"AllControls.csv\")\n  if (file.exists(allControlsFile)) {\n    # Positive controls must have been synthesized. Include both positive and negative controls.\n    allControls <- read.csv(allControlsFile)\n  } else {\n    # Include only negative controls\n    pathToCsv <- system.file(\"settings\", \"NegativeControls.csv\", package = \"ARB\")\n    allControls <- read.csv(pathToCsv)\n    allControls$oldOutcomeId <- allControls$outcomeId\n    allControls$targetEffectSize <- rep(1, nrow(allControls))\n  }\n  return(allControls)\n}\n"},"elapsedMs":4}</script></tool-result></div>



<div><thinking id="thinking-1782411053569-nf15a">
Now I have a clear picture. Let me understand the situation:

1. The user has their cohorts already created with IDs 1, 2, 3 (target, comparator, outcome) in their cohort table.
2. The package's `createCohorts()` function creates cohorts AND negative controls in the same cohort table using `NegativeControlOutcomes.sql`.
3. The negative controls use concept IDs as their cohort IDs (e.g., 4333677 for Mania).

Key issues to address:
1. **Negative control creation**: Yes, they go in the same cohort table. 
2. **The TCOs hardcode cohort IDs 1794964, 1797490, 1795536** - the user's cohorts have IDs 1, 2, 3. This is a mismatch. Both `TcosOfInterest.csv` and `NegativeControls.csv` reference `targetId = 1794964` and `comparatorId = 1797490`, which don't match the user's actual cohort IDs.

The user has a few options: they could re-insert their cohorts with the package-expected IDs, modify the package code to use their IDs, or run `createCohorts()` to regenerate the cohorts with the hardcoded IDs from the JSON definitions.

Looking more carefully at what they're asking—they have cohorts with IDs 1, 2, 3 but the package expects 1794964, 1797490, 1795536. The real solution is to create negative controls in their existing cohort table using the negative control concept IDs, then update the TCO and negative control CSV files to reference their actual cohort IDs instead of the hardcoded ones. and run that SQL directly to populate the negative controls. Then I need to look at the SQL file itself to see how the cohort IDs are being referenced and what adjustments are needed for the analysis phase.
</thinking><span data-thinking-duration-ms="18756"></span></div>



<div><tool-call id="toolu_012yjCMemXqM8sjLVy6bZVHw"><script type="application/json">{"version":1,"name":"search","input":{"includePatterns":["inst/sql/**/*.sql"]},"caption":"inst/sql/**/*.sql","inputPreview":{"type":"code","value":"Include: inst/sql/**/*.sql"}}</script></tool-call></div>

<div><tool-result call-id="toolu_012yjCMemXqM8sjLVy6bZVHw"><script type="application/json">{"version":1,"status":"success","result":{"type":"content","value":[{"type":"text","text":"{\n  \"rootFolders\": [\n    {\n      \"uri\": \"file:///Users/michaelconlin/Library/CloudStorage/...[truncated, total 983 chars]"}]},"elapsedMs":21}</script></tool-result></div>



<div><tool-call id="toolu_01RxwLbr5JtcW1d1o882uZMu"><script type="application/json">{"version":1,"name":"read","input":{"file_path":"inst/sql/sql_server/NegativeControlOutcomes.sql"},"caption":"inst/sql/sql_server/NegativeControlOutcomes.sql","captionLink":"inst/sql/sql_server/NegativeControlOutcomes.sql"}</script></tool-call></div>

<div><tool-result call-id="toolu_01RxwLbr5JtcW1d1o882uZMu"><script type="application/json">{"version":1,"status":"success","result":{"type":"text","value":"[File: 937B, 37 lines, showing lines 1-37]\n     1→CREATE TABLE #Codesets (\r\n     2→  ances...[truncated, total 1239 chars]"},"resultPreview":{"type":"code","value":"[File: 937B, 37 lines, showing lines 1-37]\nCREATE TABLE #Codesets (\r  ancestor_concept_id int NOT NULL,\r  concept_id int NOT NULL\r)\r;\r\rINSERT INTO #Codesets (ancestor_concept_id, concept_id)\r SELECT ancestor_concept_id, descendant_concept_id\r FROM @cdm_database_schema.CONCEPT_ANCESTOR\r WHERE ancestor_concept_id IN (@outcome_ids)\r;\r\r{DEFAULT @cohort_id_field_name = 'cohort_definition_id'}\r\rINSERT INTO @target_database_schema.@target_cohort_table (\r\tsubject_id,\r\t@cohort_id_field_name,\r\tcohort_start_date,\r\tcohort_end_date\r)\rSELECT\r\ts.subject_id,\r\ts.cohort_definition_id,\r\ts.cohort_start_date,\r\ts.cohort_start_date cohort_end_date\rFROM (\r    SELECT d.person_id subject_id,\r        c.ancestor_concept_id cohort_definition_id,\r        d.condition_start_date cohort_start_date\rFROM @cdm_database_schema.condition_occurrence d\rINNER JOIN #Codesets c ON c.concept_id = d.condition_concept_id\r) s\r;\r\rTRUNCATE TABLE #Codesets;\rDROP TABLE #Codesets;\r"},"elapsedMs":5}</script></tool-result></div>



<div><thinking id="thinking-1782411076295-n8cda">
Now I have a clear picture. Let me summarize what the user needs to do:

1. **Negative controls go in the same cohort table** - Yes, they are inserted into the same cohort table using the condition concept IDs (4333677, 433244, etc.) as the `cohort_definition_id`.

2. **To create just negative controls**, they can run the relevant SQL directly using `SqlRender` and `DatabaseConnector`, essentially extracting the relevant lines from `createCohorts()`.

3. **The cohort ID mismatch problem**: The package hardcodes cohort IDs 1794964, 1797490, 1795536 in `TcosOfInterest.csv` and `NegativeControls.csv`. The user's cohorts have IDs 1, 2, 3. They need to either:
   - Re-insert their cohorts with the hardcoded IDs (simpler if they haven't progressed far)
   - Or modify the settings files to reference their actual cohort IDs 1, 2, 3 instead of the package defaults

Option A means updating `NegativeControls.csv` and `TcosOfInterest.csv` to swap out the original IDs for theirs, which is cleaner but requires editing package internals. Option B would duplicate their cohort data with the expected IDs, which feels hacky but avoids touching the package files.

I think the best approach is to have them create the negative controls directly using the R code from `createCohorts()`, then handle the ID mismatch separately for the analysis piece.

For the negative control creation, they can run the code that loads the negative controls CSV, renders the SQL template with the appropriate database parameters, and executes it to populate the outcome tables. Then for the analysis itself, they'll need to update the `TcosOfInterest.csv` and `NegativeControls.csv` files to match their actual cohort IDs (1, 2, 3) instead of the default IDs in those configuration files. Let me write out clear step-by-step instructions for them.
</thinking><span data-thinking-duration-ms="15311"></span></div>

There are two things to address here: creating the negative controls, and a **cohort ID mismatch** you'll need to fix before the analysis will work.

---

## 1. Creating Negative Control Outcome Cohorts

Yes, they go into the same cohort table. The SQL inserts rows using each condition's concept ID as the `cohort_definition_id` (e.g., 4333677 for Mania). You can run just that portion of `createCohorts()` directly:

```r
library(ARB)
library(DatabaseConnector)
library(SqlRender)

connection <- DatabaseConnector::connect(connectionDetails)

negativeControls <- read.csv(
  system.file("settings", "NegativeControls.csv", package = "ARB")
)

sql <- SqlRender::loadRenderTranslateSql(
  sqlFilename        = "NegativeControlOutcomes.sql",
  packageName        = "ARB",
  dbms               = connectionDetails$dbms,
  tempEmulationSchema = getOption("sqlRenderTempEmulationSchema"),
  cdm_database_schema    = cdmDatabaseSchema,
  target_database_schema = cohortDatabaseSchema,
  target_cohort_table    = cohortTable,
  outcome_ids            = unique(negativeControls$outcomeId)
)

DatabaseConnector::executeSql(connection, sql)
DatabaseConnector::disconnect(connection)
```

---

## 2. The Cohort ID Mismatch — Fix Before Running the Analysis

This is the more important issue. The package's settings files hardcode the original ATLAS cohort IDs:

| File | Hardcoded IDs |
|---|---|
| `inst/settings/NegativeControls.csv` | `targetId = 1794964`, `comparatorId = 1797490` |
| `inst/settings/TcosOfInterest.csv` | `targetId = 1794964`, `comparatorId = 1797490`, `outcomeIds` includes `1795536` |

If your cohorts are IDs 1, 2, 3, `runCohortMethod()` will look for cohorts that don't exist under those IDs and produce empty results. You need to update those two files:

**In `inst/settings/NegativeControls.csv`**, replace `1794964` → `1` and `1797490` → `2`.

**In `inst/settings/TcosOfInterest.csv`**, replace `1794964` → `1`, `1797490` → `2`, and `1795536` → `3` in the `outcomeIds` column.

You can do that in R:

```r
# Fix NegativeControls.csv
nc_path <- system.file("settings", "NegativeControls.csv", package = "ARB")
nc <- read.csv(nc_path)
nc$targetId[nc$targetId == 1794964] <- 1
nc$comparatorId[nc$comparatorId == 1797490] <- 2
write.csv(nc, nc_path, row.names = FALSE)

# Fix TcosOfInterest.csv
tcos_path <- system.file("settings", "TcosOfInterest.csv", package = "ARB")
tcos <- read.csv(tcos_path, stringsAsFactors = FALSE)
tcos$targetId[tcos$targetId == 1794964] <- 1
tcos$comparatorId[tcos$comparatorId == 1797490] <- 2
# Replace 1795536 inside the semicolon-delimited outcomeIds string
tcos$outcomeIds <- gsub("1795536", "3", tcos$outcomeIds)
write.csv(tcos, tcos_path, row.names = FALSE)
```

> **Note**: `system.file()` returns a path inside your installed package library. If you're working from the source package directly (i.e., not installed), use `inst/settings/` relative paths instead.

---

## 3. Run the Analysis

Once the negative controls are created and IDs are corrected, call `runCohortMethod()` directly (skipping `createCohorts`):

```r
ARB:::runCohortMethod(
  connectionDetails   = connectionDetails,
  cdmDatabaseSchema   = cdmDatabaseSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTable         = cohortTable,
  tempEmulationSchema = getOption("sqlRenderTempEmulationSchema"),
  outputFolder        = outputFolder,
  maxCores            = maxCores
)
```

Note the `:::` since `runCohortMethod` is not exported from the package namespace.

<span class="suggestion">Check how `addCohortNames()` in `CohortMethod.R` uses `Cohorts.csv` for name lookups — it also references the original cohort IDs and may need updating for labels to appear correctly in the analysis summary and Shiny app.</span>

## Create the Cohorts using Capr - an alternative approach matching existing cohort creation


```r
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
  cohortId   = negativeControls$outcomeId,
  cohortName = negativeControls$outcomeName,
  json       = sapply(nc_cohort_defs, Capr::toJson)
)

# Insert negative controls into your existing cohort table
# (generateCohortSet appends; it does not drop/recreate the table)
connection <- DatabaseConnector::connect(connectionDetails)

CohortGenerator::generateCohortSet(
  connection           = connection,
  cdmDatabaseSchema    = cdmDatabaseSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTableNames     = CohortGenerator::getCohortTableNames(cohortTable),
  cohortDefinitionSet  = nc_cohort_def_set
)

DatabaseConnector::disconnect(connection)
```

A few notes on differences from the SQL approach:

- The original SQL inserts **all occurrences** of each condition. Capr here uses `primaryCriteriaLimit = "First"`, which is first occurrence only. For CohortMethod this makes no practical difference — it only looks for the first outcome event after the at-risk period starts regardless.
- Capr/CohortGenerator uses `CONCEPT_ANCESTOR` under the hood the same way the SQL does, so descendants are included automatically via `descendants()`.
- `generateCohortSet()` appends to the existing table, so your cohorts with IDs 1, 2, 3 are safe.

