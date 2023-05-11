## 01 Download RTT data

# MAIN WEBSITE FOR THIS INDICATOR
# Consultant-led Referral to Treatment (RTT) waiting times
# https://www.england.nhs.uk/statistics/statistical-work-areas/rtt-waiting-times/
# FULL month sets of data
# APRIL 2022 <a href=https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2022/06/Full-CSV-data-file-Apr22-ZIP-3300K-57873-1.zip>Full CSV data file Apr22 (ZIP, 3300K)</a>
# MAY 2022   <a href=https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2022/07/Full-CSV-data-file-May22-ZIP-3611K-16155.zip>Full CSV data file May22 (ZIP, 3611K)</a>
# JUNE 2022  <a href=https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2022/08/Full-CSV-data-file-Jun22ZIP-3886K-68395.zip>Full CSV data file Jun22(ZIP, 3886K)</a>

# Function to download RTT data from  NHS England website
RTTdata <- function() {
  
  if(!dir.exists("data")){dir.create("data")}
  
  # Download master.zip file APRIL 2022 d
  # And unzip April file as .csv file
  download.file(
    url = 'https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2022/06/Full-CSV-data-file-Apr22-ZIP-3300K-57873-1.zip',
    destfile = "data/RTTapr22.zip"
  )
  unzip(zipfile = "data/RTTapr22.zip",exdir = "data",junkpaths = T)
  # Download master .zip file MAY 2022
  # And unzip May file as .csv file
  download.file(
    url = 'https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2022/07/Full-CSV-data-file-May22-ZIP-3611K-16155.zip',
    destfile = "data/RTTmay22.zip"
  )
  unzip(zipfile = "data/RTTmay22.zip",exdir = "data",junkpaths = T)
  
  # Download master .zip file JUNE 2022
  # And unzip June file as .csv file
  download.file(
    url = 'https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2022/08/Full-CSV-data-file-Jun22ZIP-3886K-68395.zip',
    destfile = "data/RTTjun22.zip"
  )
  unzip(zipfile = "data/RTTjun22.zip",exdir = "data",junkpaths = T)
  
}


# Download RTT data function (no arguments)
RTTdata()