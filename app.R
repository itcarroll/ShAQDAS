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
library(RSQLite)
library(xml2)

# Load post and comments as data.frames from database
con <- dbConnect(SQLite(), dbname = 'wilwheaton.db')
author <- tbl(con, 'author')
post <- tbl(con, 'post') %>%
    left_join(author, by = c('author_id' = 'id')) %>%
    select(id, date_gmt, author_name = name, title, content)
comment <- tbl(con, 'comment') %>%
    select(id, post_id, date_gmt, author_name, content)

# function to purge <iframe> and <script> from content
# and add <div> container with id when provided
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

# vector for IDs used in navigation
posts <- post %>%
    arrange(desc(date_gmt)) %>%
    pull(id)

# storage of entered codes
obs_filename <- 'codes.RData'
if (file.exists(obs_filename)) {
    load(obs_filename)
}
if (!exists('codebook')) {
    codebook <- data.frame(
        code = c('BB-8', 'C-3PO', 'R2-D2'),
        description = c(
            'spherical in quality',
            'bright, translates easily',
            'wasn\'t that Wesley\'s droid?'),
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

# User Interface

## elements
sidebar <- sidebarPanel(
    tags$div(class = 'inline',
        selectInput('post_id', label = 'Select post', choices = posts),
        uiOutput('comment_select')),
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
    h3('Coding Results'),
    p('Download all coding results (the entries displayed in the sidebar with
        their associated post or comment), or replace them by uploading a new
        CSV file with the same columns.'),
    downloadButton('codes_down', 'Download'),
    fileInput('codes_up', label = 'Replace with ...', accept = 'text/csv'),
    h3('Codebook'),
    p('Create new entries in the Codebook. To edit existing entries, download
        and replace the Codebook. Backup your data (i.e. download the coding
        results) before replacing the codebook!'),
    tableOutput('codebook'),
    tags$div(class = 'inline',
        actionButton('codebook_submit', 'Append'),
        textInput('codebook_code', 'code'),
        textInput('codebook_description', 'description')),
    p('Download the current codebook (displayed below), or
      replace it by uploading a new CSV file with identical structure.'),
    downloadButton('codebook_down', 'Download'),
    fileInput('codebook_up', label = 'Replace with ...', accept = 'text/csv')
)
main <- mainPanel(
    tabsetPanel(id = 'content', type = 'tabs',
        post_tab, comment_tab, codes_tab),
    width = 8,
    id = 'main-panel'
)

## layout and assets
ui <- fluidPage(
    sidebarLayout(sidebar, main),
    includeScript('app.js'),
    tags$head(includeCSS('app.css')),
    id = 'app-container')

# Server
server <- function(input, output, session) {
    
    # make values reactive
    robs <- reactiveVal(obs)
    rcodebook <- reactiveVal(codebook)
    
    # handle switching tab to Post or Comments
    ignore_comment_id <- reactiveVal(TRUE)
    observeEvent(input[['content']], {
        if (input[['content']] == 'Post') {
            ignore_comment_id(TRUE)
        } else if (input[['content']] == 'Comments')
            ignore_comment_id(FALSE)
    })
    
    # pull from database tables
    current_post <- reactive(post %>%
        filter(id == input[['post_id']]) %>%
        collect())
    current_comment_set <- reactive(comment %>%
        filter(post_id == input[['post_id']]) %>%
        arrange(date_gmt) %>%
        collect())
    current_comment <- reactive(comment %>%
        filter(post_id == input[['post_id']]) %>%
        filter(id == input[['comment_id']]) %>%
        collect())

    # render comment selector
    output[['comment_select']] <- renderUI(
        selectInput('comment_id', label = 'Select comment',
            choices = current_comment_set() %>%
                pull(id)))
    
    # post metadata
    output[['author']] <- renderText({
        if (ignore_comment_id()) {
            current <- current_post()
        } else {
            current <- current_comment()
        }
        current[['author_name']]
    })
    output[['date_gmt']] <- renderText({
        if (ignore_comment_id()) {
            current <- current_post()
        } else {
            current <- current_comment()
        }
        strftime(current[['date_gmt']], '%Y-%m-%d %H:%M:%S')
    })

    # post content
    output[['post_title']] <- renderText(current_post()[['title']])
    output[['post_content']] <- renderText(
        clean_content(current_post()[['content']]))

    # comment content
    output[['comment_content']] <- renderText({
        comment_set <- current_comment_set()
        idx <- which(comment_set[['id']] == current_comment()[['id']])
        # unideal solution this running before current_comment also updates
        if (length(idx) == 0) {
            comments = ''
        } else {
            comments <- mapply(clean_content,
                comment_set[['content']], comment_set[['id']])
            comments[[idx]] <- sub('<div', '<div class="active"',
                comments[[idx]], fixed = TRUE)
        }
        paste(comments, collapse = '')
    })
    
    # existing codes
    output[['obs_prior']] <- renderTable({
        obs_prior <- filter(robs(), post_id == input[['post_id']])
        if (ignore_comment_id()) {
            obs_prior <- filter(obs_prior, is.na(comment_id))
        } else {
            obs_prior <- filter(obs_prior, comment_id == input[['comment_id']])            
        }
        select(obs_prior, code, text)
    }, width = '100%')
    
    # coding posts and comments
    output[['code_select']] <- renderUI(
        selectInput('obs_code', label = 'Code',
            choices = c('', rcodebook()[['code']])))
    observeEvent(input[['obs_submit']], {
        obs_row <- nrow(obs) + 1
        obs[[obs_row, 1]] <- as.integer(input[['post_id']])
        if (!ignore_comment_id()) {
            obs[[obs_row, 2]] <- as.integer(input[['comment_id']])
        }
        obs[[obs_row, 3]] <- input[['obs_code']]
        obs[[obs_row, 4]] <- input[['obs_text']]
        obs[[obs_row, 5]] <- input[['obs_memo']]
        updateTextInput(session, 'obs_memo', value = '')
        updateTextAreaInput(session, 'obs_text', value = '')
        updateSelectInput(session, 'obs_code', selected = '')
        robs(obs)
    })

    # append to codebook
    observeEvent(input[['codebook_submit']], {
        idx <- nrow(codebook) + 1
        codebook[[idx, 'code']] <- input[['codebook_code']]
        codebook[[idx, 'description']] <- input[['codebook_description']]
        updateTextInput(session, 'codebook_code', value = '')
        updateTextInput(session, 'codebook_description', value = '')
        rcodebook(codebook)
    })
    
    # down/upload
    output[['codebook']] <- renderTable(rcodebook())
    output[['codebook_down']] <- downloadHandler(
        filename = function() paste('codebook-', Sys.Date(), '.csv', sep=''),
        content = function(c) write.csv(rcodebook(), c, row.names = FALSE))
    observeEvent(input[['codebook_up']], {
        infile <- input[['codebook_up']]
        # overwrite codebook
        codebook <- read.csv(infile$datapath, stringsAsFactors = FALSE)
        rcodebook(codebook)
    })
    output[['codes_down']] <- downloadHandler(
        filename = function() paste('codes-', Sys.Date(), '.csv', sep=''),
        content = function(c) write.csv(robs(), c, row.names = FALSE))
    observeEvent(input[['codes_up']], {
        infile <- input[['codes_up']]
        # overwrite codes
        obs <- read.csv(infile$datapath, stringsAsFactors = FALSE)
        obs[['code']] <- factor(obs[['code']], levels = rcodebook()[['code']])
        if (anyNA(obs[['code']])) {
            showModal(modalDialog(
                title = 'Replacement Unallowed',
                'The uploaded file was not accepted because missing codes were
                present or introduced. Are all codes in the codebook?',
                easyClose = TRUE
            ))
        } else {
            robs(obs)
        }
    })
    
    # store data locally on session ended
    observeEvent(robs(), {
        obs <<- robs()
    })
    observeEvent(rcodebook(), {
        codebook <<- rcodebook()
        # append levels to obs
        levels(obs[['code']]) <- union(levels(obs[['code']]), codebook[['code']])
        robs(obs)
    })
    session$onSessionEnded(function() {
        save(codebook, obs, file = obs_filename)
        dbDisconnect(con)
        stopApp()
    })
}

# run the application 
shinyApp(ui = ui, server = server)
