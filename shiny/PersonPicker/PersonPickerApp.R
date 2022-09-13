
library(shiny)

ui <- fluidPage(
  h1("Meeting/Workshop Volunteer Picker"),
  HTML("<i>Perfectly fair as the random number don't care!</i>"),
  textInput("name", "Name"),
  actionButton("add", "add"),
  actionButton("del", "delete"),
  textOutput("names"),
  textOutput("num_names"),
  hr(),
  actionButton("vol", "Pick a volunteer!"),
  textOutput("vol_name")
)

server <- function(input, output, session) {
  r <- reactiveValues(names = character(), volunteer = character())

  observeEvent(input$add, {
    r$names <- union(r$names, input$name)
    updateTextInput(session, "name", value = "")
  })

  observeEvent(input$del, {
    r$names <- setdiff(r$names, input$name)
    updateTextInput(session, "name", value = "")
  })

  observeEvent(input$vol, {
    r$volunteer <- sample(r$names, 1)
  })

  output$names <- renderText(paste("Today's attendees are", paste0(r$names, collapse = ", ")))

  output$num_names <- renderText(paste("There are", length(r$names), "attendees"))

  output$vol_name <- renderText({
    req(r$volunteer)
    paste("Today's volunteer to lead is", r$volunteer)
  })
}

shinyApp(ui, server)
