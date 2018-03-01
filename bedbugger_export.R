library(dplyr)
library(RPostgreSQL)
library(xml2)

# Note: the project contains a .Renviron file, which is used to set the PGSERVICEFILE
# environment variable.

clean_content <- function(content, id = NULL) {
    content <- read_html(content)
    scripts <-  xml_find_all(content, '//script')
    xml_remove(scripts)
    iframes <-  xml_find_all(content, '//iframe')
    xml_remove(iframes)
    content <- xml_child(content, 'body')
    xml_name(content) <- 'div'
    if (!is.null(id)) {
        xml_attr(content, 'id') <- paste('comment', id, sep = '-')
    }
    as.character(content)
}

con <- dbConnect(PostgreSQL(), dbname = 'postgres:///?service=bedbugger')
author <- tbl(con, 'author')
post <- tbl(con, 'post') %>%
    left_join(author, by = c('author_id' = 'id')) %>%
    select(id, date_gmt, author_name = name, title, content) %>%
    collect()
for (i in 1:nrow(post)) {
    post[[i, 'content']] <- clean_content(post[[i, 'content']])
}
comment <- tbl(con, 'comment') %>%
    select(id, post_id, date_gmt, author_name, content) %>%
    collect()
for (i in 1:nrow(comment)) {
    comment[[i, 'content']] <- clean_content(
        comment[[i, 'content']], comment[[i, 'id']])
}

dbDisconnect(con)

save(post, comment, file = 'BedbuggerCoder/bedbugger.RData')
