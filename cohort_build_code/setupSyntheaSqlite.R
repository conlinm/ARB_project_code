library(SqlRender)
library(DatabaseConnector)

# connect to new database
connDeets <- createConnectionDetails(dbms = "sqlite", server = "/Users/michaelconlin/synthea100k/synthea100k.sqlite")
connection <- connect(connDeets)
querySql(connection, "SELECT COUNT(*) FROM person;")
