library(shiny)
library(palmerpenguins)
library(plotly)

ui <- fluidPage(

   shinyjs::useShinyjs(),

   # Application title
   titlePanel("Example app"),

   plotlyOutput("penguinPlot"),
   verbatimTextOutput("textInfo")


)

server <- function(input, output) {

   output$penguinPlot <- renderPlotly({

     p <- penguins %>%
       plot_ly(x=~body_mass_g,
               y=~bill_length_mm,
               frame=~year,
               source="mainplot") %>%
       add_trace() %>%
       event_register(event="plotly_click")

     return(p)

   })

   output$textInfo <- renderText({
     d <- event_data("plotly_click", source="mainplot")
     if (is.null(d)) {
       "Click on a point for info"
     } else {
       # Get info on current year from html using javascript
       shinyjs::runjs("
            // There are 4 elements with slider-label as class name, the first one is
            // the text on the top RHS of the slider, the other 3 are the slider options
            let text = document.getElementsByClassName('slider-label')[0].innerHTML;
            // get year out of inner text
            text = text.replace('year: ', '');
            // Sends text to input$year_shiny
            Shiny.setInputValue('sliderYear', text);
            ")
       paste0("Information from most recent click:", "\n",
              "\n",
              "Year: ", input$sliderYear, "\n",
              "Body mass: ", d$x, "g", "\n",
              "Bill length: ", d$y, "mm")
     }
   })
}

# Run the application
shinyApp(ui = ui, server = server)

