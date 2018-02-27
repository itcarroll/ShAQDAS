library(dplyr)
library(RPostgreSQL)

# Note: the project contains a .Renviron file, which is used to set the PGSERVICEFILE
# environment variable.

con <- dbConnect(PostgreSQL(), dbname = 'postgres:///?service=bedbugger')

posts <- tbl(con, 'post') %>%
    arrange(desc(date_gmt)) %>%
    head(10) %>%
    collect()

dbDisconnect(con)
