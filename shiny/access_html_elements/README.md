# Accessing HTML elements from shiny 

Sometimes you want to be able to use information from HTML elements which you can't get at using normal shiny ways.

In this example, we have a simple app with an animated plotly plot which displays a scatter plot for each of three years.

When clicking on a point in the plot we want to display data on the x and y values, but also on the current year. The x and y values can be obtained from plotly directly by registering the event of clicking on the point using `event_register()` and then using the `event_data()` object to get this information. However, the current year (given by the frame value) is not available.

We can access the current year directly from the HTML, however, as it is displayed on the slider. This is done using a JavaScript snippet. 

## What is going on in the JavaScript

This is the JavScript snippet:

```js
// There are 4 elements with slider-label as class name, the first one is
// the text on the top RHS of the slider, the other 3 are the slider options
let text = document.getElementsByClassName('slider-label')[0].innerHTML;
// get year out of inner text
text = text.replace('year: ', '');
// Sends text to input$year_shiny
Shiny.setInputValue('sliderYear', text);
```

- The first line finds all the HTML elements with class "slider-label". There are four of these: the first is the text on the top right hand side of the slider; the other three are the slider options below the slider. The inner HTML of the first one is assigned to a new local variable `text`. The inner HTML will be e.g. "year: 2001"

- The second line gets just the year itself out of this text

- The third line assigns this to `input$sliderYear`, which can then be accessed from shiny


## Important things to note

- We must include `shinyjs::useShinyjs()` in the ui in order for `shinyjs::runjs()` to work

