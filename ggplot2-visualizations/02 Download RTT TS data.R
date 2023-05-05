# 01 Download RTT data.R

# How to download .XLSX files from a URL into R 

# MAIN WEBSITE FOR THIS INDICATOR
# Consultant-led Referral to Treatment (RTT) waiting times
# https://www.england.nhs.uk/statistics/statistical-work-areas/rtt-waiting-times/

# Time series data
# CHROME: Inspect element. Copy outher HTML 
# We can find the .csv data by looking at <href> tags in the HTML code
# <p><strong>England-level time series</strong></p>
# <p><a href="https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2023/01/RTT-Overview-Timeseries-Including-Estimates-for-Missing-Trusts-Nov22-XLS-98K-63230.xlsx">RTT Overview Timeseries Including Estimates for Missing Trusts Nov22 (XLS, 98K)</a></p>'

# Template to load xlsx file from URL
# urlFile = "https://docs.google.com/spreadsheets/d/1SF0PkBz9BR4yqiQ27Bt5OsD33Y8Rt5lh/edit?usp=sharing&ouid=107152468748636733235&rtpof=true&sd=true"
# xlsFile = "refugios_nayarit.xlsx"
# download.file(url=urlFile, destfile=xlsFile, mode="wb")

# Check WD directory file system  
RTT_TS_data <- function() {
  
  if(!dir.exists("data")){dir.create("data")}
  
  # England-level time series
  # Download Excel file to a Project sub-folder called "data"
  # Created previously using an adhoc project structure function
  
  xlsFile <- "RTT_TS_data.xlsx"
  
  download.file(
    url = 'https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2023/01/RTT-Overview-Timeseries-Including-Estimates-for-Missing-Trusts-Nov22-XLS-98K-63230.xlsx',
    destfile = here("data",xlsFile),
    mode ="wb"
  )

}
# Download RTT data function (no arguments)
RTT_TS_data()