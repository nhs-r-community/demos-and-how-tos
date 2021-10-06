
ui <- fluidPage(
  
  # Application title
  titlePanel("Dynamic tag list"),
  
  sidebarLayout(
    sidebarPanel(
      checkboxInput("show_tab", "Show the optional tab?")
    ),
    
    mainPanel(
      uiOutput("main_panelUI")
    )
  )
)

server <- function(input, output) {
  
  output$main_panelUI <- renderUI({
    
    ui_list <- list(tabPanel("Panel one", h2("Hello!")))
    
    if(input$show_tab){
      
      ui_list <- c(ui_list, list(tabPanel("Panel two", h2("Peekaboo!"))))
    }
    
    do.call(tabsetPanel, ui_list)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
