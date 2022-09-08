library(shiny)
library(tidyverse)
dta <- datasets::iris
initial_selection <- names(dta)[sapply(dta, class) == "numeric"]
ui <- fluidPage(
  titlePanel("Make an association plot"),
  sidebarLayout(
    sidebarPanel(
      selectInput("xvar_selection",
                  "Choose variables for x axis:",
                  choices = initial_selection
      ),
      # selectInput("yvar_selection",
      #             "Choose variables for y axis:",
      #             choices = initial_selection
      # ),
      uiOutput("yvar_ui"),
      checkboxInput("mark_species",
                    "Check to use different symbols/colours for each species"
      )
      
    ),
    mainPanel(
      plotOutput("scatterplot")#,
      # verbatimTextOutput("show_remaining_selection")
    )
  )
)
# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # get_selection <- reactive({
  #   dta %>% 
  #     select(input$xvar_selection, input$yvar_selection)
  # })
  
  get_remaining_selection <- reactive({
    xvar <- input$xvar_selection
    
    initial_selection[initial_selection != xvar]
  })
  
  output$scatterplot <- renderPlot({
    req(input$yvar_selection)
    
    gg <- 
      dta %>% 
      ggplot(aes(x = .data[[input$xvar_selection]], y = .data[[input$yvar_selection]])) 
    
    if (input$mark_species) {
      gg <- gg + geom_point(aes(shape = Species, colour = Species)) 
      
    } else {
      gg <- gg + geom_point()
    }
    
    gg
  })
  
  # output$show_remaining_selection <- renderText({
  #   get_remaining_selection()
  # })
  
  output$yvar_ui <- renderUI({
    selectInput("yvar_selection",
                "Choose variables for y axis:",
                choices = get_remaining_selection()
    )
  })
}
# Run the application 
shinyApp(ui = ui, server = server)