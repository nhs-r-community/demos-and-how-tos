#Example of linking two plotly outputs

# Jon Minton

# I'm going to start with the example in section 17.1 of Sievert's book, then adapt to two plots
# https://plotly-r.com/linking-views-with-shiny.html
library(shiny)
library(plotly)


ui <- fluidPage(
  selectizeInput(
    inputId = "cities",
    label = "Select a city",
    choices = unique(txhousing$city),
    selected = "Abilene",
    multiple = TRUE
  ),
  plotlyOutput(outputId = "main_plot"),
  plotlyOutput(outputId = "sub_plot"),
  hr(),
  verbatimTextOutput("hover"),
  verbatimTextOutput("click")
)

server <- function(input, output, ...) {
  make_main_plot <- reactive({
    plot_ly(
      txhousing, x = ~date, y = ~median,
      customdata = ~city, # This allows the city corresponding to the curveNumber to be passed
            source = "main" # Added this so can distinguish from clicks/interactions with subplot
    ) %>%
      filter(city %in% input$cities) %>%
      group_by(city) %>%
      add_lines() %>%
      layout(title = "Main plot")
  })

  output$main_plot <- renderPlotly({
    p <- make_main_plot()

    p %>% event_register("plotly_selecting")
  })

  output$hover <- renderPrint({
    d <- event_data("plotly_hover", source = "main")
    if (is.null(d)) "Hover events appear here (unhover to clear)" else d
  })

  output$click <- renderPrint({
    d <- event_data("plotly_click", source = "main")
    if (is.null(d)) "Click events appear here (double-click to clear)" else d
  })

  output$sub_plot <- renderPlotly({
    d <- event_data("plotly_click", source = "main")
    req(d)

    this_time <- d$x
    this_city <- d$customdata
    this_year <- floor(this_time)
    this_month <- ((this_time - this_year) * 12) %>% round(0)

    p_time_varying <-
      txhousing %>%
        filter(
          city == this_city
        ) %>%
        plot_ly(x = ~date, y = ~median) %>%
        add_lines() %>%
        add_markers(
          data =  txhousing %>%
                  filter(
                    city == this_city,
                    year == this_year,
                    month == this_month
                  )
        ) %>%
        layout(margin = list(r = 30), # set right margin
               showlegend = FALSE,
               title = "Time varying subplot"
               )

    p_place_varying <-
      txhousing %>%
        filter(
          year == this_year,
          month == this_month
        ) %>%
      mutate(
        selected_city = city == this_city
      ) %>%
      plot_ly(
        x = ~median,
        y = ~forcats::fct_reorder(city, median),
        symbol = ~selected_city,

        color = ~selected_city,
        colors = c(`FALSE` = 'black', `TRUE` = 'red')
        ) %>%
      add_markers() %>%
      layout(margin = list(l = 30), # set left margin
             yaxis = list(side = "right"),
             showlegend = FALSE,
             title = "Place varying subplot")

    subplot(
      p_time_varying, p_place_varying, nrows = 1
    ) %>%
      layout(
        margin = list(pad = 25),
        title = "Subplot",
        annotations = list(
          list(
            x = 0.20, y = 1.0,
            xref = "paper", yref = "paper",
            xanchor = "centre",
            yanchor = "bottom",
            showarrow = FALSE,
            text = "Time varying"
          ),
          list(
            x = 0.80, y = 1.0,
            xref = "paper", yref = "paper",
            xanchor = "centre",
            yanchor = "bottom",
            showarrow = FALSE,
            text = "Place varying"
          )
        )
      ) %>%
      config(displayModeBar = FALSE)
  })
}

shinyApp(ui, server)
