# 02 camcoder
# https://github.com/thebioengineer/camcorder

# install.packages("camcoder",dependencies = TRUE)
# successfully installed from CRAN

# NHS A&E ATTENDANCES STATISTICS:
# 
# https://www.england.nhs.uk/statistics/statistical-work-areas/ae-waiting-times-and-activity/
#
# The Weekly and Monthly A&E Attendances and Emergency Admissions collection collects 
# the total number of attendances in the specified period for all A&E types, including 
# Minor Injury Units and Walk-in Centres, and of these, the number discharged, admitted 
# or transferred within four hours of arrival.

# type_1_departments_major_a_e
# type_2_departments_single_specialty
# type_3_departments_other_a_e_minor_injury_unit

# 0 Load camcoder manually from Packages tab (If the lib command below doesn't work)
install.packages("camcoder")
library(tidyverse)
library(camcorder)


# 1 A&E Data preparation
pacman::p_load(readxl,here,tidyverse,janitor)

list.files("data")

AE_ATT <- read_excel(here("data","AE_England_data.xls"), 
                     sheet = 1, skip = 17, range = "C18:G123", na = "") %>% 
                     clean_names()

AE_ATT <- AE_ATT %>% 
        select(
                Period = period,
                Major_att = type_1_departments_major_a_e ,
                Single_spec_att = type_2_departments_single_specialty,
                Other_att = type_3_departments_other_a_e_minor_injury_unit
        )
AE_ATT

AE_ATTM <- AE_ATT %>% 
            select(Period, Major_att)
AE_ATTM

# 1 Start building the chart
# At this stage we plan the step by step ggplot changes to obtain our final chart with all the aesthetics, 
# forms and themes we require

# NHS colours
# This is the top level palette that reinforces people's association with blue and white
# NHS Dark Blue #003087
# NHS Blue  #005EB8
# NHS Bright Blue #0072CE 

MIN_date <- min(AE_ATTM$Period)
MIN_date
# [1] "2010-08-01 UTC"
MAX_date <- max(AE_ATTM$Period)
MAX_date
# [1] "2019-04-01 UTC"

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.5) +
  geom_point(colour = "#005EB8", size = 3) +
  
  labs(title = "A&E Type I major attendances. England 2010-2019",
       subtitle = "Source: NHS England. A&E Attendances and Emergency Admissions",
       y = "Number Attendances", x = "Years"
  ) +
  theme_light()  +
  theme(plot.title = element_text(size = 15, color = "#330072"),
        plot.subtitle = element_text(size = 8, color = "#0072CE"),
        axis.ticks = element_blank()) +
  # Add geom_smooth to the chart
  geom_smooth(se = TRUE,color =  "#00A9CE", size = 0.3, method = "loess", span = 0.25 )

ggsave("01 AE Type I major attendances England.png", width = 6, height = 4)

# 2 Turn the above plot into a step by step script for camcoder
# https://github.com/thebioengineer/camcorder

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) + 
  geom_line()

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8")
  
ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.5)

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.5) +
  geom_point(colour = "#005EB8")    
    
ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.5) +
  geom_point(colour = "#005EB8", size = 3)    

    
ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.5) +
  geom_point(colour = "#005EB8", size = 3) +
  labs(title = "A&E Type I major attendances. England 2010-2019")

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.5) +
  geom_point(colour = "#005EB8", size = 3) +
  labs(title = "A&E Type I major attendances. England 2010-2019",
       subtitle = "Source: NHS England. A&E Attendances and Emergency Admissions",
       y = "Number Attendances", x = "Years")  +
  theme(plot.title = element_text(size = 9),
        plot.subtitle = element_text(size = 7))


ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.3) +
  geom_point(colour = "#005EB8", size = 2) +
  labs(title = "A&E Type I major attendances. England 2010-2019",
       subtitle = "Source: NHS England. A&E Attendances and Emergency Admissions",
       y = "Number Attendances", x = "Years") +
  theme(plot.title = element_text(size = 9, color = "#330072"),
        plot.subtitle = element_text(size = 7, color = "#0072CE"))

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.5) +
  geom_point(colour = "#005EB8", size = 3) +
  labs(title = "A&E Type I major attendances. England 2010-2019",
       subtitle = "Source: NHS England. A&E Attendances and Emergency Admissions",
       y = "Number Attendances", x = "Years")+
  theme_light() 

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.2) +
  geom_point(colour = "#005EB8", size = 2) +
  labs(title = "A&E Type I major attendances. England 2010-2019",
       subtitle = "Source: NHS England. A&E Attendances and Emergency Admissions",
       y = "Number Attendances", x = "Years")+
  theme_light() +
theme(plot.title = element_text(size = 9, color = "#330072"),
      plot.subtitle = element_text(size = 7, color = "#0072CE"))

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.2) +
  geom_point(colour = "#005EB8", size = 2) +
  labs(title = "A&E Type I major attendances. England 2010-2019",
       subtitle = "Source: NHS England. A&E Attendances and Emergency Admissions",
       y = "Number Attendances", x = "Years")+
  theme_light() +
  theme(plot.title = element_text(size = 9),
        plot.subtitle = element_text(size = 7))

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.2) +
  geom_point(colour = "#005EB8", size = 2) +
  labs(title = "A&E Type I major attendances. England 2010-2019",
       subtitle = "Source: NHS England. A&E Attendances and Emergency Admissions",
       y = "Number Attendances", x = "Years")+
  theme_light() +
  theme(plot.title = element_text(size = 9, color = "#330072"),
        plot.subtitle = element_text(size = 7, color = "#0072CE"))

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.2) +
  geom_point(colour = "#005EB8", size = 2) +
  labs(title = "A&E Type I major attendances. England 2010-2019",
       subtitle = "Source: NHS England. A&E Attendances and Emergency Admissions",
       y = "Number Attendances", x = "Years")+
  theme_light() +
    theme(plot.title = element_text(size = 10, color = "#330072"),
          plot.subtitle = element_text(size = 6, color = "#0072CE"),
          axis.ticks = element_blank())
  

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.2) +
  geom_point(colour = "#005EB8", size = 2) +
  labs(title = "A&E Type I major attendances. England 2010-2019",
       subtitle = "Source: NHS England. A&E Attendances and Emergency Admissions",
       y = "Number Attendances", x = "Years")+
  theme_light() +
  theme(plot.title = element_text(size = 10, color = "#330072"),
        plot.subtitle = element_text(size = 6, color = "#0072CE"),
        axis.ticks = element_blank()) +
  geom_smooth(se = TRUE,color =  "#00A9CE", size = 0.3, method = "loess", span = 0.25 )
  
# 3 Record the plot
# This is how you setup camcoder output file on your work laptop

## Extra tip: When working in the NHS modern desktop laptops, after installing R and R Studio, I recomment to create a "WorkingDir" folder
# whithin your R folder. This will help you to render any Markdown document (specially with nested side navigation menus as part of your YAML section)

# So After this setup to render my Markdown documents, I always use that WorkingDir to create new ouptut folders.
# In this instance I am creating a folder called "recording102" for this specific GIF
# Create a new folder every time to record a new GIF using camcoder, to keep each recordin neat and tidy

gg_record(
  dir = file.path("C:\\R\\WorkingDir", "recording102"), # where to save the recording
  device = "png", # device to use to save images
  width = 4,      # width of saved image
  height = 6,     # height of saved image
  units = "in",   # units for width and height
  dpi = 300       # dpi to use when saving image
)

# Once the recorder is initialized, any ggplot that is made will be automatically recorded
# Use this 

# Section to produce the plot step by step recording each ggplot iteration
ggplot(AE_ATTM, aes(x = Period, y = Major_att)) + 
  geom_line()

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8")

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.5)

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.5) +
  geom_point(colour = "#005EB8")    

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.5) +
  geom_point(colour = "#005EB8", size = 3)    

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.5) +
  geom_point(colour = "#005EB8", size = 3) +
  labs(title = "A&E Type I major attendances. England 2010-2019")

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.5) +
  geom_point(colour = "#005EB8", size = 3) +
  labs(title = "A&E Type I major attendances. England 2010-2019",
       subtitle = "Source: NHS England. A&E Attendances and Emergency Admissions",
       y = "Number Attendances", x = "Years")  +
  theme(plot.title = element_text(size = 9),
        plot.subtitle = element_text(size = 7))

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.3) +
  geom_point(colour = "#005EB8", size = 2) +
  labs(title = "A&E Type I major attendances. England 2010-2019",
       subtitle = "Source: NHS England. A&E Attendances and Emergency Admissions",
       y = "Number Attendances", x = "Years") +
  theme(plot.title = element_text(size = 9, color = "#330072"),
        plot.subtitle = element_text(size = 7, color = "#0072CE"))

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.5) +
  geom_point(colour = "#005EB8", size = 3) +
  labs(title = "A&E Type I major attendances. England 2010-2019",
       subtitle = "Source: NHS England. A&E Attendances and Emergency Admissions",
       y = "Number Attendances", x = "Years")+
  theme_light() 

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.2) +
  geom_point(colour = "#005EB8", size = 2) +
  labs(title = "A&E Type I major attendances. England 2010-2019",
       subtitle = "Source: NHS England. A&E Attendances and Emergency Admissions",
       y = "Number Attendances", x = "Years")+
  theme_light() +
  theme(plot.title = element_text(size = 9, color = "#330072"),
        plot.subtitle = element_text(size = 7, color = "#0072CE"))

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.2) +
  geom_point(colour = "#005EB8", size = 2) +
  labs(title = "A&E Type I major attendances. England 2010-2019",
       subtitle = "Source: NHS England. A&E Attendances and Emergency Admissions",
       y = "Number Attendances", x = "Years")+
  theme_light() +
  theme(plot.title = element_text(size = 9),
        plot.subtitle = element_text(size = 7))

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.2) +
  geom_point(colour = "#005EB8", size = 2) +
  labs(title = "A&E Type I major attendances. England 2010-2019",
       subtitle = "Source: NHS England. A&E Attendances and Emergency Admissions",
       y = "Number Attendances", x = "Years")+
  theme_light() +
  theme(plot.title = element_text(size = 9, color = "#330072"),
        plot.subtitle = element_text(size = 7, color = "#0072CE"))

ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.2) +
  geom_point(colour = "#005EB8", size = 2) +
  labs(title = "A&E Type I major attendances. England 2010-2019",
       subtitle = "Source: NHS England. A&E Attendances and Emergency Admissions",
       y = "Number Attendances", x = "Years")+
  theme_light() +
  theme(plot.title = element_text(size = 10, color = "#330072"),
        plot.subtitle = element_text(size = 6, color = "#0072CE"),
        axis.ticks = element_blank())


ggplot(AE_ATTM, aes(x = Period, y = Major_att)) +
  geom_line(colour = "#005EB8", size = 0.2) +
  geom_point(colour = "#005EB8", size = 2) +
  labs(title = "A&E Type I major attendances. England 2010-2019",
       subtitle = "Source: NHS England. A&E Attendances and Emergency Admissions",
       y = "Number Attendances", x = "Years")+
  theme_light() +
  theme(plot.title = element_text(size = 10, color = "#330072"),
        plot.subtitle = element_text(size = 6, color = "#0072CE"),
        axis.ticks = element_blank()) +
  geom_smooth(se = TRUE,color =  "#00A9CE", size = 0.3, method = "loess", span = 0.25 )

# 4 Output the plot as a animated GIF file
# Finally, to generate the final GIF, use the gg_playback() function. The user can define: - where the final GIF gets saved by setting the name argument, - duration of the first and last images with first_image_duration or last_image_duration - delay between frames in seconds with frame_duration
#   dir = file.path("C:\\R\\WorkingDir", "recording100"), 

gg_playback(
  dir = file.path("C:\\R\\WorkingDir", "recording","vignette_gif.gif"),
  first_image_duration = 5,
  last_image_duration = 15,
  frame_duration = .4,
  image_resize = 800
)
