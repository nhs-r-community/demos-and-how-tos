--- 
title: "Simple grand tour example"
author: "Jon Minton"
date: "8 September 2022"
---

# Introduction

The code example here shows how to produce something like a Grand Tour of a series of data by linking two `plotlyOutput` objects. 

Initially, a main plot appears, for which multiple selections can be supplied. Each of these selections produces a new line trace, showing how a value changes for a different place. These traces can quickly become overwhelming.

When the user clicks on a point on any of the series in the main graph, two subplots are produced below the mainplot. 
One of these subplots shows how the place selected, for the period selected, compares with other places in the same period. (I.e. a dotplot)
The other subplot shows how the value for the place selected changed over time, highlighting the year selected as a point on top of the polyline for the place selected. 

The app includes text outputs to show that both hover-over and click-on events are passed from the main plot to elsewhere in the shiny server. 

# Methods demonstrated

The shiny app shows how plotly's `event_register` and `event_data` functions can be used to allow user interactions with a plotly canvas can be passed between parts of the server in the shiny app. 
This is what allows the selected data, on click, to be passed from the main figure to the subfigure logic. 

The example also shows how plotly objects can be given a source attribute, allowing `event_data` to listen only to specific plotly plots, rather than any plotly plot. 