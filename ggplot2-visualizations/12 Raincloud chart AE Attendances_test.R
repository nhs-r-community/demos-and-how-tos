# 12 Raincloud chart AE Attendances

# Load required packages at once (readxl,here,dplyr,janitor)
pacman::p_load(readxl,here,tidyverse,janitor)


# Load England AE Attendances
# Import (Type 1, Type 2 and Type 3 AE Attendances)
AE_ATT <- read_excel(here("data","AE_England_data.xls"),
                                sheet = 1,skip =17, range = "C18:G123",na = "") %>% 
clean_names() 

AE_ATT

names(AE_ATT)

# [1] "period"                                        
# [2] "type_1_departments_major_a_e"                  
# [3] "type_2_departments_single_specialty"           
# [4] "type_3_departments_other_a_e_minor_injury_unit"
# [5] "total_attendances"

AE_ATT <- AE_ATT %>% 
                select(
                   Period = period,
                   Major_att = type_1_departments_major_a_e ,
                   Single_spec_att = type_2_departments_single_specialty,
                   Other_att = type_3_departments_other_a_e_minor_injury_unit
              
                )
AE_ATT

# Create variable for year 

AE_ATT <- AE_ATT %>% 
          mutate(
            year = as.numeric(format(Period, "%Y"))
          )
AE_ATT

AE_ATT_arrange <- AE_ATT %>% 
select(Period,year,Major_att,Single_spec_att,Other_att)
AE_ATT_arrange

# Prep.1 Pivot long the initial data set 
AE_ATT_long<- AE_ATT_arrange %>% 
              pivot_longer(names_to = "Metrics",
                           cols = 3:ncol(AE_ATT_arrange))
AE_ATT_long


# Prep.2 Group value by year and Metric
AE_ATT_long_year <-  AE_ATT_long %>% 
                      select(year,Metrics,value) %>% 
                      group_by(year,Metrics) %>% 
                      summarise(Value = sum(value))
AE_ATT_long_year

## Start building raincloud plot


## 1. MAJOR ATTENDANCES RAINCLOUD


# Filter data to account for 2010-2014 years

# 1.1 Create boilerplate chart for value by period split by Metrics

# Include all years in the visualization
AE_ATT_sel_major <- AE_ATT_long %>%  select(year,Metrics,value) 
                               
AE_ATT_sel_major
names(AE_ATT_sel_major)

# Include all years in the visualization
# Subset data for 2010-2014 period
AE_ATT_period <- AE_ATT_long %>%  select(year,Metrics,value) %>% 
                  filter(Metrics == "Major_att" &
                           (year == 2010 | year == 2011 |year == 2012 | year == 2013 )
                         ) %>% 
                  select(year,value)
AE_ATT_period



# 1.2 Add Raincloud visualization

MAJOR_ATT <- ggplot(AE_ATT_sel_major,aes(x = factor(year), y = value,
                              fill = factor(year))) +
  # Include half-violin from {ggdist} package
  # Function: stat_halfeye() from ggdist package 
  ggdist::stat_halfeye(
    adjust = 0.5, 
    justification = -.2, 
    .width = 0,
    point_colour = NA
  ) +
# Function: geom_boxplot() from ggplot package
geom_boxplot(
  width = .12,
  outlier.color = NA,
  alpha = 0.5
  
)
# DOTS chart. Function: stat_dots() from ggdis package
ggdist::stat_dots(
  side = "left", # left orientation
  justification = 1.1, 
  binwidth = .25
  
)  
MAJOR_ATT

# 2. Improve plot layout feel and look
# functions: scale_fill_tq(), theme_tq()
# Improve theme and plot layout
library(tidyquant)


MAJOR_ATT_layout <- ggplot(AE_ATT_sel_major,aes(x = factor(year), y = value,
                                         fill = factor(year))) +
  # Include half-violin from {ggdist} package
  # Function: stat_halfeye() from ggdist package 
  ggdist::stat_halfeye(
    adjust = 0.5, 
    justification = -.2, 
    .width = 0,
    point_colour = NA
  ) +
  # Function: geom_boxplot() from ggplot package
  geom_boxplot(
    width = .12,
    outlier.color = NA,
    alpha = 0.5
    
  ) +
# DOTS chart. Function: stat_dots() from ggdis package
ggdist::stat_dots(
  side = "left", # left orientation
  justification = 1.1, 
  binwidth = .25
  
) +
  # Improve theme and plot layout
  # library(tidyquant)
  scale_fill_tq() +
  theme_tq() +   # Apply theme
  labs (
    title = "Raincloud plot",
    subtitle = "Major A&E Attendances. England 2010-2019",
    x = "Major Attendances",
    y = "Years",
    fill = "Years"
  ) +
  coord_flip() ## Flip coordinates 



MAJOR_ATT_layout





scale_fill_tq() +
  theme_tq() +   # Apply theme
  labs (
    title = "Raincloud plot",
    subtitle = "Major A&E Attendances. England 2010-2019",
    x = "Major Attendances",
    y = "Years",
    fill = "Years"
  ) +
  coord_flip() ## Flip coordinates 

