# 08 AE Attendances by type same plot

# We start building our new plot based on the "AE_Att_year"
# The data set for all attendances from 2011 up to 2014

library(tidyverse)

# This AE_Att_year was created in "07 AE chart facet wrap by month.R" script
#  in section 2: # 2. Create variable to display year
AE_Att_year
names(AE_Att_year)
table(AE_Att_year$Year)

# 1. Subset data from AE_Att_year to include just 2011-2018 data
# TS Year on year plot comparison

Subset <-c(2011,2012,2013,2014,2015,2016,2017,2018)

Att_full_years  <- AE_Att_year %>% filter(Year %in% Subset)
Att_full_years

check <- Att_full_years %>% distinct(Year)
check

# Rename Att_full_years into AEBYEAR
AEBYEAR <- Att_full_years

rm(list=ls()[!(ls()%in%c('AE_Att_year','Att_full_years', 'AEBYEAR'))])


# 1 Start designing a long data set to have one column 
# for each type of Attendances:
names(AEBYEAR)

# [1] "period"                                         "type_1_departments_major_a_e"                  
# [3] "type_2_departments_single_specialty"            "type_3_departments_other_a_e_minor_injury_unit"
# [5] "total_attendances"                              "Year"                                          
# [7] "Month"                                          "Monthl" 

head(AEBYEAR)

library(tidyverse)

AEBYEAR_sel <- AEBYEAR %>% 
  select(
    period,
    Major_att = type_1_departments_major_a_e ,
    Single_esp_att = type_2_departments_single_specialty,
    Other_att = type_3_departments_other_a_e_minor_injury_unit,
    total_att = total_attendances) 
AEBYEAR_sel

# 1.1 Pivot long the initial data set 
AEBYEAR_long<- AEBYEAR_sel %>% 
                pivot_longer(names_to = "Metrics",
                             cols = 2:ncol(AEBYEAR_sel))
AEBYEAR_long

# 2.1 Display using facet_wrap AE Attendances by Metric one metric on each chart
# facet_wrap() by Metric

names(AEBYEAR_long)
# [1] "period"  "Metrics" "value" 

AEM_FACET_METRIC<- AEBYEAR_long %>%

  select(period,Metrics,value) %>% 
  ggplot(aes(x = period, y = value,group = Metrics, colour = Metrics)) +
  geom_line(size=1,  linetype=1) +

  labs(title = "A&E Attendances in England by Type",
       subtitle ="Attendances by type by year 2011-2018",
       # Change X and Y axis labels
       x = "Period", 
       y = "Type I Attendances") +
  theme_light() +
  facet_wrap(~ Metrics) +
  # Apply format to sub-title
theme(
  plot.subtitle = element_text(
    size =10, colour = "darkorange1", face = "bold")
)

AEM_FACET_METRIC  

ggsave("plots/13_AE_Attendances_facet_wrap.png", width = 6, height = 4) 

# 2.2 Display four AE Attendanves metrics on same chart using colour = Metric
AEM_SINGLE_PLOT <- AEBYEAR_long %>% 
  select(period,Metrics,value) %>% 
  ggplot(aes(x = period, y = value,group = Metrics, colour = Metrics)) +
  geom_line(size=1,  linetype=1) +
  labs(title = "A&E Attendances in England by Type",
       subtitle ="Type 1,2,3 and Total Atendances. 2011-2018",
       # Change X and Y axis labels
       x = "Period", 
       y = "Attendances") +
  theme_light()  +
  
  # Apply format to sub-title
  theme(
  plot.subtitle = element_text(
    size =10, colour = "cornflowerblue", face = "bold")
  )

AEM_SINGLE_PLOT


ggsave("plots/14_AE_Attendances_by_type.png", width = 10, height = 6) 