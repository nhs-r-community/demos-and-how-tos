library(palmerpenguins)
library(tidyverse)

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Application title
    titlePanel("Reactive example"),
    
    sidebarLayout(
        sidebarPanel(
            selectInput("species",
                        "Select penguin species",
                        choices = c("Adelie", "Chinstrap", "Gentoo")),
            uiOutput("plotSizeUI")
        ),
        
        mainPanel(
            plotOutput("pengPlot")
        )
    )
)

server <- function(input, output) {
    
    penguinData <- reactive({
        
        penguins %>% 
            filter(species == input$species)
    })
    
    output$plotSizeUI <- renderUI({
        
        min_bill_length <- min(penguinData()$bill_length_mm, na.rm = TRUE)
        max_bill_length <- max(penguinData()$bill_length_mm, na.rm = TRUE)
        
        sliderInput("billLength",
                    "Bill length range selector",
                    min = min_bill_length,
                    max = max_bill_length,
                    value = c(min_bill_length, max_bill_length))
    })
    
    output$pengPlot <- renderPlot({
        
        penguinData() %>% 
            ggplot(aes(x = bill_length_mm, y = bill_depth_mm)) +
            scale_x_continuous(
                limits = c(input$billLength[1], input$billLength[2])) + 
            geom_point()
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
