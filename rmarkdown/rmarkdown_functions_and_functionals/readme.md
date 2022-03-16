===
author: "Jon Minton"
title: "Procedurally generating Rmarkdown reports using functions and functional programming"
date: "6 March 2022"

===

# Introduction

The example here contains a slight enhancement on existing examples for procedurally generating Rmarkdown reports. 

- The R script
    - Loads the data required at the outset so it does not have to be loaded each time the Rmarkdown template file is run
    - Turns the call to the .rmd template file into a function based on the pattern used in [the rmarkdown cookbook](https://bookdown.org/yihui/rmarkdown-cookbook/parameterized-reports.html)
    - Runs the function which calls the .rmd template three ways:
        - Once, for a single parameter combination
        - For all parameter combinations, using a for loop
        - For all parameter combinations, using the `purrr::walk2` function instead of a for loop 
- The rmd template:
    - Adjusts the title of the report to be specific to the country being profiled
    - Presents some very simple in-line summary information for the country of interest
    - Shows data for the country of interest with a bold red line, and other countries/populations with lighter grey lines for reference
    
    
# Usage

- Create a subdirectory `outputs`
- Make sure dependencies are loaded
- Run the .R file

You may need to clear the contents of the `outputs` folder between runs

# Data and data source

Life expectancies at birth, from lifetables extracted and aggregated from the [Human Mortality Database](https://www.mortality.org/), extracted using the [HMDHFDplus R package](https://cran.r-project.org/web/packages/HMDHFDplus/index.html). 

