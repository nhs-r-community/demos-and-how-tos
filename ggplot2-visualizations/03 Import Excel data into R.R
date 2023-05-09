# 03 Import Excel data into R.R 

# Load required packages at once (readxl,here,dplyr,janitor) 

library(readxl)
library(here)
library(dplyr)
library(janitor)


# Added "where_am_i" across all instances an absolute path is required 

where_am_i <- here::here()

excel_file <- list.files (paste0(where_am_i,"/ggplot2-visualizations/data"),pattern = "xlsx$")
excel_file


# [1] "RTT_TS_data.xlsx"
excel_tabs <- excel_sheets(paste0(where_am_i,"/ggplot2-visualizations/data/RTT_TS_data.xlsx"))
excel_tabs

# We read in data from Excel using READXL package
# From "readxl" package we use the read_excel function to read in data from Excel file

# Parameters
# sheet = number [Number of sheet to be imported]
# skip = number [Number of rows from the top of the file to be skipped when importing data into Excel]
# range = "C10:F18" [Range of rows from a specific sheet to be Imported into R]
# na = ""   [How missing values are defined in the input file "-", "#" ]

# Two examples
# Skip certain rows of data: 
# Myocardial_infarction <- read_excel(
#              here("data", "CCG_1.17_I01968_D.xlsx"), 
#              sheet = 3, skip =13) %>% 
#              clean_names()
# How to select rows of data 
#Tab10202in <- read_excel(here("Input_files",DataA),sheet = 1,range = "C10:F18",skip = 1,na = "")

### Importing our main RTT data

# THere are 9 Rows of data in the Excel file we downloaded from the URL
# File name "RTT_TS_data.xlsx"
# skip = 9

# Let's try to import it just by specifying the number of rows to ommit



# 1-3 First get the File name we want to import 
excel_file <- list.files (paste0(where_am_i,"/ggplot2-visualizations/data"),pattern = "xlsx$")
excel_file
# [1] "RTT_TS_data.xlsx"

# 2-3 Then get the Tab names to choose which one to import (with multi tab files)
excel_tabs <- excel_sheets(paste0(where_am_i,"/ggplot2-visualizations/data/RTT_TS_data.xlsx"))
excel_tabs
#[1] "Full Time Series"

# Start applying all these parameters to our function
RTT_Data <- read_excel(paste0(where_am_i,"/ggplot2-visualizations/data/RTT_TS_data.xlsx"),sheet = "Full Time Series")
RTT_Data

# 1. Add argument to skip first 10 rows of data
# So this will get us the right Table headings
RTT_Data <- read_excel(paste0(where_am_i,"/ggplot2-visualizations/data/RTT_TS_data.xlsx"),sheet = "Full Time Series",
                       skip = 10)
RTT_Data

names(RTT_Data)

# 2.Add na argument to get rid of missing values  na = "-"  
# In this particular example, missing values are defined by "-" character
# Try to adjust the spaces for the missing values
RTT_Data <- read_excel(paste0(where_am_i,"/ggplot2-visualizations/data/RTT_TS_data.xlsx"),sheet = "Full Time Series",
                       skip = 10 , na = "-")

RTT_Data

# 3. Use Janitor package to get clear names using "clear_names()"function
# This file worked fine and solves:
# a. Importing null values from original file defined as "-"
# b. Cleaning original variable names using clean_names() function from Janitor package
RTT_Data <- read_excel(paste0(where_am_i,"/ggplot2-visualizations/data/RTT_TS_data.xlsx"),sheet = "Full Time Series",
                       skip = 10 , na = "-") %>% 
  clean_names()

RTT_Data
# Try to capture that missing value better
Variable_names <- names(RTT_Data)
Variable_names

# 4. As we can see we have plenty of variables, we will start by subsetting them and keeping just TWO
# x2 that will correspond to "Date" and "Total waiting(Mil)" That corresponds to Total figure of incomplete pathways or waiting list

RTT_data_sub <- RTT_Data %>% 
  select(x2,total_waiting_mil)
RTT_data_sub    

# Now rename the variable appropriately
RTT_data <- RTT_data_sub %>% select(Date = x2, Total_waiting = total_waiting_mil)
RTT_data

# We can also remote null values using drop_na() function rom tidyr package
# From DPLYR we can use na.omit() function
RTT_data <- RTT_data_sub %>% 
  select(Date = x2, Total_waiting_M = total_waiting_mil) %>% 
  na.omit()
RTT_data

# Check how the data looks like
install.packages("tidyverse",dependencies = TRUE)
library(tidyverse)

RTT_data_plot <- RTT_data %>% 
  ggplot(X = Date, Y = Total_waiting_M, aes()) + 
  geom_line()