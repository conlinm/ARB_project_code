# jsonToCaprFile() is a function in the jsonToCapr.r file
# that converts an OHDSI cohort definition JSON file (e.g., exported
# from ATLAS) into an R script that uses the Capr package to programmatically
# build the same cohort definition.

# Convert the primary ARBS cohort definition
jsonToCaprFile(
  jsonPath = "cohort_arbs.json",
  outRPath = "cohort_build_arbs.r"
)

# Convert the ARBS control cohort definition
jsonToCaprFile(
  jsonPath = "cohort_arbs_control.json",
  outRPath = "cohort_build_arbs_control.r"
)

# Convert the ARBS outcome cohort definition
jsonToCaprFile(
  jsonPath = "cohort_arbs_outcome.json",
  outRPath = "cohort_build_arbs_outcome.r"
)
