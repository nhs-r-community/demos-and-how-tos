# Source: showtext: Using Fonts More Easily in R Graphs
# https://cran.rstudio.com/web/packages/showtext/vignettes/introduction.html

library(showtext)
library(here)
library(tidyverse)
here()

# font_add_google()
font_add_google("Schoolbell", "bell")
font_add_google("Gochi Hand", "gochi")


# Fonts I am exploring for maps and charts
font_add_google("Barlow", "Barlow")
font_add_google("Barlow Condensed", "barlow condensed")
font_add_google("Didact Gothic","didact gothic")


# Code sample for bell google font 
# PLOT 01> plot a histogram using "bell" family font
hist(rnorm(1000),breaks = 30, col = "steelblue", border = "white",
    main = "", xlab = "", ylab = "")
showtext_begin()
title("Normal Histogram - bell google font", family = "bell", cex.main = 2)
title(ylab = "Frequency", family = "bell", cex.lab = 2)
text(2, 70, "N = 1000", family = "bell", cex = 2.5)
showtext_end()

ggsave("bell_font_example.png", width = 10, height = 6) 

# PLOT 02> plot a histogram using "gochi" family font
# Using Family = gochi"
hist(rnorm(1000),breaks = 30, col = "steelblue", border = "white",
     main = "", xlab = "", ylab = "")
showtext_begin()
title("Normal Histogram - gochi google font", family = "gochi", cex.main = 2)
title(ylab = "Frequency", family = "gochi", cex.lab = 2)
text(2, 70, "N = 1000", family = "gochi", cex = 2.5)
showtext_end()

ggsave("plots/bell_font_example.png", width = 10, height = 6) 

# PLOT 03> plot a histogram using "Barlow condensed" family font
# Using Family = "Barlow condensed"
showtext_auto()

set.seed(123)
hist(rnorm(1000), breaks = 30, col = "steelblue", border = "white",
     main = "", xlab = "", ylab = "")
title("Histogram of Normal Numbers- Barlow ", family = "barlow condensed", cex.main = 2)
title(ylab = "Frequency", family = "barlow condensed", cex.lab = 2)
text(2, 70, "N = 1000", family = "barlow condensed", cex = 2.5)

# PLOT 04> plot a histogram using "didact gothic" family font
# Using Family = "didact gothic"
showtext_auto()

set.seed(123)
hist(rnorm(1000), breaks = 30, col = "steelblue", border = "white",
     main = "", xlab = "", ylab = "")
title("Histogram of Normal Numbers- didact gothic ", family = "didact gothic", cex.main = 2)
title(ylab = "Frequency", family = "didact gothic", cex.lab = 2)
text(2, 70, "N = 1000", family = "didact gothic", cex = 2.5)
