# with thanks to this answer https://stackoverflow.com/a/36062742/486245

library(shiny)
library(shinydashboard)

dbHeader <- dashboardHeader(
  tags$li(class = "dropdown",
          tags$a(href="https://github.com/nhs-r-community/demos-and-how-tos", target="_blank",
                 tags$img(height="20", alt="GitHub Logomark",
                          src="https://cdn.icon-icons.com/icons2/2368/PNG/512/github_logo_icon_143772.png")
          )
  )
)

sidebar <- dashboardSidebar()

body <- dashboardBody()

ui <- dashboardPage(
  dbHeader,
  sidebar,
  body
)

server = function(input, output) { }

shinyApp(ui, server)