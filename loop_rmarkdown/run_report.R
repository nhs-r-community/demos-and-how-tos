
# install.packages("palmerpenguins")

library(rmarkdown)
library(palmerpenguins)

for(i in unique(penguins$species)){
  
  render("loop_rmarkdown/loop_species.Rmd", params = list(species = i), 
         output_file = paste0("report_", i))
}

for(i in c("bill_length_mm", "bill_depth_mm")){
  
  render("loop_rmarkdown/loop_variables.Rmd", params = list(variable = i), 
         output_file = paste0("variable_report_", i))
}
