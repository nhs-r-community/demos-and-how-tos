#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinydashboard
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic 
    dashboardPage(
      
      dashboardHeader(title = "Patient experience",
                      titleWidth = 300),
      dashboardSidebar(
        width = 300,
        sidebarMenu(
          
          menuItem("Upload data", 
                   tabName = "upload-data"),
          menuItem("Per class",
                   tabName = "per_class")
          
        )
      ),
      dashboardBody(
        
        tabItems(
          tabItem(tabName = "upload-data",
                  mod_upload_data_ui("upload_data_ui_1")
          ),
          tabItem(tabName = "per_class",
                  mod_per_class_ui("per_class_ui_1"))
        )
      )
    )
  )
}

#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )
  
  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'excelReports'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}

