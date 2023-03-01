# 07 AE Attendances facet_wrap

# This script will provide a matrix of plots by month

library(tidyverse)
library(gridExtra)

# We can clean our workspace to keep just a set of variables
rm(list=ls()[!(ls()%in%c('AE_data_plot'))])

# Kepep just attendances from the original data set

# Looking into the previous R Script: 
# 05 Tidy up downloaded AE data.R

# 3. Subset original imported AE_data set to Keep A&E Attendances
# From file  AE_England_data.xls

# Import only "Type 1 Departments- Major A&E" A&E Attendances data into R

# AE_data_subset<- read_excel(
#  here("data", "AE_England_data.xls"), 
#  sheet = 1, skip =17) %>% 
#  clean_names() %>% 
#  select(
#    "x1",                                                                      
#    "period",                                                                  
#    "type_1_departments_major_a_e",                                            
#    "type_2_departments_single_specialty",                                     
#    "type_3_departments_other_a_e_minor_injury_unit",                          
#    "total_attendances" 
#  )
# AE_data_subset

# AE_plot_prep <- AE_data_plot %>% 
#   select(
#     period,
#    type_1_Major_att = type_1_departments_major_a_e,
#     type_2_Single_esp_att = type_2_departments_single_specialty,
#    type_3_other_att = type_3_departments_other_a_e_minor_injury_unit,
#    total_att = total_attendances
#  ) 
# AE_plot_prep

# 1. Rename data set with sensible name

AE_Attendances <- AE_data_plot

names(AE_Attendances)

# 2. Create variable to display year
library(tidyverse)


AE_Att_year <- AE_Attendances %>% 
               mutate(
                      Year = format(period, format = "%Y"),
                      Month = format(period, format = "%m"),
                      Monthl = months(as.Date(period))
                                      )
                      
AE_Att_year

## 3. Rename main variables

AE_Att_monthp <- AE_Att_year %>% 
select(
    period,
      type_1_Major_att = type_1_departments_major_a_e,
       type_2_Single_esp_att = type_2_departments_single_specialty,
      type_3_other_att = type_3_departments_other_a_e_minor_injury_unit,
      total_att = total_attendances,
    Monthl
    ) 

AE_Att_monthp

## 4. Find out which years have  full set of months of data 
# month.abb[month]

# Extract Month and Year from period date variable 

Att_Full_year <- AE_Att_monthp %>% 
                        mutate(
                                  Year = format(period, format = "%Y"),
                                  Month = format(period, format = "%b")
                                 )
Att_Full_year

# Turn month into a FACTOR to get the right month order in plots
Att_Full_year_f <-  Att_Full_year %>% mutate(Monthf = factor(Month, levels = month.abb))


# Check number of  rows per year
Records_year <-Att_Full_year_f %>% 
                      select(Year) %>% 
                      group_by(Year) %>% 
                      count()
Records_year

# 1 2010      5
# 2 2011     12
# 3 2012     12
# 4 2013     12
# 5 2014     12
# 6 2015     12
# 7 2016     12
# 8 2017     12
# 9 2018     12
# 10 2019      4

# 5. Subset then just for complete years (2011,2012,2013,2014,2015,2016,2017,2018)

Subset <-c(2011,2012,2013,2014,2015,2016,2017,2018)

Att_full_years  <- Att_Full_year_f %>% filter(Year %in% Subset)
Att_full_years

check <- Att_full_years %>% distinct(Year)
check

head(Att_full_years)

# 6. CREATE FACET_WRAP plots by month for each year
# facet_wrap(~Monthl, labeller = label_wrap_gen(width = 20))

# Subset variables for Facet_plot

Att_facet <- Att_full_years %>% select(period,type_1_Major_att,Year,Monthf)
Att_facet

# Minimal facet_wrap to work with my data
# Split facets by Year (group = year)
# ggplot(aes (x = Month, y = type_1_Major_att, group = year))

# # Turn month into a FACTOR to get the right month order in plots

AE_att_wrap_year   <- Att_facet %>% 
                      select(type_1_Major_att,Year,Monthf) %>% 
                      ggplot(aes(x = Monthf, y = type_1_Major_att,group = Year)) +
                      geom_line(color="#0072CE", size=1,  linetype=1) +
                      facet_wrap(~ Year)
AE_att_wrap_year   

# Add title and subtitle to the above wrapped plot
AE_att_wrap_year   <- Att_facet %>% 
  select(type_1_Major_att,Year,Monthf) %>% 
  ggplot(aes(x = Monthf, y = type_1_Major_att,group = Year)) +
  geom_line(color="#0072CE", size=1,  linetype=1) +
  facet_wrap(~ Year) +
  labs(title = "A&E Attendances in England: Type 1 Departments - Major A&E",
       subtitle ="Type I attendances by month by year. 2011-2018",
       # Change X and Y axis labels
       x = "Period", 
       y = "Type I Attendances") +
  theme_light() 
AE_att_wrap_year  

ggsave("plots/11_AE_Attendances_facet_wrap.png", width = 6, height = 4) 

# Apply format to title and subtitles in facet_wrap plots


AE_att_wrap_formatted   <- Att_facet %>% 
  select(type_1_Major_att,Year,Monthf) %>% 
  ggplot(aes(x = Monthf, y = type_1_Major_att,group = Year)) +
  geom_line(color="#0072CE", size=1,  linetype=1) +
  facet_wrap(~ Year) +
  labs(title = "A&E Attendances in England: Type 1 Departments - Major A&E",
       subtitle ="Type I attendances by month by year. 2011-2018",
       # Change X and Y axis labels
       x = "Period", 
       y = "Type I Attendances") +
  theme_light()  +

theme(
  axis.ticks = element_blank(),
  # A value of “plot” means the titles/caption are aligned to the entire plot
  # Apply format to title plot
  plot.title.position = "plot", 
  plot.title = element_text(margin = margin (b=10), colour = "dodgerblue2", face = "bold"), # Skyblue1 colour
  # Apply format to sub-title
  plot.subtitle = element_text(
    size =8, colour = "deepskyblue2", face = "bold")
) 

AE_att_wrap_formatted 

ggsave("plots/12_AE_Attendances_facet_wrap.png", width = 6, height = 4) 


