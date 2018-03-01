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

# Load post and comments data.frames from bedbugger.RData
load('bedbugger.RData')

# vector for IDs used in navigation
posts <- post %>%
    arrange(desc(date_gmt)) %>%
    pull(id)

# Storage of entered codes
obs_filename <- 'codes.RData'
if (file.exists(obs_filename)) {
    load(obs_filename)
}
if (!exists('codebook')) {
    codebook <- data.frame(
        code = factor(c('BB8', 'C3PO', 'etc.')),
        description = c('description of code BB8', 'description of code C3PO', ''),
        stringsAsFactors = FALSE)
}
if (!exists('obs')) {
    obs <- data.frame(
        post_id = integer(),
        comment_id = integer(),
        code = factor(levels = codebook[['code']]),
        text = character(),
        memo = character(), stringsAsFactors = FALSE)
}

# UI (user interface)

## elements
sidebar <- sidebarPanel(
    selectInput('post_id', label = 'Select post', choices = posts),
    uiOutput('comment_select'),
    h3('Author'),
    textOutput('author'),
    h3('Date'),
    textOutput('date_gmt'),
    h3('Codes'),
    textAreaInput('obs_text', 'Segment', placeholder = 'copied from text'),
    textInput('obs_memo', 'Memo', placeholder = 'any comment or note'),
    uiOutput('code_select'),
    actionButton('obs_submit', 'Add Code'),
    tableOutput('obs_prior'),
    width = 4,
    id = 'sidebar-panel'
)
post_tab <- tabPanel('Post',
    h2(textOutput('post_title')),
    htmlOutput('post_content')
)
comment_tab <- tabPanel('Comments',
    htmlOutput('comment_content')
)
codes_tab <- tabPanel('Codes',
    h3('Codebook'),
    p('Download the current codebook (displayed below), or
      replace it by uploading a new CSV file with identical structure.'),
    fileInput('codebook_up', label = '', accept = 'text/csv'),
    tableOutput('codebook'),
    downloadButton('codebook_down', 'Download'),
    h3('Codes'),
    p('The current codes are displayed with the associated post or comments.
      Download the table of all codes, or replace it by uploading a new CSV
      file with identical structure.'),
    fileInput('codes_up', label = '', accept = 'text/csv'),
    downloadButton('codes_down', 'Download')
)
main <- mainPanel(
    tabsetPanel(id = 'content', type = 'tabs', post_tab, comment_tab, codes_tab),
    width = 8,
    id = 'main-panel'
)

## User Interface (web page)
ui <- fluidPage(sidebarLayout(sidebar, main),
                includeScript('www/app.js'),
                tags$head(includeCSS('www/app.css')),
                id = 'app-container')

# Server (that runs R code)
server <- function(input, output, session) {
    
    # make values reactive
    robs <- reactiveVal(obs)
    rcodebook <- reactiveVal(codebook)
    
    # pull from bedbugger tables
    current_post <- reactive(
        post %>%
            filter(id == input[['post_id']]))
    current_comment_set <- reactive(
        comment %>%
            filter(post_id == input[['post_id']]) %>%
            arrange(date_gmt))
    current_comment <- reactive(
        current_comment_set() %>%
            filter(id == input[['comment_id']]))

    # render comment selector
    output[['comment_select']] <- renderUI(
        selectInput('comment_id', label = 'Select comment',
            choices = pull(current_comment_set(), id)))
    
    # post metadata
    output[['author']] <- renderText(
        switch(input[['content']],
            'Comments' = current_comment()[['author_name']],
            current_post()[['author_name']]))
    output[['date_gmt']] <- renderText(
        switch(input[['content']],
            'Comments' = current_comment()[['date_gmt']],
            current_post()[['date_gmt']]) %>%
            strftime(format = "%Y-%m-%d %H:%M:%S"))

    # post content
    output[['post_title']] <- renderText(current_post()[['title']])
    output[['post_content']] <- renderText(current_post()[['content']])

    # comment content
    output[['comment_content']] <- renderText({
        comments <- current_comment_set()[['content']]
        comments[[1]] <- sub('<div', '<div class="active"',
            comments[[1]], fixed = TRUE)
        paste(comments, collapse = '')
    })
    
    # existing codes entered
    output[['obs_prior']] <- renderTable(
        switch(input[['content']],
            'Comments' = filter(robs(), comment_id == input[['comment_id']]),
            filter(robs(), is.na(comment_id))) %>%
            filter(post_id == input[['post_id']]) %>%
            select(code, text),
        width = '100%')

    # code entry
    output[['code_select']] <- renderUI(
        selectInput('obs_code', label = 'Code',
            choices = c('', levels(robs()[['code']]))))
    observeEvent(input[['obs_submit']], {
        obs <- robs()
        obs_row <- nrow(obs) + 1
        obs[[obs_row, 1]] <- input[['post_id']]
        if (input[['content']] == 'Comments') {
            obs[[obs_row, 2]] <- input[['comment_id']]
        }
        obs[[obs_row, 3]] <- input[['obs_code']]
        obs[[obs_row, 4]] <- input[['obs_text']]
        obs[[obs_row, 5]] <- input[['obs_memo']]
        robs(obs)
        obs <<- robs()
        updateTextInput(session, 'obs_memo', value = '')
        updateTextAreaInput(session, 'obs_text', value = '')
        updateSelectInput(session, 'obs_code', selected = '')
    })

    # Down/upload
    output[['codebook']] <- renderTable(rcodebook())
    output[['codebook_down']] <- downloadHandler(
        filename = function() {
            paste('codebook-', Sys.Date(), '.csv', sep='')
        },
        content = function(con) {
            write.csv(rcodebook(), con, row.names = FALSE)
        }
    )
    output[['codes_down']] <- downloadHandler(
        filename = function() {
            paste('codes-', Sys.Date(), '.csv', sep='')
        },
        content = function(con) {
            write.csv(robs(), con, row.names = FALSE)
        }
    )
    observeEvent(input[['codebook_up']], {
        infile <- input[['codebook_up']]
        codebook <- read.csv(infile$datapath, stringsAsFactors = FALSE)
        codebook[[1]] <- factor(codebook[[1]])
        rcodebook(codebook)
        codebook <<- rcodebook()
        levels(obs[['code']]) <- codebook[['code']]
        robs(obs)
    })
    observeEvent(input[['codes_up']], {
        infile <- input[['codes_up']]
        obs <- read.csv(infile$datapath, stringsAsFactors = FALSE)
        obs[['code']] <- factor(obs[['code']],
            levels = rcodebook()[['code']])
        robs(obs)
        obs <<- robs()
    })
    
    # on session ended
    session$onSessionEnded(function() {
        save(codebook, obs, file = obs_filename)
        stopApp()
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
