library(RPostgreSQL)

Sys.setenv(PGSERVICEFILE='/nfs/bedbugs-data/pg_service.conf')
con <- dbConnect(PostgreSQL(), dbname = 'postgres:///?service=bedbugs')

dbListTables(con)
