library(targets)
library(tarchetypes)
lapply(list.files("./R", full.names = TRUE), source)

tar_option_set(packages = c("tidyverse"))

# Basic example of a targets pipeline, run me with targets::tar_make and visualise me with targets::tar_visnetwork().
# Load my outputs into you environment using targets::tar_load(everything())

tar_plan(
  
  #################
  ### Motivation###
  #################
  
  df_some_data = get_data(),
  
  df_wrangled_data = df_some_data %>% mutate(c=a * 2),
  
  tar_file(out_file, (function() {
      file_name <- 'output_data/wrangled_data.csv'
      write_csv2(df_wrangled_data, file_name)
      file_name}) () ),
  
  #################
  ### Gothcas   ###
  #################
  
  # Doesn't know that input is a file and not just a string
  # therefore doesn't rerun when the file changes
  df_first = read_csv('input_data/first.csv'),
  
  # Fixed it, tar_file creates a target that reruns when the file contents change
  tar_file(file_first, 'input_data/first.csv'),
  df_first_fixed = read_csv(file_first),
  
  # Depends on external state, the function and its inputs don't change
  not_the_time = Sys.time(),
  
  # Fixed it by adding a 'cue' rule that tells it when to rerun
  tar_target(the_time, Sys.time(), cue=tar_cue('always')),


  #################
  ### Branching ###
  #################
  
  # A directory full of files
  tar_files(input_files, list.files('input_data', full.names = TRUE)),
  
  tar_target(line_counts, length(read_csv(input_files)), pattern = map(input_files)),
  
  fixed_line_count = 17,
  
  final_line_count = sum(line_counts) + fixed_line_count,
  
  #################
  
  final = 1

)