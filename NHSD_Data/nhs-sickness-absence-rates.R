# National Staff Abscence Rates ----------------------------------------------------------
library(htmltools)
library(rvest)
library(xml2)
library(dplyr)




#Specifying the url for desired website to be scraped
url <- paste("https://digital.nhs.uk/data-and-information/publications/statistical/nhs-sickness-absence-rates")

#Reading the HTML code from the website
webpage <- read_html(url)

#Using CSS selectors to scrape the publications section
web_data_html <- html_nodes(webpage,'.cta__button')

#Find the latest publication 
web_data <- xml_attrs(web_data_html[[1]]) %>% 
  data.frame() %>% 
  head(1) %>% 
  pull()

url2 <- paste0("https://digital.nhs.uk",web_data)



#Reading the HTML code from the website
webpage2 <- read_html(url2)

#Using CSS selectors to scrape the downloads section
#For my purposes I need the NEW_FORMAT_NHS Sickness Absence XLSX file which is number 9
web_data_html2 <- html_nodes(webpage2,'.nhsd-a-box-link')[9]

#Pull out the full file path
web_data2 <- xml_attrs(web_data_html2[[1]]) %>% 
  data.frame() %>% 
  head(1) %>% 
  pull()

#Download File
destfile <- "NationalAbsenceRates.xlsx"
curl::curl_download(web_data2, destfile)

#Read file as normal, here I am getting the monthly nation absence rates for acutes 
NationalAbsenceRates <- read_excel(destfile, sheet = "Table 3", skip = 2) |> 
  select(`...1`, Acute) |> 
  drop_na() |> 
  mutate(Date = paste("01",`...1`)) |> #Poorly formatted dates need adjusting
  mutate(Date = as.Date(Date, "%d %B %Y")) |> 
  mutate(Absence = rollmean(Acute, k=12, fill=NA, align = "right")) |> 
  filter(Date >= '2021-04-01') |> 
  select(Date, Absence)


