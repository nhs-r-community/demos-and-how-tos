
# Download and Process the KH03 data

Each NHS Trust has so submit a report containing the amount of beds
available and occupied in a month. This report is called “KH03”, and is
available (by quarter) from April 2010 onwards.

The script in this folder will download and process these files. It does
not attempt to use the yearly versions which were available prior to
April 2010.

`{targets}` is used to orchestrate the downloading and processing of
files. There are two targets:

-   `kh03_files` goes to the NHS England [Bed Availability and
    Occupancy](https://www.england.nhs.uk/statistics/statistical-work-areas/bed-availability-and-occupancy/bed-data-overnight/)
    site and find’s the available files to download, using the `{rvest}`
    package. This target is set to always run, no matter what.
-   `kh03_data` then uses the list of files from the `kh03_files` target
    and will run the function `process_kh03_file()` for each of the
    available files. This target will only run for newly added items to
    the `kh03_files` list. In other words, we only will download and
    process each file once.

We can run the targets pipeline using the following:

``` r
library(targets)
tar_make()
```

Once targets has finished running we can save the data to an Rds/parquet
file for easier use outside of this targets environment.

``` r
suppressMessages({
  library(tidyverse)
  library(arrow)
})

kh03_data <- tar_read(kh03_data)

saveRDS(kh03_data, "kh03.Rds")

kh03_data |>
  unnest(by_specialty) |>
  write_parquet("kh03.parquet")
```
