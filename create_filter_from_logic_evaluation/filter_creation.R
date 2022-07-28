library(palmerpenguins)
library(tidyverse)
 
ce1_use_filter <- TRUE
ce1_event_name <- 'bill_length_mm'
# This option can also be used to identify pts without this event
ce1_occured <- TRUE 
ce1_result_evaluation <- TRUE

equal_to_ce1_result <- FALSE
greater_than_ce1_result <- FALSE
greater_than_or_equal_to_ce1_result <- TRUE
less_than_ce1_result <- FALSE
less_than_or_equal_to_ce1_result <- FALSE

ce1_result <- "30"

math_opperator <- if (equal_to_ce1_result == TRUE) {
  '=='
} else if (greater_than_ce1_result == TRUE) {
  '>'
} else if(greater_than_or_equal_to_ce1_result == TRUE) {
  '>='
} else if (less_than_ce1_result == TRUE) {
  '<'
}else if (less_than_or_equal_to_ce1_result == TRUE) {
  '<='
}

if(ce1_use_filter == TRUE){
  a <- paste0("variable == ","'",ce1_event_name,"'")
  if (ce1_occured==FALSE) {
    a <- paste0('!',a)
  }
  if (ce1_result_evaluation == TRUE) {
    a <- paste0(
      a,
      " & ",
      "measure ",
      math_opperator,
      ce1_result
    )
  }
  ce1_filter <- a
  rm(a)
}
ce1_filter

palmerpenguins::penguins %>% 
# transform the penguins data set to make it more like a database table
  pivot_longer(names_to = 'variable',
               values_to = 'measure',
               cols = c(
                 "bill_length_mm",
                 "bill_depth_mm",
                 "flipper_length_mm",
                 "body_mass_g"
               )) %>% 
  filter(eval(str2expression(ce1_filter))) %>% 
  view()


