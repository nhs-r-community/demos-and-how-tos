library(dplyr)
library(tidyr)
library(purrr)
library(stringr)

opcs_lookup <- data.frame(
  stringsAsFactors = FALSE,
  speciality = c("ENT", "ENT"),
  procedure_name = c("Wide incision", "Biopsy"),
  opcs = c("B1", "D1"),
  procedurecode2 = c(NA, "B1")
)

patient_data <- data.frame(
  stringsAsFactors = FALSE,
  patient = c("Patient1", "Patient2", "Patient3", "Patient4"),
  procedurecode1 = c("B1", "D1", "C1", "E1"),
  procedurecode2 = c(NA, "B1", "D1", "B1"),
  procedurecode3 = c(NA, NA, "B1", "D1"),
  procedurecode4 = c(NA, NA, NA, NA),
  procedurecode5 = c(NA, NA, NA, NA)
)

joined <- patient_data |> 
  select(
    patient,
    procedurecode1,
    procedurecode2,
    procedurecode3,
    procedurecode4,
    procedurecode5) |> 
  mutate(rn = row_number()) |> 
  pivot_longer(cols = starts_with("procedurecode"), 
               names_to = "procedure_code_number",
               values_to = "opcs") |> 
  na.omit(opcs) |> 
  group_by(rn) |> 
  mutate(all_codes = map_chr(list(opcs), paste, collapse= " ")) |> 
  inner_join(opcs_lookup, 
             by = "opcs") |>
  filter(is.na(procedurecode2) | str_detect(all_codes, procedurecode2)) 
  

