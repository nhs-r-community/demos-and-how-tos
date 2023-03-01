## GGPLOT2 group by

library(reshape2)
library(ggplot2)
x <- seq(1, 5, length = 100)
y <- replicate(10, sin(2 * pi * x) + rnorm(100, 0, 0.3), "list")
z <- replicate(10, sin(2 * pi * x) + rnorm(100, 5, 0.3), "list")
y <- melt(y)
z <- melt(z)
df <- data.frame(x = y$Var1, rep = y$Var2, y = y$value, z = z$value)
dat <- melt(df, id = c("x", "rep"))

dat

# Plot it using dacet wrap

ggplot(dat) + geom_line(aes(x, value, group = rep, color = variable), 
                        alpha = 0.3) + facet_wrap(~variable)
