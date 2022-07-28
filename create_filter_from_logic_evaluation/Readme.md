
This script shows how to convert logical values (TRUE/FALSE) into a string which can then be evaluated as an expression using str2expression()

But why would you want to do this?

Most data extraction in the NHS reuses the same code chunks and is often repeated to answer different questions. It seemed sensible to replace the copy and paste process with a definition of a search strategy and then logically interpret that. 

e.g search for men  over 18 years of age with severe pain attending the ED between x & y who have a raised creatinine

Defining variables such as:  

```
men <- TRUE
min_age <- 18
max_age <- 100
presenting_complaint <- c(
'Back Pain'
)
min_date <- '2022-06-01 23:59:59'#'YYYY-MM-DD hh:mm:ss'
max_date <- '2022-06-05 23:59:59'#'YYYY-MM-DD hh:mm:ss'

```
Gets you most of the way to being able to drop these variables into a search strategy and just change a config file to define the search each time. 

However defining a reproducible method for evaluating a clinical event mathematically is a little more complex.

The approach showin in the [filter_creation](filter_creation.R) script shows how the following variables:  

```
ce1_use_filter <- TRUE
ce1_event_name <- 'Troponin Serum'
# This option can also be used to identify pts without this event
ce1_occured <- TRUE 
ce1_result_evaluation <- TRUE

equal_to_ce1_result <- FALSE
greater_than_ce1_result <- FALSE
greater_than_or_equal_to_ce1_result <- TRUE
less_than_ce1_result <- FALSE
less_than_or_equal_to_ce1_result <- FALSE

ce1_result <- "14"
```
Can be used to create the expression 

```
ce1_filter <- "EVENT == Troponin Serum & EVENT_RESULT_TXT >=14"
```

Which can then be evaluated locally using:  

```
dataframe %>% 
   filter(eval(str2expression(ce1_filter)))
```

or on a remote database using

```
dataframe %>% 
   filter(!!parse_expr(ce1_filter))
```

The script does this using penguin data. 
