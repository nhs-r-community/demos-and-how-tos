library(DT)
library(palmerpenguins)
library(tidyverse)

ui <- fluidPage(
    
    # Application title
    titlePanel("Web scraping results"),
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            actionButton("refresh_data", "Press to refresh")
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            DT::DTOutput("table"),
            plotOutput("graph")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    reactive_data <- reactive({
        
        # call the reactive input here
        
        input$refresh_data
        
        # put web scraping stuff in here and finish with a dataframe
        # I will sample palmerpenguins to illusrate
        
        penguins %>% 
            sample_frac(.5)
    })
    
    output$table <- renderDT({
        
        # as long as the above function returns a dataframe you can just
        # call it straight from here
        
        reactive_data() %>% 
            group_by(species) %>%
            summarise(bill_length = mean(bill_length_mm, na.rm = TRUE))
    })
    
    output$graph <- renderPlot({
        
        # again if reactive returns dataframe you can plot here
        
        reactive_data() %>% 
            ggplot(aes(x = bill_length_mm, y = body_mass_g)) + 
            geom_point()
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
