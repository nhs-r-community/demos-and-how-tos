library(tidyverse)
lapply(list.files("./R", full.names = TRUE), source)

df_some_data <- get_data()

df_wrangled_data <- df_some_data %>% mutate(c=a * 2)

write_csv2(df_wrangled_data, 'output_data/wrangled_data.csv')
