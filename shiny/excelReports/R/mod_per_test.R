#' per_test UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_per_test_ui <- function(id){
  ns <- NS(id)
  tagList(
    
    fluidPage(
      # dynamic UI for three choices
      
      fluidRow(
        column(3, uiOutput(ns("which_subjectUI"))),
        column(3, uiOutput(ns("which_classUI"))),
        column(3, uiOutput(ns("which_test_descUI")))
      ),
      
      fluidRow(
        
        downloadButton(ns("download_graphs")),
      )
    )
  )
}

#' per_test Server Functions
#'
#' @noRd 
mod_per_test_server <- function(id, all_data){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    cleaned_data <- reactive({
      
      df <- all_data()
      
      df$marks_perc <- df$marks / df$max_marks * 100
      df$subject <- factor(tolower(df$subject))
      df$test_desc <- factor(tolower(df$test_desc))
      
      return(df)
    })
    
    output$which_subjectUI <- renderUI({
      
      choices <- unique(cleaned_data()$subject)
      
      selectInput(session$ns("which_subject"), "Select subject",
                  choices = choices)
      
    })
    
    output$which_classUI <- renderUI({
      
      choices <- unique(cleaned_data()$class)
      
      selectInput(session$ns("which_class"), "Select class",
                  choices = choices)
      
    })
    
    output$which_test_descUI <- renderUI({
      
      choices <- unique(cleaned_data()$test_desc)
      
      selectInput(session$ns("which_test_desc"), "Select test description",
                  choices = choices)
      
    })
    
  })
}
