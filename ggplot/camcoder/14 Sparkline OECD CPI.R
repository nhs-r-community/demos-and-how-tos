## ORIGINGAL CHART FROM WEBSITE
# http://motioninsocial.com/tufte/
  
##  Sparklines in ggplot2
# DATA: OECD Inflation (CPI) 

# 1. Load required packages
pacman::p_load(here,tidyverse,ggthemes,reshape,RCurl,janitor)

# 2. Get data into R
OECD_files <- list.files(path = "./data/OECD", pattern = "csv$")
OECD_files

OECD_DATA  <-read.table(here("data","OECD", "OECD_CPI_selected_countries.csv"),
                        header =TRUE, sep =',',stringsAsFactors =TRUE) %>% 
                        clean_names()
OECD_DATA

# 3. Subset data to include just a set of countries
names(OECD_DATA)

location_freq <- OECD_DATA %>% 
                  select(location) %>%
                  group_by(location) %>% 
                  summarise(freq = n()) %>% 
                  arrange(freq)
location_freq

min(OECD_DATA$time)

# Subset data just for these countries G20 (G-20), 
# Japan (JPN), United Kingdom (GBR), United states (USA), Australia (AUS) . 
Subset <-c("G-20","JPN","GBR","USA","AUS")
OECD_subset  <- OECD_DATA %>% filter(location %in% Subset)

OECD_subset  <- OECD_subset %>% select(time,country = location, value)
OECD_subset

Min_year <- min(OECD_subset$time)
Min_year
# [1] 1974
Max_year <- max(OECD_subset$time)
Max_year
# [1] 2022
head(OECD_subset)
names(OECD_subset)

# 4. Compute reference points (min, max, latest) Inflation CPI values for each country
minv <- group_by(OECD_subset, country) %>% slice(which.min(value))
maxv <- group_by(OECD_subset, country) %>% slice(which.max(value))
endv <- group_by(OECD_subset, country) %>% filter(time == max(time))

quartv <- OECD_subset %>% group_by(country) %>%
          summarize(quart1 = quantile(value, 0.25),
                    quart2 = quantile(value, 0.75)) %>% 
          right_join(OECD_subset)

# 5.  Build plot to include Inflation CPI min max and latest values for selected countries
ggplot(OECD_subset, aes(x=time, y=value)) + 
  facet_grid(country ~ ., scales = "free_y") + 
  ggtitle("Inflation, consumer price index (CPI) selected countries. 1974-2022") +
  geom_line(size=0.3) +
  geom_point(data = minv, col = 'red') +
  geom_point(data = maxv, col = 'blue') +
  geom_point(data = endv, col = 'purple') +
  geom_text(data = minv, aes(label = value), vjust = -1) +
  geom_text(data = maxv, aes(label = value), vjust = 2.5) +
  geom_text(data = endv, aes(label = value), hjust = 0, nudge_x = 1) +
  geom_text(data = endv, aes(label = country), hjust = 0, nudge_x = 5) +
  expand_limits(x = max(OECD_subset$time) + (0.25 * (max(OECD_subset$time) - min(OECD_subset$time)))) +
  scale_x_continuous(breaks = seq(1960, 2025, 5)) +
  scale_y_continuous(expand = c(0,25)) +
  theme_minimal() +
  theme(
        axis.title=element_blank(), axis.text.y = element_blank(), 
        axis.ticks = element_blank(), strip.text = element_blank(),
        legend.position="none",
          panel.spacing = unit(0.1, "lines"),
          strip.text.x = element_text(size = 8),
          plot.title = element_text(size=14)
        ) 

ggsave("plots/04 Sparkline chart OECD CPI test.png", width = 6, height = 4)



