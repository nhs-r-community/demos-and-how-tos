# find bank holidays (example is for England and Wales)

holidays <- jsonlite::fromJSON(
  "https://www.gov.uk/bank-holidays.json")$`england-and-wales`$events$date