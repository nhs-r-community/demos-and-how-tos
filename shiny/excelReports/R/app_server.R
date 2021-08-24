#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # Your application server logic 
  
  # load data
  
  all_data <- mod_upload_data_server("upload_data_ui_1")
  
  mod_per_class_server("per_class_ui_1", all_data)
}
