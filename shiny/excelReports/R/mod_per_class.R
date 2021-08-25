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
    
    fluidPage(
      
      downloadButton(ns("download_graphs")),
    )
  )
}

#' per_class Server Functions
#'
#' @noRd 
mod_per_class_server <- function(id, all_data){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    output$download_graphs <- downloadHandler(
      
      filename = "graphs.zip",
      content = function(file) {
        
        WhichClass	<- "7"
        
        df <- all_data()
        
        df$marks_perc <- df$marks / df$max_marks * 100
        
        df$subject <- factor(tolower(df$subject))
        df$test_desc <- factor(tolower(df$test_desc))
        df$name_short <- factor(df$name_short2)
        df$test_occ_no_f <- factor(paste("Occ", df$test_occ, sep=":"))
        
        df <- df[df$class == WhichClass, ]
        
        admission_numbers <- unique(df$adm_no)
        
        n_subjects <- length(unique(levels(df$subject)))
        n_pupils <- length(unique((df$adm_no)))
        
        # delete previous run
        
        unlink("class_plots/*pdf")
        
        files <- NULL
        
        for (i in 1 : 2 n_pupils) {
          xdf <- df[df$adm_no == admission_numbers[i], ]
          for(j in 1:n_subjects) {
            my_file_name <- 
              paste0(xdf$name_short[xdf$adm_no==admission_numbers[i]], "_AdmNo_", 	
                     xdf$adm_no[xdf$adm_no==admission_numbers[i]], 
                     "_Class_", xdf$class[xdf$adm_no==admission_numbers[i]], ".pdf")
            
            pdf(file.path("class_plots", my_file_name), width = 15, height = 10)
            
            p1 <- ggplot2::ggplot(xdf, 
                                  ggplot2::aes(x = test_occ_no_f, 
                                               y = marks_perc, 
                                               group = name_short)) +
              ggplot2::geom_line() +
              ggplot2::geom_point() +	
              ggplot2::facet_wrap(subject ~ test_desc) +
              ggplot2::ylab("% Score") +
              ggplot2::xlab("Test Occ") +
              ggplot2::scale_y_continuous(breaks = seq(0, 100, 10), 
                                          limits = c(0, 100)) +
              ggplot2::ggtitle(my_file_name)
            print(p1)
            
            files <- c(my_file_name, files)
            dev.off()
          }
        }
        zip(file, file.path("class_plots", files))
      }
    )
    
  })
}
