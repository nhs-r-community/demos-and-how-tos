# 10 Density plot for A&E Attendanes
library(ggside)
library(tidyverse)
library(tidyquant)

# Using the AEBYEAR_sel data set for this Density plot
AEBYEAR_sel

names(AEBYEAR_sel)
names(Att_facet)
head(Att_facet)

# 1 DENSITY PLOT FOR MAJOR_ATTENDANCES AND SINGLE ESP ATT SCATTERPLOT
MAJORSING <- AEBYEAR_sel %>% select(period,Major_att,Single_esp_att,Other_att )
MAJORSING


# > MAJORSING
# A tibble: 96 × 4
#period              Major_att Single_esp_att Other_att
#<dttm>                  <dbl>          <dbl>     <dbl>
#  1 2011-01-01 00:00:00  1133881.         51585.   542331.
#2 2011-02-01 00:00:00  1053707.         51249.   494408.
#3 2011-03-01 00:00:00  1225222.         57900.   580319.
#4 2011-04-01 00:00:00  1197213.         54042.   593120.
#5 2011-05-01 00:00:00  1221687.         57067    594941.
#6 2011-06-01 00:00:00  1168468.         54739.   562210 
#7 2011-07-01 00:00:00  1211066.         56204.   597690.
#8 2011-08-01 00:00:00  1135801.         51890.   570417.
#9 2011-09-01 00:00:00  1162143.         52329.   566738.
#10 2011-10-01 00:00:00  1200708.         54447.   593757.

# 2 Create variable for Moths, we are going to display Attendances by Month for 2011
Att_months  <- MAJORSING %>% 
  mutate(
    Year = format(period, format = "%Y"),
    Month = format(period, format = "%b")
  )
Att_months

# Plot structure
# X axis (period)
# Y axis  (value)
# color (metric) 

# 2 Start building the Density plot
# 2.1 Initial GGPLOT displaying metric by date
scatter_plot <- Att_months %>% 
              ggplot(aes(period, Major_att, color = Major_att)) +
              ggtitle("AE Major attendances. 2011-2019") +
              geom_point(size = 2, alpha = 0.3)   
scatter_plot

# 2.2 start building the density plot
library(tidyquant)

# Test including X axis density plot

# a. Subset variables
Att_months_long <- Att_months %>% 
                   select(period,Year,Month, Major_att, Single_esp_att, Other_att)
Att_months_long

# b. Pivot long the data 
Att_months_pivotl <- Att_months_long %>% 
                      pivot_longer(
                        cols = Major_att:Other_att,
                        names_to = c("Metrics"),
                           values_to = "count"
                      )
Att_months_pivotl

# Build a standard scatterplot
scatter_plot01 <- Att_months_pivotl %>% 
                    ggplot(aes(period, count, Metrics, color = Metrics)) +
                    ggtitle("AE Major attendances. 2011-2019") +
                    geom_point(size = 2, alpha = 0.3)   
scatter_plot01

ggsave("plots/19_A&E_Attendances_normal_scatterplot.png", width = 6, height = 4)



# 3 Start building density plot 
# 
Att_months_pivotl1<-Att_months_pivotl %>% 
                    mutate(Yearin = as.integer(Year))
Att_months_pivotl1


Norma_scatter_plot <- Att_months %>% 
                ggplot(aes(Major_att, Single_esp_att, Metrics, color = Month)) +
                ggtitle("AE Major attendances. 2011-2019") +
                geom_point(size = 2, alpha = 0.3)   
Norma_scatter_plot

# 3.1 Scatter plot plus X axis density plot
Desity_plot01 <- Att_months %>% 
  ggplot(aes(Major_att, Single_esp_att, Metrics, color = Month)) +
  ggtitle("AE Major attendances. 2011-2019") +
  geom_point(size = 2, alpha = 0.3)   +

  # Adding density plot for X axis
geom_xsidedensity(
  aes(y = after_stat(density),fill = Month),
  alpha = 0.5, size = 1,
  position = "stack") 

Desity_plot01

ggsave("plots/20_A&E_Attendances_X_axis_density_plot.png", width = 6, height = 4)


# 3.2 Scatter plot plus Y axis density plot 

Desity_plot02 <- Att_months %>% 
  ggplot(aes(Major_att, Single_esp_att, Metrics, color = Month)) +
  ggtitle("AE Major attendances. 2011-2019") +
  geom_point(size = 2, alpha = 0.3)   +
  
  # Adding density plot for X axis
  geom_xsidedensity(
    aes(y = after_stat(density),fill = Month),
    alpha = 0.5, size = 1,
    position = "stack") +

 # Adding density plot for Y axis

geom_ysidedensity(
  aes(x = after_stat(density),fill = Month),
  alpha = 0.5, size = 1,
  position = "stack")  
  
Desity_plot02

ggsave("plots/21_A&E_Attendances_X_axis_Y_axis_density_plot.png", width = 6, height = 4)

