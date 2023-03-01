# 10 Density plot for A&E Attendanes
library(ggside)
library(tidyverse)
library(tidyquant)

# Using the AEBYEAR_sel data set for this Density plot
AEBYEAR_sel

# 1 DENSITY PLOT FOR MAJOR_ATTENDANCES AND SINGLE ESP ATT SCATTERPLOT
AEBYEAR <- AEBYEAR_sel %>% select(period,Major_att,Single_esp_att,Other_att)
AEBYEAR


# Plot structure
# X axis (period)
# Y axis  (value)
# color (metric)

# 2. Place both metrics Major_att, Single_esp_att on the same columns (pivot long data set)
Dendata_long<- AEBYEAR %>% 
   pivot_longer(names_to = "Metrics",
             cols = 2:ncol(AEBYEAR))
Dendata_long

# 2.1 Add month as new variable to data set
Dendata_months<- Dendata_long %>% 
                      mutate(
                        Year = format(period, format = "%Y"),
                        Month = format(period, format = "%b")
                            )
Dendata_months

# 2 Start building the Density plot
# 2.1 Initial GGPLOT displaying metric by date
scatter_plot <- Dendata_months %>% 
              ggplot(aes(period, value, color = Metrics)) +
              ggtitle("Standard ggplot2 scatterplot") +
              geom_point(size = 2, alpha = 0.3)   
scatter_plot



# 2.2 start building the density plot
library(tidyquant)

density_plot <- density_Major_att %>% 
  ggplot(aes(period, value, color = Metrics)) +
  ggtitle("AE Attendances by Type.2011-2019") +
  geom_point(size = 2, alpha = 0.3)   +

# Adding X axis density plot
geom_xsidedensity(
  aes(y = after_stat(density),fill = Metrics),
  alpha = 0.5, size = 1,
  position = "stack")  
  
density_plot
  