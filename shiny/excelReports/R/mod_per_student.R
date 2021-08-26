#' per_student UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_per_student_ui <- function(id){
  ns <- NS(id)
  tagList(
    
    fluidPage(
      
      checkboxInput(ns("all_graphs"), "Return all students?"),
      
      conditionalPanel(
        condition = "input.all_graphs==0", ns = ns,
        
        uiOutput(ns("which_studentUI"))
      ),
      
      downloadButton(ns("download_graphs")),
    )
  )
}

#' per_student Server Functions
#'
#' @noRd 
mod_per_student_server <- function(id, all_data){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    output$which_studentUI <- renderUI({
      
      choices = unique(all_data()$adm_no)
      
      selectInput("which_student", "Select student",
                  choices = choices)
    })
    
    output$download_graphs <- downloadHandler(
      
      filename = "graphs.zip",
      content = function(file) {
        
        df <- all_data()
        
        df$marks_perc <- df$marks/df$max_marks*100
        
        df$subject <- factor(tolower(df$subject))
        df$test_desc <- factor(tolower(df$test_desc))
        df$name_short <- factor(df$name_short2)
        df$test_occ_no_f <- factor(paste("Occ", df$test_occ, sep=":"))
        
        
        if(input$all_graphs) {
          
          n <- length(unique(all_data()$adm_no))
          admission_numbers <- sort(unique(all_data()$adm_no))
          
        } else {

          n <- 1
          admission_numbers <- input$which_student
        }
        
        ###
        files <- NULL
        
        myDir = tempdir()
        
        for(i in 1:n) {
          my_file_name <- paste(df$name_short[df$adm_no == admission_numbers[i]], 
                                "AdmNo", df$adm_no[df$adm_no == admission_numbers[i]], 
                                "Class", df$class[df$adm_no == admission_numbers[i]],
                                sep = "-")
          adf <- df %>% 
            dplyr::filter (adm_no==admission_numbers[i])
          pdf (paste(my_file_name, "pdf", sep='.'), width=15, height=10)
          p1 <- ggplot(df[df$class==unique(adf$class),], aes(x=test_occ_no_f, y=marks_perc)) +
            geom_boxplot()+
            geom_point(data=adf, 
                       aes(x=test_occ_no_f, y=marks_perc,group=test_desc), 
                       col='red')+	
            facet_wrap(subject~test_desc)+
            ylab("% Score")+
            xlab("Test Occ")+
            scale_y_continuous(breaks = seq(0, 100, 10), limits=c(0,100))+
            ggtitle(my_file_name)
          print(p1)
          
          files <- c(my_file_name, files)
          dev.off()
        }
        zip(file, file.path(myDir, files), flags = "-j")
      }
    )
  })
}
