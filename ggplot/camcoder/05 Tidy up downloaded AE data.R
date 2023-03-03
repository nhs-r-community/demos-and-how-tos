# 05 Tidy up downloaded AE data.R

# 1. Load required packages 
pacman::p_load(readxl,here,dplyr,janitor)

# Check existing files in data project folder

Excel_files_xls <- list.files(path = "./data", pattern = "xls$")
Excel_files_xls

Excel_files_xlsx <- list.files(path = "./data", pattern = "xlsx$")
Excel_files_xlsx

# [1] "AE_England_data.xls" "RTT_TS_data.xls"  

# 2. Import AE Excel data into R
# From file  AE_England_data.xls

# This is an .xls file extension, Excel 97-Excel 2003 Workbook 

# 2.1 Check first how many sheets the AE data has
here()

AE_tabs <- excel_sheets(here("data","AE_England_data.xls"))
AE_tabs

# [1] "Activity"    "Performance" 

# We read in data from Excel using READXL package
# From "readxl" package we use the read_excel function to read in data from Excel file

# Parameters
# sheet = number [Number of sheet to be imported]
# skiep = number [Number of rows from the top of the file to be skipped when importing data into Excel]
# range = "C10:F18" [Range of rows from a specific sheet to be Imported into R]
# na = ""   [How missing values are defined in the input file "-", "#" ]

# To obtain cleansed data from the original file formatting setup, we must skip some rows from the top of the file

# Also we make use of the clean_names() from janitor package to obtain clear variable names


# 2.2 Skip first rows of data containing Notes and file description information in the original .xls file

# We start now importing the data by cleaning out the redundant text rows 
# from the original input .xls file 
#-	We want to import data from the First sheet “Activity”/ Sheet =1 
#-	We also need to skip 17 rows to obtain the right column variable values
#-	We need to bear in mind that the first 4 rows are A&E Attendances and the from row 5 on wards are A&E Admissions


# Skip certain rows of data: 
AE_data<- read_excel(
                     here("data", "AE_England_data.xls"), 
                     sheet = 1, skip =17) %>% 
                     clean_names()
AE_data

names(AE_data)

# Example: How to select rows of data 
# Import only "Type 1 Departments- Major A&E" A&E Attendances data into R

AE_data_Type1_ATT <- read_excel(here("data","AE_England_data.xls"),
                                sheet = 1,skip =17, range = "C18:D123",na = "")
AE_data_Type1_ATT

# 3. Subset original imported AE_data set to Keep A&E Attendances
# From file  AE_England_data.xls
AE_data_subset<- read_excel(
                      here("data", "AE_England_data.xls"), 
                      sheet = 1, skip =17) %>% 
                      clean_names() %>% 
                      select(
                        "x1",                                                                      
                        "period",                                                                  
                        "type_1_departments_major_a_e",                                            
                        "type_2_departments_single_specialty",                                     
                        "type_3_departments_other_a_e_minor_injury_unit",                          
                        "total_attendances" 
                      )
AE_data_subset

# 4. Rename variables in preparation for creating a ggplot2 plot
# 4.1 First we remove X1 extra variable
AE_data_plot <- AE_data_subset %>% 
                select(-x1)
AE_data_plot

# 4.2 Then we rename remaining variables to shorten their names

# SUbset Attendances data to produce our first plot
AE_plot_prep <- AE_data_plot %>% 
                select(
                  period,
                  type_1_Major_att = type_1_departments_major_a_e,
                  type_2_Single_esp_att = type_2_departments_single_specialty,
                  type_3_other_att = type_3_departments_other_a_e_minor_injury_unit,
                  total_att = total_attendances
                  
                ) 
AE_plot_prep

# Save AE Attendances variables in a new data set
AEATT_plot <- AE_plot_prep