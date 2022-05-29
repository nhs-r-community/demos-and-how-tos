library(targets)
source("kh03.R")

tar_option_set(packages = c("dplyr", "purrr", "withr", "rvest"))

list(
  tar_target(kh03_files, get_kh03_filelist(), cue = tar_cue("always")),
  tar_target(kh03_data, process_kh03_file(kh03_files), pattern = map(kh03_files))
)
