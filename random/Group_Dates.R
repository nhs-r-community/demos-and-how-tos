#Do you have daily data that would be useful to present weekly or monthly?
#The cut.Date function will help!


library(dplyr)

#Create data 
df <- data.frame(
ActivityDate = seq(as.Date("2021-01-01"), as.Date("2021-12-31"), by="days"),
Activity = sample(100:200, size = 365, replace = TRUE)
)

#Group by week
df |> mutate(Week = 
               cut.Date(as.Date(`ActivityDate`), breaks="week", start.on.monday = TRUE))


#Group by month
df |> mutate(Month = 
               cut.Date(as.Date(`ActivityDate`), breaks="month"))