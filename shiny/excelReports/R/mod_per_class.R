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
mod_per_class_server <- function(id, all_data){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
  })
}
