Working with Web API’s
================
[Tom Jemmett](mailto:thomas.jemmett@nhs.net) \| [The Strategy
Unit](https://strategyunitwm.nhs.uk/)

``` r
options("nhs_api_key" = params$nhs_api_key)
```

## What are API’s?

Application Programming Interfaces, or API’s are a way for developers to
expose some part of a system so other developers can interact and work
with that system programatically.

> "It defines the kinds of calls or requests that can be made, how to
> make them, the data formats that should be used, the conventions to
> follow, etc. It can also provide extension mechanisms so that users
> can extend existing functionality in various ways and to varying
> degrees. [source: Wikipedia](https://en.wikipedia.org/wiki/API)

I like to think of an API as a contract - if you call the API with the
correct type of data and request, then it will return you data in a
specific way that you can work with.

A Web API is a specific type of API where the system that you are
interacting with is reached over the internet via \[HTTP\] calls. Some
API’s are designed for you to just download some data from a remote
server, other’s allow you to add, update, or delete data. Some API’s are
open for anyone to use, others require you to be registered and to
authenticate yourself, usually via an “API Key”.

Each API is going to be different - they will be specific for the system
that you are interacting with. A good API will have documentation that
makes it easy for the developer to learn how to use it, along with the
expected results. Each API may have it’s own quirks that you need to
understand, and there may be limits to usage, such as rate limiting (you
can only call the API 1000 times a minute or once per second), and how
many results are returned per call that requires you to “page” the
results in order to get all the records.

In this document we will cover how to work with Web API’s in R, first
looking at an example where someone has done all the hard work for us in
a package, then we will look at how we can implement our own calls for
when a package doesn’t already exist.

## Getting postcode data from postcodes.io

It is useful to sometimes take a postcode and ask “What *x* does this
postcode belong to?”, where *x* may be something like Local Authority,
LSOA or CCG. We may also want to be able to get the latitude and
longitude of the postcode in order to plot it on a map.

One way of doing this would be to download the \[NHS Postcode
Database\]\[postcode\_db\] into a datawarehouse, or directly into R. But
this is a rather large file (\~1GB) with way over 1m rows of data. If
you are only needing to work with a small number of postcodes (perhaps
in the order of 10,000) it may be quite wasteful to load this entire
dataset.

Instead, we can use the [postcodes.io](https://postcodes.io) Web API to
query a specific postcode, or to bulk search. There is an R package,
`{PostcodesioR}` that has already implemented all of the calls to the
API for us, so all we need to do is run a function and we will get the
data we are after.

First, let’s load the package (and `{tidyverse}` for good measure).

``` r
library(tidyverse)
```

    ## -- Attaching packages --------------------------------------- tidyverse 1.3.1 --

    ## v ggplot2 3.3.3     v purrr   0.3.4
    ## v tibble  3.1.2     v dplyr   1.0.6
    ## v tidyr   1.1.3     v stringr 1.4.0
    ## v readr   1.4.0     v forcats 0.5.1

    ## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library(PostcodesioR)
```

Now, let’s search for a single postcode. Here I am going to search for
my local hospital, [New Cross
Hospital](https://www.royalwolverhampton.nhs.uk/) in Wolverhampton.

``` r
nxh <- postcode_lookup("WV10 0QP")
glimpse(nxh)
```

    ## Rows: 1
    ## Columns: 35
    ## $ postcode                        <chr> "WV10 0QP"
    ## $ quality                         <int> 1
    ## $ eastings                        <int> 393625
    ## $ northings                       <int> 300219
    ## $ country                         <chr> "England"
    ## $ nhs_ha                          <chr> "West Midlands"
    ## $ longitude                       <dbl> -2.095555
    ## $ latitude                        <dbl> 52.59972
    ## $ european_electoral_region       <chr> "West Midlands"
    ## $ primary_care_trust              <chr> "Wolverhampton City"
    ## $ region                          <chr> "West Midlands"
    ## $ lsoa                            <chr> "Wolverhampton 015E"
    ## $ msoa                            <chr> "Wolverhampton 015"
    ## $ incode                          <chr> "0QP"
    ## $ outcode                         <chr> "WV10"
    ## $ parliamentary_constituency      <chr> "Wolverhampton North East"
    ## $ admin_district                  <chr> "Wolverhampton"
    ## $ parish                          <chr> "Wolverhampton, unparished area"
    ## $ admin_county                    <lgl> NA
    ## $ admin_ward                      <chr> "Heath Town"
    ## $ ced                             <lgl> NA
    ## $ ccg                             <chr> "NHS Wolverhampton"
    ## $ nuts                            <chr> "Wolverhampton"
    ## $ admin_district_code             <chr> "E08000031"
    ## $ admin_county_code               <chr> "E99999999"
    ## $ admin_ward_code                 <chr> "E05001330"
    ## $ parish_code                     <chr> "E43000185"
    ## $ parliamentary_constituency_code <chr> "E14001049"
    ## $ ccg_code                        <chr> "E38000210"
    ## $ ccg_id_code                     <chr> "06A"
    ## $ ced_code                        <chr> "E99999999"
    ## $ nuts_code                       <chr> "UKG39"
    ## $ lsoa_code                       <chr> "E01010476"
    ## $ msoa_code                       <chr> "E02002163"
    ## $ lau2_code                       <chr> "E05001330"

We get a vast amount of useful information from this API!

It’s probably more common though to need to search for multiple
postcodes. For this particular API we need to use a slight different
function. Next I’m going to search for 3 of my local hospitals, New
Cross again, Russell’s Hall in Dudley and Walsall Manor in Walsall.

``` r
postcodes <- list(postcodes = c("WV10 0QP", "DY1 2HQ", "WS2 9PS"))
bulk_results <- bulk_postcode_lookup(postcodes)
```

Now, one thing to note is API’s often return structured data, often
using [JSON](https://en.wikipedia.org/wiki/JSON). This allows very
complex data to be returned, but this may not necessarily be easy to
work with in R. We may want to need to convert the data into a tibble -
while this tutorial isn’t intended to explain this topic, you may want
to start with a look at [repurrrsive](https://github.com/jennybc/repurrrsive).

First, we need to get a bit of an idea on the structure of the data. As
we searched for 3 postcodes, we expect 3 results.

``` r
length(bulk_results)
```

    ## [1] 3

We can have a quick peek at the structure of the first result:

``` r
names(bulk_results[[1]])
```

    ## [1] "query"  "result"

``` r
bulk_results[[1]]$query
```

    ## [1] "WV10 0QP"

``` r
names(bulk_results[[1]]$result)
```

    ##  [1] "postcode"                   "quality"                   
    ##  [3] "eastings"                   "northings"                 
    ##  [5] "country"                    "nhs_ha"                    
    ##  [7] "longitude"                  "latitude"                  
    ##  [9] "european_electoral_region"  "primary_care_trust"        
    ## [11] "region"                     "lsoa"                      
    ## [13] "msoa"                       "incode"                    
    ## [15] "outcode"                    "parliamentary_constituency"
    ## [17] "admin_district"             "parish"                    
    ## [19] "admin_county"               "admin_ward"                
    ## [21] "ced"                        "ccg"                       
    ## [23] "nuts"                       "codes"

Now, we need to find a way to get the results into a tibble. We can use
`{purrr}` to help here. First, we don’t really care for the “query” part
of the results, just the “result” list. We could do this with a call
like `bulk_results %>% map_dfr("result")` - this would try to convert
the results to a tibble. If you do this though you will see each
postcode appears multiple times. Annoyingly, the “codes” column is
automatically expanded, so instead I map over the 3 results using the
`modify_at()` function to wrap each set of codes in it’s own list. This
creates a nice nested column of codes for each row of data.

``` r
bulk_results %>%
  map("result") %>%
  map_dfr(modify_at, "codes", list)
```

    ## # A tibble: 3 x 22
    ##   postcode quality eastings northings country nhs_ha        longitude latitude
    ##   <chr>      <int>    <int>     <int> <chr>   <chr>             <dbl>    <dbl>
    ## 1 WV10 0QP       1   393625    300219 England West Midlands     -2.10     52.6
    ## 2 DY1 2HQ        1   392052    289456 England West Midlands     -2.12     52.5
    ## 3 WS2 9PS        1   400170    298280 England West Midlands     -2.00     52.6
    ## # ... with 14 more variables: european_electoral_region <chr>,
    ## #   primary_care_trust <chr>, region <chr>, lsoa <chr>, msoa <chr>,
    ## #   incode <chr>, outcode <chr>, parliamentary_constituency <chr>,
    ## #   admin_district <chr>, parish <chr>, admin_ward <chr>, ccg <chr>,
    ## #   nuts <chr>, codes <list>

## Getting a list of A&E departments from the NHS API

In the next example we are going to work with the NHS API to get a list
of A&E departments. This API requires you to be authenticated, so first
go to [developer.api.nhs.uk](https://developer.api.nhs.uk/), click the
login in the top right corner and create an account. You can have a
trial subsription for the purposes of this sample.

Once you have an account you can view your API key by clicking the my
account in the top right corner. At the bottom you should see your
primary key. You will want to follow good security practice with these
keys, e.g. not storing them in your code (especially if you are using a
git repository). A good way of storing these would be in a
[.Renviron](https://support.rstudio.com/hc/en-us/articles/360047157094-Managing-R-with-Rprofile-Renviron-Rprofile-site-Renviron-site-rsession-conf-and-repos-conf)
file, or using `options()` in .Rprofile, for example:

``` r
options("nhs_api_key" = "YOUR_KEY_HERE")
```

We will be using the [service
search](https://developer.api.nhs.uk/nhs-api/documentation/service-search-organisations)
API. There are two listed options, a “get” endpoint and a “post”
endpoint. `GET` and `POST` are two HTTP
[methods](https://www.w3schools.com/tags/ref_httpmethods.asp).
Typically, `GET` is used to “get” data, and `POST` is used to send data
to the server in order to create/update data on the server. However,
`POST` can also confusingly be used for “getting” data - this is because
a `POST` request can have a “body”, or a set of data that we provide
along with the request.

**(at least, you can provide more complex data than you can with a `GET`
request. Parameters with a `GET` request have to be encoded in the
URL)**

We will use the `{httr}` package in order to make requests.

``` r
library(httr)
```

We can now start building our request. First, this API has a useful
[wizard](http://api-bridge.azurewebsites.net/servicesearchguide/) to run
through and build a query in various programming languages. R isn’t one
of the options, but we can use CURL as a basis for our request.

``` r
req <- POST(
  # first, the URL to query
  "https://api.nhs.uk/service-search/search",
  # we can add any query params to the URL with the "query" argument, we could also add ?api-version=1 to the URL above
  query = list( "api-version" = 1 ),
  # we need to say what type of data we are providing, so the end server knows how to process the data
  content_type_json(),
  # we need to tell httr how to encode the "body" argument, in this case we want to encode using json
  encode = "json",
  # we provide the search parameters to the request
  body = list(
    "filter" = "ServicesProvided / any(x: x eq 'Accident and emergency services')",
    "orderby" = "OrganisationName",
    "top" = 25,
    "skip" = 0,
    "count" = TRUE
  ),
  # finally we add the subscription key
  add_headers(
    "subscription-key" = getOption("nhs_api_key")
  )
)
req
```

    ## Response [https://api.nhs.uk/service-search/search?api-version=1]
    ##   Date: 2021-06-17 10:22
    ##   Status: 200
    ##   Content-Type: application/json; odata.metadata=minimal
    ##   Size: 327 kB
    ## {
    ##   "@odata.context": "https://nhsuksearchproduks.search.windows.net/indexes('o...
    ##   "@odata.count": 159,
    ##   "value": [
    ##     {
    ##       "@search.score": 1.0,
    ##       "OrganisationID": "40719",
    ##       "OrganisationName": "Addenbrooke's",
    ##       "OrganisationAliases": [],
    ##       "OrganisationTypeID": "HOS",
    ## ...

The “Status” code above is important and will tell us if things have
worked, or failed. 200 is what we want to see, but other codes will
indicate issues. Common ones will be 401, in this case you probably
haven’t provided the API key, 404 means you have asked for a URL that
doesn’t exist, and 400 is usually when you have provided some invalid
data.

In order to use the data we need to do get the content from the request.
As we are getting json data, which is going to be converted to a list in
R, it’s worth using tools like `length()` to see how many items are
returned and `names()` to see what the items in the list are called.

``` r
data <- content(req)
names(data)
```

    ## [1] "@odata.context" "@odata.count"   "value"          "tracking"

One of the items is a count of how many records there are in total:

``` r
data[["@odata.count"]]
```

    ## [1] 159

However, we said we wanted the top 25 records, how many items are in the
response?

``` r
length(data[["value"]])
```

    ## [1] 25

In order to get all of the results we need to “page”. Essentially, we
need to run the same request over and over, but updating the “page” that
we are looking at.

For this particular API we need to adjust the “skip” parameter. One away
to get all the results will be to repeatedly make the request in a loop
until the number of records we have got matches the count. The best type
of loop for this approach is `repeat`: we don’t know what the coniditon
will be until we have made at least one request.

At each iteration we will take the `value` from the results and combine
it with the previous results in the `data` variable. I wrap all of this
in `local()` - this is just so the `data`, `N_RECORDS` and `skip`
variables are temporary while we produce `ae_sites_data`.

``` r
ae_sites_data <- local({
  data <- list() # create an empty list to store the results
  N_RECORDS <- 25 # how many records to load per request
  skip <- 0 # update this during each iteration
  repeat {
    req <- POST(
      "https://api.nhs.uk/service-search/search",
      query = list( "api-version" = 1 ),
      content_type_json(),
      encode = "json",
      body = list(
        "filter" = "ServicesProvided / any(x: x eq 'Accident and emergency services')",
        "orderby" = "OrganisationName",
        "top" = N_RECORDS,
        "skip" = skip,
        "count" = TRUE
      ),
      add_headers(
        "subscription-key" = getOption("nhs_api_key")
      )
    )
    # if at any point our request fails, raise an error
    stopifnot(status_code(req) == 200)
    
    # get the content from the request and update the `data` to include this page
    res <- content(req)
    # safety check: we expect some data, raise an error if we don't get anything
    stopifnot(length(res$value) > 0)
    data <- c(data, res$value)
    
    # loop condition, if we ever reach or exceed number of records then exit the loop
    if (length(data) >= res$`@odata.count`) break()
    
    # update the `skip` value by the number of records we retrieve per page
    skip <- skip + N_RECORDS
    
    # the API has rate limitations, so we can add a bit of a delay between requests so we don't exceed these:
    # pause for 0.2s betweeen each request
    Sys.sleep(0.2)
  }
  
  data
})
```

We now need to convert this list to something more usable like a tibble.
Again, this isn’t meant to be a tutorial in data rectangling. Here is
the solution I came up with, utilising a few extra packages like `{sf}`
to make this useful for geospatial work, `janitor` to clean the names of
the columns, and `jsonlite` for some of the data items.

The process for getting to this code is largely to look at individual
records (e.g. `ae_sites_data[[1]]`) using tools like `lenght()` and
`names()` to get an idea for what the data contains,
`map_chr(ae_sites_data[[1]], class)` to have a look at what data type
each column contains, and lot’s of trial and error. One thing I would
suggest avoiding is just typing `your_data` into the R console and
dumping everything - you data could be very complex and take a long time
to print out, potentially even crashing R.

``` r
library(sf)
```

    ## Linking to GEOS 3.9.0, GDAL 3.2.1, PROJ 7.2.1

``` r
library(janitor)
```

    ## 
    ## Attaching package: 'janitor'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     chisq.test, fisher.test

``` r
library(jsonlite)
```

    ## 
    ## Attaching package: 'jsonlite'

    ## The following object is masked from 'package:purrr':
    ## 
    ##     flatten

``` r
data <- map_dfr(ae_sites_data, function(val) {
  # iterate over each of the items in the list, and for each `val`:
  val %>%
    # discard any item in the list where the value is `NULL` - this will cause problems when turning the list into a
    # tibble: any list that contains a NULL item will silently drop that "row" in the tibble
    discard(is.null) %>%
    # also, get rid of any item in the list where the item has a lenght of 0, e.g. no data
    discard(~length(.x) < 1) %>%
    # if the item is not a scalar value, wrap it in a list
    modify_if(~length(.x) > 1, list)
  # we use map_dfr, so the data will be converted to a tibble
}) %>%
         # modify the OpeningTimesV2: it starts off as a list, this will convert each list into a tibble
  mutate(across(OpeningTimesV2, map, bind_rows),
         # the Contacts and metrics columns are json strings, but some values are NA. Replace these NA's first with an
         # object that json will recognise (an empty array, []), then convert it from json to a list, then convert that
         # liust to a tibble
         across(c(Contacts, Metrics), map, purrr::compose(as_tibble, fromJSON, replace_na), "[]")) %>%
  # we have geospatial data, so we can use the {sf} package
  st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326) %>%
  # I prefer snake_case names as per tidyverse style guide, use {janitor} to clean these names up for us
  clean_names() %>%
  # get rid of columns I don't care for
  select(-opening_times, -geocode, -organisation_type_id, -organisation_status, -is_pims_managed, -pims_code) %>%
  # rename the opening_times_v2 column
  rename(opening_times = opening_times_v2)

data
```

    ## Simple feature collection with 159 features and 24 fields
    ## Geometry type: POINT
    ## Dimension:     XY
    ## Bounding box:  xmin: -6.309277 ymin: 49.91306 xmax: 1.717994 ymax: 55.07407
    ## Geodetic CRS:  WGS 84
    ## # A tibble: 159 x 25
    ##    search_score organisation_id organisation_name     organisation_ty~ nacs_code
    ##           <dbl> <chr>           <chr>                 <chr>            <chr>    
    ##  1            1 40719           Addenbrooke's         Hospital         RGT01    
    ##  2            1 40481           Aintree University H~ Hospital         REM21    
    ##  3            1 40270           Airedale General Hos~ Hospital         RCF22    
    ##  4            1 40195           Alder Hey Children's~ Hospital         RBS25    
    ##  5            1 42750           Alexandra Hospital    Hospital         RWP01    
    ##  6            1 72361           Barnet Hospital       Hospital         RAL26    
    ##  7            1 40570           Barnsley Hospital     Hospital         RFFAA    
    ##  8            1 40337           Basildon University ~ Hospital         RDDH0    
    ##  9            1 41260           Basingstoke and Nort~ Hospital         RN506    
    ## 10            1 41405           Bassetlaw Hospital    Hospital         RP5BA    
    ## # ... with 149 more rows, and 20 more variables: summary_text <chr>, url <chr>,
    ## #   address2 <chr>, city <chr>, county <chr>, organisation_sub_type <chr>,
    ## #   last_updated_date <chr>, postcode <chr>, services_provided <list>,
    ## #   service_codes_provided <list>, services_provided_conditions <list>,
    ## #   org_type_conditions <list>, contacts <list>, metrics <list>,
    ## #   opening_times <list>, organisation_aliases <list>, address1 <chr>,
    ## #   address3 <chr>, related_iaptcc_gs <list>, geometry <POINT [°]>

## Final thoughts

Working with Web API’s can be a great way to get data in an automated
and reproducible way. However, there is no “one-size fit’s all”
approach, which can be frustrating. It’s worth searching google to see
if someone has already created a package to do all the hardwork for you,
but if not you need to make sure you handle things like paging data,
checking for error messages and rate limiting yourself.
