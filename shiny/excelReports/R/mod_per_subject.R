#' per_subject UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_per_subject_ui <- function(id){
  ns <- NS(id)
  tagList(
    
    fluidPage(
      
      checkboxInput(ns("all_graphs"), "Return all subjects?"),
      
      conditionalPanel(
        condition = "input.all_graphs==0", ns = ns,
        
        uiOutput(ns("which_subjectUI"))
      ),
      
      downloadButton(ns("download_graphs")),
    )
  )
}

#' per_subject Server Functions
#'
#' @noRd 
mod_per_subject_server <- function(id, all_data){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    output$which_subjectUI <- renderUI({
      
      choices = unique(all_data()$subject)
      
      selectInput(session$ns("which_subject"), "Select subject",
                  choices = choices)
    })
    
    output$download_graphs <- downloadHandler(
      
      filename = "graphs.zip",
      content = function(file) {
        
        df <- all_data()
        
        df$marks_perc <- df$marks / df$max_marks * 100
        
        df$subject <- factor(tolower(df$subject))
        df$test_desc <- factor(tolower(df$test_desc))
        df$name_short <- factor(df$name_short)
        df$test_occ_no_f <- factor(paste("Occ", df$test_occ, sep=":"))
        
        
        if(input$all_graphs) {
          
          subjects <- sort(unique(all_data()$subject))
          
        } else {
          
          subjects <- input$which_subject
        }
        
        files <- NULL
        
        myDir <- tempdir()

        for(i in subjects) {
          
          my_file_name <- paste0(i, ".pdf")
          
          adf <- df %>% 
            dplyr::filter(subject == i)
          
          pdf(file.path(myDir, my_file_name), width = 15, height = 10)
          
          p1 <- ggplot2::ggplot(adf, 
                                ggplot2::aes(x = test_occ_no_f, 
                                             y = marks_perc)) +
            ggplot2::geom_boxplot() +
            ggplot2::facet_wrap(class ~ test_desc) +
            ggplot2::ylab("% Score") +
            ggplot2::xlab("Test Occ") +
            ggplot2::scale_y_continuous(breaks = seq(0, 100, 10), 
                                        limits = c(0, 100)) +
            ggplot2::ggtitle(my_file_name)
          print(p1)
          
          files <- c(my_file_name, files)
          dev.off()
        }
        zip(file, file.path(myDir, files), flags = "-j")
      }
    )
  })
}
