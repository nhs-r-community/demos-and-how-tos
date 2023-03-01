#09 AE Attendances_by_year_geom_smooth

library(tidyverse)

# Load England AE Attendances
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

AE_Attendances <- AE_data_plot

AE_Att_year <- AE_Attendances %>% 
  mutate(
    Year = format(period, format = "%Y"),
    Month = format(period, format = "%m"),
    Monthl = months(as.Date(period))
  )

AE_Att_year

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

# Subset variables for Facet_plot
Subset <-c(2011,2012,2013,2014,2015,2016,2017,2018)

Att_full_years  <- Att_Full_year_f %>% filter(Year %in% Subset)
Att_full_years

Att_facet <- Att_full_years %>% select(period,type_1_Major_att,Year,Monthf)
Att_facet


## Create new data set [AEBYEAR_sel] for further charts 
# From this data set: Att_Full_year_f

# Output: AEBYEAR_sel
# Input: Att_Full_year_f

names(Att_Full_year_f)
AEBYEAR_sel <- Att_Full_year_f %>% 
               select(
                 period, 
                  Major_att = type_1_Major_att,
                  Single_esp_att = type_2_Single_esp_att,
                 Other_att  = type_3_other_att, 
                 total_att, 
                 Monthf,
                 Year)
AEBYEAR_sel

# > MAJORSING
# A tibble: 96 × 4
#period              Major_att Single_esp_att Other_att
#<dttm>                  <dbl>          <dbl>     <dbl>
#  1 2011-01-01 00:00:00  1133881.         51585.   542331.
#2 2011-02-01 00:00:00  1053707.         51249.   494408.
#3 2011-03-01 00:00:00  1225222.         57900.   580319.
#4 2011-04-01 00:00:00  1197213.         54042.   593120.



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


ggsave("plots/15_AE_Attendances_facet_wrap.png", width = 6, height = 4) 



# We can add colour to these facet plots by metric
# Display each line on a different colour for each year
# 
AE_att_wrap_colour   <- Att_facet %>% 
  select(type_1_Major_att,Year,Monthf) %>% 
  ggplot(aes(x = Monthf, y = type_1_Major_att,group = Year,colour = Year)) +
  # Line colour defined by Metric variable
  geom_line(size=1,  linetype=1) +
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

AE_att_wrap_colour 

ggsave("plots/16_AE_Attendances_facet_wrap_colour.png", width = 6, height = 4) 


# Display each line on a different colour for each year
# Add also a geom_smooth(span = 0.1,se = TRUE, size = 0.8) to the plot

AE_att_wrapy_smooth<- Att_facet %>% 
                          select(type_1_Major_att,Year,Monthf) %>% 
                          ggplot(aes(x = Monthf, y = type_1_Major_att,group = Year)) +
                          geom_line(color="#0072CE", size=1,  linetype=1) +
                          facet_wrap(~ Year) +
                          geom_smooth(se = TRUE, colour ="darkorchid1")

AE_att_wrapy_smooth  

ggsave("plots/17_AE_Attendances_facet_wrap_geom.png", width = 6, height = 4) 


AE_att_wrap_colouryear   <- Att_facet %>% 
                          select(type_1_Major_att,Year,Monthf) %>% 
                          ggplot(aes(x = Monthf, y = type_1_Major_att,group = Year,colour = Year)) +
                          # Line colour defined by Metric variable
                          geom_line(size=1,  linetype=1) +
                          facet_wrap(~ Year) +
                          # Include smooth line colour darkorchid
                          geom_smooth(se = TRUE, colour ="darkorchid1") +
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
                              size =10, colour = "chartreuse4", face = "bold")
                          ) 

AE_att_wrap_colouryear 

ggsave("plots/18_AE_Attendances_facet_wrap_colour.png", width = 6, height = 4) 
