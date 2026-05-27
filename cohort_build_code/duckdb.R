# setup a duckdb db of synthea OMOP data from AWS
# installed duck db on my mac mini 4/19/2026
install.packages("duckdb")
library("duckdb")
# create a persistant DuckDB database file
con <- dbConnect