library(RPostgreSQL)

# Note: the project contains a .Renviron file, which is used to set the PGSERVICEFILE
# environment variable.

con <- dbConnect(PostgreSQL(), dbname = 'postgres:///?service=bedbugs')

dbListTables(con)

dbDisconnect(con)
