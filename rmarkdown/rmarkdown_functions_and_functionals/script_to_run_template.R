
# Code to run the template 

pacman::p_load(tidyverse, here)


country_code_df <- tribble(
  ~code, ~country,
  "AUS", "Australia",
  "AUT", "Austria",
  "BLR", "Belarus",
  "BEL", "Beligium",
  "BGR", "Bulgaria",
  "CAN", "Canada",
  "CHL", "Chile",
  "HRV", "Croatia",
  "CZE", "Czechia",
  "DNK", "Denmark",
  "EST", "Estonia",
  "FIN", "Finland",
  "FRATNP", "France",
  "DEUTNP", "Germany",
  "GRC", "Greece",
  "HUN", "Hungary",
  "ISL", "Iceland",
  "IRL", "Ireland",
  "ISR", "Israel",
  "ITA", "Italy",
  "JPN", "Japan",
  "KOR", "Korea", 
  "LVA", "Latvia",
  "LTU", "Lithuania",
  "LUX", "Luxembourg",
  "NLD", "Netherlands",
  "NZL_NP", "New Zealand",
  "NOR", "Norway",
  "POL", "Poland",
  "PRT", "Portugal",
  "RUS", "Russia",
  "SVK", "Slovakia",
  "SVN", "Slovenia",
  "ESP", "Spain",
  "SWE", "Sweden",
  "CHE", "Switzerland",
  "TWN", "Taiwan",
  "GBR_NP", "United Kingdom",
  "USA", "USA",
  "UKR", "Ukraine"
)

# Make render function and render for one population
all_lt <- read_rds("https://github.com/JonMinton/change-in-ex/blob/main/data/lifetables.rds?raw=true")

render_country_report <- function(code, country){
  rmarkdown::render(
    here("rmarkdown", "rmarkdown_functions_and_functionals", "markdown_template.rmd"), # this is where the markdown document to use as a template is located
    output_dir = here("rmarkdown", "rmarkdown_functions_and_functionals", "outputs"), # This is the output directory  
    output_file = paste0(code, "-", country, ".html"), # a filename specific to each output generated
    params = list(code = code, country = country), # these are the parameters to pass to the .rmd tempalte
    envir = parent.frame(), # This ensures the markdown document can 'see' contents created here
    output_format = "html_document", 
  )
}

# An example for a single country 

render_country_report(code = "CHE", country = "Switzerland")


# Generate for all countries


## using a for loop

N_rows <- nrow(country_code_df)

for (i in 1:N_rows){
  this_code <- country_code_df$code[i]
  this_country <- country_code_df$country[i]
  
  render_country_report(code = this_code, country = this_country)
}


# Using functional programming and walk2

country_code_df %>% 
  mutate(
    NULL = walk2(code, country, render_country_report)
  )

# tmp doesn't really do anything! 