suppressPackageStartupMessages(library(rio))
suppressPackageStartupMessages(library(readxl))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(purrr))
suppressPackageStartupMessages(library(data.table))


files <- dir(pattern = "*.xlsx")  # in case other file types are in folder

# base R f
method_lapply <- lapply(files, read_excel)
method_lapply <- do.call(rbind, Map(data.frame, method_lapply))


# purrr, using set_names to identify each source workbook

method_purrr <- files %>% 
  set_names() %>% 
  map_dfr(read_excel, sheet = "Manchester",.id = "source_wb")


# for loop and data.table 

filecount <- as.numeric(length(files))  
temp_list <- list()

for (i in seq_along(files)) {
  filename <- files[i] 
  df <- read_excel(path = filename, sheet = "Manchester")
  df$source_wb <- filename
  temp_list[[i]] <- df
  rm(df)
  method_datatable <- data.table::rbindlist(temp_list, fill = TRUE) 
} 
rm(temp_list);rm(filecount);rm(filename);rm(i)


# rio 

method_rio <-  import_list(files, 
                           rbind = TRUE, 
                           rbind_label = "source_wb", #optional
                           sheet = "Manchester") # will read the first sheet by default





#read in and combine all worksheets from one file

path <- "copy2.xlsx"
all_sheets <- path %>%
  readxl::excel_sheets() %>%
  purrr::set_names()

# optional - exclude the Targets sheet which is different to the others
all_sheets <- all_sheets[which(!all_sheets %like% 'Targets')]

# combine the remaining sheets and identify them using .x
all_sheets_df <- map_dfr(all_sheets,
                    ~ read_excel(path, sheet = .x),
                    .id = "sheet")

