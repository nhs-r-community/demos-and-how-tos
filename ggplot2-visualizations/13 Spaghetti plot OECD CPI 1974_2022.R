# CPI Consumer price index

# OECD Indicators
# Inflation (CPI)
# Inflation measured by consumer price index (CPI) is defined as the change in the prices of a basket of goods and services that are typically purchased by specific groups of households
# Downloaded data from
# https://data.oecd.org/price/inflation-cpi.htm

OECD_Inflation_CPI.csv

# 1. Load required packages
pacman::p_load(readxl,here,dplyr,janitor)

OECD_files <- list.files(path = "./data/OECD", pattern = "csv$")
OECD_files


# [1] "OECD_Inflation_CPI.csv"

# 2. Read in data
library(here)
library(janitor)
library(tidyverse)

OECD_DATA  <-read.table(here("data","OECD", "OECD_CPI_selected_countries.csv"),
                            header =TRUE, sep =',',stringsAsFactors =TRUE) %>% 
                        clean_names()
OECD_DATA

# 3. Subset data to include just 
names(OECD_DATA)

[1] "location"   "indicator"  "subject"    "measure"    "frequency"  "time"       "value"     
[8] "flag_codes"

location_freq <- OECD_DATA %>% 
                    select(location) %>%
                    group_by(location) %>% 
                    summarise(freq = n()) %>% 
                    arrange(freq)

location_freq

min(OECD_DATA$time)

# Subset data just for these countries (Canada (CAN), France(FRA),G20 (G-20), Germany (DEU), 
# Italy (ITA) , Japan (JPN), United Kingdom (GBR), United states (USA), Australia (AUS) . 
Subset <-c("CAN","FRA","G-20","DEU","ITA","JPN","GBR","USA","AUS")

OECD_subset  <- OECD_DATA %>% filter(location %in% Subset)
OECD_subset
  
Min_period <- min(OECD_subset$time)
Min_period
# [1] 1974
Max_period <- max(OECD_subset$time)
Max_period
# [1] 2022
head(OECD_subset)

# New data set
# Variables 

OECD_plot <- OECD_subset

names(OECD_plot)
head(OECD_plot)
[1] "location"   "indicator"  "subject"    "measure"    "frequency"  "time"       "value"     
[8] "flag_codes"

OECD_plot %>%
            ggplot( aes(x=time, y=value, group=location, fill=location)) +
            geom_area() +
  scale_colour_viridis_d(option = "plasma") +
            theme(legend.position="none") +
            ggtitle("Inflation, consumer price index (CPI) selected countries. 1974-2022") +
            theme_minimal() +
            theme(
              legend.position="none",
              panel.spacing = unit(0.1, "lines"),
              strip.text.x = element_text(size = 8),
              plot.title = element_text(size=14)
            ) +
            facet_wrap(~location)
OECD_plot


ggsave("01 Consumer price index 1974-2022.png", width = 10, height = 6) 

# Turn the above plot into a spaghetti plot

tmp <- OECD_plot %>%
  mutate(location2=location)

  
tmp %>%
  ggplot( aes(x=time, y=value)) +
  geom_line( data=tmp %>% dplyr::select(-location), aes(group=location2), color="grey", linewidth=0.5, alpha=0.5) +
  geom_line( aes(color=location), color="#69b3a2", linewidth=1.2 )+
  scale_colour_viridis_d(option = "plasma") +
  theme_minimal() +
  theme(
    legend.position="none",
    plot.title = element_text(size=14),
    panel.grid = element_blank()
  ) +
  ggtitle("A spaghetti chart of consumer price index (CPI) selected countries. 1974-2022") +
  facet_wrap(~location)

ggsave("02 Spaguetti chart inflation selected countries.png", width = 10, height = 6) 

