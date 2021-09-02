#' upload_data UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_upload_data_ui <- function(id){
  ns <- NS(id)
  tagList(
    
    fluidPage(
      
      actionButton(ns("launch_modal"), "Upload new data"),
      
      hr(),
      
      h3("Data preview"),
      
      DT::DTOutput(ns("data_preview"))
    )
    
  )
}

#' upload_data Server Functions
#'
#' @noRd 
mod_upload_data_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    observeEvent(input$launch_modal, {
      datamods::import_modal(
        id = session$ns("myid"),
        from = "file",
        title = "Import data to be used in application"
      )
    })
    
    imported <- datamods::import_server("myid", return_class = "tbl_df")
    
    output$data_preview <- DT::renderDT({
      
      imported$data()
    })
    
    reactive(
      imported$data()
    )
    
  })
}
