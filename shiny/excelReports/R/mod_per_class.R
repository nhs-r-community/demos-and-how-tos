#' per_class UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_per_class_ui <- function(id){
  ns <- NS(id)
  tagList(
 
  )
}
    
#' per_class Server Functions
#'
#' @noRd 
mod_per_class_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_per_class_ui("per_class_ui_1")
    
## To be copied in the server
# mod_per_class_server("per_class_ui_1")
