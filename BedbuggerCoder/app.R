#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(RPostgreSQL)
library(xml2)

# Database connection
con <- dbConnect(PostgreSQL(), dbname = 'postgresql:///?service=bedbugger')
posts <- tbl(con, 'post') %>%
    arrange(desc(date_gmt)) %>%
    pull(id)

# UI (user interface)

## elements
sidebar <- sidebarPanel(
    numericInput('post_idx', 'Select post:',
                 1, min = 1, max = length(posts),
                 step = 1)
)
main <- mainPanel(htmlOutput('post_content'))

## ui
ui <- fluidPage(
   titlePanel("BedbuggerCoder"),
   sidebarLayout(sidebar, main)
)

# Server (that runs R code)
server <- function(input, output, session) {
   
   output$post_content <- renderText({
      # pull from bedbugger database
      content <- tbl(con, 'post') %>%
           filter(id == posts[[input$post_idx]]) %>%
           pull(content)
      content <- paste('<div>', content, '</div>') %>%
           read_html()
      scripts <-  xml_find_all(content, '//script')
      xml_remove(scripts)
      iframes <-  xml_find_all(content, '//iframe')
      xml_remove(iframes)
      as.character(content)
   })
   
   session$onSessionEnded(function() {
       dbDisconnect(con)
   })
}

# Run the application 
shinyApp(ui = ui, server = server)
