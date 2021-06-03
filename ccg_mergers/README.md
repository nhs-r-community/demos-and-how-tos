ccg mergers
================
[Tom Jemmett](mailto:thomas.jemmett@nhs.net) \| The Strategy Unit
[su\_web](https://www.strategyunitwm.nhs.uk/)
02/06/2021

When the
[CCG](https://www.england.nhs.uk/commissioning/who-commissions-nhs-services/ccgs/)’s
were first introduced in April 2013 there were 211 CCG’s. But since then
a series of mergers have reduced the number to
[106](https://geoportal.statistics.gov.uk/datasets/48fc517976fd495c80a2fbde97b103e6_0/explore)
(as of April 2021).

This document shows how we can easily find the list of successors to
CCG’s. We will use the `{NHSRtools}` package, which is currently only
available on github. You can install it by running:

``` r
devtools::install_github("NHS-R-Community/NHSRtools")
```

## Getting the data

First, let’s get a list of all of the CCG’s that have ever existed from
the [ODS
API](https://digital.nhs.uk/services/organisation-data-service/guidance-for-developers/search-endpoint).
The API returns not only the CCG’s but also commisioning hubs, so we
simply filter the list to only include rows where the name starts with
“NHS” and ends in “CCG”.

``` r
ccgs <- NHSRtools::ods_get_ccgs() |>
  select(name, org_id, last_change_date, status) |>
  filter(str_detect(name, "^NHS .* CCG$"))

ccgs
```

    ## # A tibble: 248 x 4
    ##    name                                          org_id last_change_date status 
    ##    <chr>                                         <chr>  <chr>            <chr>  
    ##  1 NHS AIREDALE, WHARFEDALE AND CRAVEN CCG       02N    2021-05-18       Inacti~
    ##  2 NHS ASHFORD CCG                               09C    2021-05-20       Inacti~
    ##  3 NHS AYLESBURY VALE CCG                        10Y    2021-05-28       Inacti~
    ##  4 NHS BARKING AND DAGENHAM CCG                  07L    2021-05-17       Active 
    ##  5 NHS BARNET CCG                                07M    2021-06-01       Inacti~
    ##  6 NHS BARNSLEY CCG                              02P    2021-06-01       Active 
    ##  7 NHS BASILDON AND BRENTWOOD CCG                99E    2021-06-01       Active 
    ##  8 NHS BASSETLAW CCG                             02Q    2021-06-01       Active 
    ##  9 NHS BATH AND NORTH EAST SOMERSET CCG          11E    2021-05-18       Inacti~
    ## 10 NHS BATH AND NORTH EAST SOMERSET, SWINDON AN~ 92G    2021-06-01       Active 
    ## # ... with 238 more rows

This returns `nrow(ccgs)` rows - more than the original 211. This
includes all of the active and inactive CCG’s.

Next we download the [successors
files](https://digital.nhs.uk/services/organisation-data-service/data-downloads/miscellaneous).
This file is for all organisation types and includes the previous
organisation, the new organisation, and the date when the change
occured. We perform a semi-join to the list of CCG’s in order to filter
the list to exclude other organisation types.

``` r
ccg_successors <- NHSRtools::ods_get_successors() |>
  semi_join(ccgs, by = c("old_code" = "org_id")) |>
  select(old_code, new_code, effective_date)

ccg_successors
```

    ## # A tibble: 142 x 3
    ##    old_code new_code effective_date
    ##    <chr>    <chr>    <date>        
    ##  1 00C      16C      2020-04-01    
    ##  2 00D      84H      2020-04-01    
    ##  3 00J      84H      2020-04-01    
    ##  4 00K      16C      2020-04-01    
    ##  5 00M      16C      2020-04-01    
    ##  6 01C      27D      2020-04-01    
    ##  7 01R      27D      2020-04-01    
    ##  8 02D      27D      2020-04-01    
    ##  9 02F      27D      2020-04-01    
    ## 10 02N      36J      2020-04-01    
    ## # ... with 132 more rows

### Checking the successors data

One thing we should check is have there been any cases where one CCG has
split into two? We can achieve this with `{dplyr}` by grouping on the
`old_code` column and seeing if there are any groups with more than 1
row (`n() > 1`).

``` r
ccg_successors |>
  group_by(old_code) |>
  filter(n() > 1)
```

    ## # A tibble: 0 x 3
    ## # Groups:   old_code [0]
    ## # ... with 3 variables: old_code <chr>, new_code <chr>, effective_date <date>

Fortunately there have been none of these cases - this makes life a lot
easier if we want to reassign old CCG’s to newer ones as we can simply
join and update.

However, one more question we should ask is have there been any cases
where CCG A merged into CCG B, and CCG B merged into CCG C?

If there were not, we could run something simple like:

``` r
ccgs |>
  rename(old_code = org_id) |>
  mutate(new_code = old_code, .after = old_code) |>
  rows_update(ccg_successors |> select(old_code, new_code), by = "old_code")
```

We can test to see if there are any of the problematic mergers by simply
joining the `ccg_successors` table to itself, like so:

``` r
inner_join(
  ccg_successors,
  ccg_successors,
  by = c("new_code" = "old_code")
)
```

    ## # A tibble: 3 x 5
    ##   old_code new_code effective_date.x new_code.y effective_date.y
    ##   <chr>    <chr>    <date>           <chr>      <date>          
    ## 1 10G      15D      2018-04-01       D4U1Y      2021-04-01      
    ## 2 10T      15D      2018-04-01       D4U1Y      2021-04-01      
    ## 3 11C      15D      2018-04-01       D4U1Y      2021-04-01

There has been a case where this has happened, so simply joining to our
dataset will not work - consider we are looking at 2016 data and we have
a row for CCG “10G”. We join to `ccg_successors` and we get the code
“15D”. But “15D” became “D3U1Y” in 2021, so we would need to repeat this
process again to get the correct result. Something like

``` r
ccgs |>
  rename(old_code = org_id) |>
  mutate(new_code = old_code, .after = old_code) |>
  rows_update(ccg_successors |> select(old_code, new_code), by = "old_code") |>
  rows_update(inner_join(
    ccg_successors,
    ccg_successors,
    by = c("new_code" = "old_code")
  ) |> select(old_code, new_code = new_code.y), by = "old_code")
```

This is pretty messy, and what happens if next year D4U1Y mergers with
another CCG? This is a problem that would be best solved with a
[graph](https://en.wikipedia.org/wiki/Graph_(abstract_data_type)).

## Creating CCG graph

We will use two packages for creating and working with our graph -
`{igraph}` and `{tidygraph}`.

``` r
g <- graph_from_data_frame(
  ccg_successors,
  vertices = select(ccgs, org_id, ccg_description = name, status)
) |>
  as_tbl_graph() |>
  activate(edges) |>
  # when using tidygraph the date column is converted to a number, convert back to a date
  mutate(across(effective_date, as_date))
```

`{tidygraph}` makes it much easier to work with graphs, using a very
similar syntax to `{dplyr}`. The big difference is there are two
dataframes we are working with - one for the edges and one for the
vertices.

We can add extra columns to our vertices - we want to add in the date
that the CCG was “active” from and when it was “active” to. We can get
this from the edges that are “incident” to the vertex. To find the
“active to” date we look at the edge that is coming out of the vertex,
and default to `NA`. For the “active from” date we look at the edges
that are coming in to the vertex and select the first item only, using
April 2013 as the default.

``` r
find_active_to_date <- function(vertex, graph) {
  c(incident_edges(graph, vertex, "out")[[1]]$effective_date %m-% days(1), as_date(NA))[[1]]
}

find_active_from_date <- function(vertex, graph) {
  c(incident_edges(graph, vertex, "in")[[1]]$effective_date, ymd(20130401))[[1]]
}
```

We can also add a column to find the current CCG to use. We recursively
search vertices to find neighbours by following “out” edges. If we have
no neighbours at any vertex we simply return that vertex as the current
CCG.

``` r
# repeatadly search the neighbours of a vertex to find the current ccg - each vertex only has one "out" edge, so we
# don't have to worry about selecting one of the neighbours
find_current_ccg <- function(v, graph) {
  n <- neighbors(graph, v)$name
  # if we find no neighbours then we simply return the vertex that we are at
  if (length(n) == 0) return(v)
  # recurisvely call this function to find the current ccg
  find_current_ccg(n, graph) 
}
```

Now we can update our graph to add in these new columns.

``` r
g <- g |>
  activate(nodes) |>
  mutate(active_from = map_dbl(name, find_active_from_date, .G()) |> as_date(),
         active_to = map_dbl(name, find_active_to_date, .G()) |> as_date(),
         current_ccg = map_chr(name, find_current_ccg, graph = .G()))
g
```

    ## # A tbl_graph: 248 nodes and 142 edges
    ## #
    ## # A rooted forest with 106 trees
    ## #
    ## # Node Data: 248 x 6 (active)
    ##   name  ccg_description               status  active_from active_to  current_ccg
    ##   <chr> <chr>                         <chr>   <date>      <date>     <chr>      
    ## 1 02N   NHS AIREDALE, WHARFEDALE AND~ Inacti~ 2013-04-01  2020-03-31 36J        
    ## 2 09C   NHS ASHFORD CCG               Inacti~ 2013-04-01  2020-03-31 91Q        
    ## 3 10Y   NHS AYLESBURY VALE CCG        Inacti~ 2013-04-01  2018-03-31 14Y        
    ## 4 07L   NHS BARKING AND DAGENHAM CCG  Active  2013-04-01  2021-03-31 A3A8R      
    ## 5 07M   NHS BARNET CCG                Inacti~ 2013-04-01  2020-03-31 93C        
    ## 6 02P   NHS BARNSLEY CCG              Active  2013-04-01  NA         02P        
    ## # ... with 242 more rows
    ## #
    ## # Edge Data: 142 x 3
    ##    from    to effective_date
    ##   <int> <int> <date>        
    ## 1    52   218 2020-04-01    
    ## 2    59    47 2020-04-01    
    ## 3   143    47 2020-04-01    
    ## # ... with 139 more rows

We can confirm that this works for the edge case that we looked at above

``` r
g |>
  activate(nodes) |>
  filter(current_ccg == "D4U1Y") |>
  arrange(active_from, ccg_description)
```

    ## # A tbl_graph: 7 nodes and 6 edges
    ## #
    ## # A rooted tree
    ## #
    ## # Node Data: 7 x 6 (active)
    ##   name  ccg_description               status  active_from active_to  current_ccg
    ##   <chr> <chr>                         <chr>   <date>      <date>     <chr>      
    ## 1 10G   NHS BRACKNELL AND ASCOT CCG   Inacti~ 2013-04-01  2018-03-31 D4U1Y      
    ## 2 99M   NHS NORTH EAST HAMPSHIRE AND~ Active  2013-04-01  2021-03-31 D4U1Y      
    ## 3 10T   NHS SLOUGH CCG                Inacti~ 2013-04-01  2018-03-31 D4U1Y      
    ## 4 10C   NHS SURREY HEATH CCG          Active  2013-04-01  2021-03-31 D4U1Y      
    ## 5 11C   NHS WINDSOR, ASCOT AND MAIDE~ Active  2013-04-01  2018-03-31 D4U1Y      
    ## 6 15D   NHS EAST BERKSHIRE CCG        Active  2018-04-01  2021-03-31 D4U1Y      
    ## # ... with 1 more row
    ## #
    ## # Edge Data: 6 x 3
    ##    from    to effective_date
    ##   <int> <int> <date>        
    ## 1     4     7 2021-04-01    
    ## 2     6     7 2021-04-01    
    ## 3     2     7 2021-04-01    
    ## # ... with 3 more rows

## Visualising the graph

We can now visualise all of the CCG’s and the mergers. The `{ggraph}`
package works well if you want to use `ggplot`, but I would prefer to be
able to have a more interactive graph. We can use `{plotly}`, but there
isn’t a neat way of getting plots of graphs, you have to handle all of
the edge shapes yourself.

``` r
ggraph(g, layout = "nicely") +
  geom_edge_link(arrow = arrow(length = unit(1, "mm")),
                 end_cap = circle(2, "mm")) +
  geom_node_point(aes(colour = format(active_from, "%b-%y"))) +
  scale_colour_brewer(type = "div", palette = "Dark2") +
  labs(colour = "") +
  theme(panel.background = element_blank(),
        legend.title = element_blank(),
        legend.key = element_blank(),
        legend.position = "bottom")
```

![](README_files/figure-gfm/visualise%20graph-1.png)<!-- -->

## Getting previous mappings

We may not want to map to the 2021 CCG’s though, it may be that we want
to create a mapping from previous years to the 2019 CCG’s. This is
really simple with `{tidygraph}`, we can simply activate the edges,
filter the results to only include edges that were effective on or
before that date, then do the same with the vertices. We just need to
recreate the `active_to` and `current_ccg` columns, as these need to
reflect the 2019 data.

``` r
g |>
  activate(edges) |>
  filter(effective_date <= ymd(20190401)) |>
  activate(nodes) |>
  filter(active_from <= ymd(20190401)) |>
  mutate(active_to = map_dbl(name, find_active_to_date, .G()) |> as_date(),
         current_ccg = map_chr(name, find_current_ccg, graph = .G()))
```

    ## # A tbl_graph: 221 nodes and 30 edges
    ## #
    ## # A rooted forest with 191 trees
    ## #
    ## # Node Data: 221 x 6 (active)
    ##   name  ccg_description               status  active_from active_to  current_ccg
    ##   <chr> <chr>                         <chr>   <date>      <date>     <chr>      
    ## 1 02N   NHS AIREDALE, WHARFEDALE AND~ Inacti~ 2013-04-01  NA         02N        
    ## 2 09C   NHS ASHFORD CCG               Inacti~ 2013-04-01  NA         09C        
    ## 3 10Y   NHS AYLESBURY VALE CCG        Inacti~ 2013-04-01  2018-03-31 14Y        
    ## 4 07L   NHS BARKING AND DAGENHAM CCG  Active  2013-04-01  NA         07L        
    ## 5 07M   NHS BARNET CCG                Inacti~ 2013-04-01  NA         07M        
    ## 6 02P   NHS BARNSLEY CCG              Active  2013-04-01  NA         02P        
    ## # ... with 215 more rows
    ## #
    ## # Edge Data: 30 x 3
    ##    from    to effective_date
    ##   <int> <int> <date>        
    ## 1    67   119 2015-04-01    
    ## 2   120   119 2015-04-01    
    ## 3   121   119 2015-04-01    
    ## # ... with 27 more rows

## Getting a tibble of the mergers

It just remains to see how we can get out a tibble of the mergers. We
can take advantage of `{tidygraph}` by activating the vertices and
running `as_tibble()` to get the data as a tibble that we can easily
work with.

``` r
g |>
  activate(nodes) |>
  as_tibble()
```

    ## # A tibble: 248 x 6
    ##    name  ccg_description               status active_from active_to  current_ccg
    ##    <chr> <chr>                         <chr>  <date>      <date>     <chr>      
    ##  1 02N   NHS AIREDALE, WHARFEDALE AND~ Inact~ 2013-04-01  2020-03-31 36J        
    ##  2 09C   NHS ASHFORD CCG               Inact~ 2013-04-01  2020-03-31 91Q        
    ##  3 10Y   NHS AYLESBURY VALE CCG        Inact~ 2013-04-01  2018-03-31 14Y        
    ##  4 07L   NHS BARKING AND DAGENHAM CCG  Active 2013-04-01  2021-03-31 A3A8R      
    ##  5 07M   NHS BARNET CCG                Inact~ 2013-04-01  2020-03-31 93C        
    ##  6 02P   NHS BARNSLEY CCG              Active 2013-04-01  NA         02P        
    ##  7 99E   NHS BASILDON AND BRENTWOOD C~ Active 2013-04-01  NA         99E        
    ##  8 02Q   NHS BASSETLAW CCG             Active 2013-04-01  NA         02Q        
    ##  9 11E   NHS BATH AND NORTH EAST SOME~ Inact~ 2013-04-01  2020-03-31 92G        
    ## 10 92G   NHS BATH AND NORTH EAST SOME~ Active 2020-04-01  NA         92G        
    ## # ... with 238 more rows

## Session Info

``` r
devtools::session_info()
```

    ## - Session info ---------------------------------------------------------------
    ##  setting  value                       
    ##  version  R version 4.1.0 (2021-05-18)
    ##  os       Windows 10 x64              
    ##  system   x86_64, mingw32             
    ##  ui       RTerm                       
    ##  language (EN)                        
    ##  collate  English_United Kingdom.1252 
    ##  ctype    English_United Kingdom.1252 
    ##  tz       Europe/London               
    ##  date     2021-06-02                  
    ## 
    ## - Packages -------------------------------------------------------------------
    ##  package      * version    date       lib
    ##  assertthat     0.2.1      2019-03-21 [1]
    ##  backports      1.2.1      2020-12-09 [1]
    ##  broom          0.7.6      2021-04-05 [1]
    ##  cachem         1.0.5      2021-05-15 [1]
    ##  callr          3.7.0      2021-04-20 [1]
    ##  cellranger     1.1.0      2016-07-27 [1]
    ##  class          7.3-19     2021-05-03 [1]
    ##  classInt       0.4-3      2020-04-07 [1]
    ##  cli            2.5.0      2021-04-26 [1]
    ##  colorspace     2.0-1      2021-05-04 [1]
    ##  crayon         1.4.1      2021-02-08 [1]
    ##  curl           4.3.1      2021-04-30 [1]
    ##  data.table     1.14.0     2021-02-21 [1]
    ##  DBI            1.1.1      2021-01-15 [1]
    ##  dbplyr         2.1.1      2021-04-06 [1]
    ##  desc           1.3.0      2021-03-05 [1]
    ##  devtools       2.4.1      2021-05-05 [1]
    ##  digest         0.6.27     2020-10-24 [1]
    ##  dplyr        * 1.0.6      2021-05-05 [1]
    ##  e1071          1.7-7      2021-05-23 [1]
    ##  ellipsis       0.3.2      2021-04-29 [1]
    ##  evaluate       0.14       2019-05-28 [1]
    ##  fansi          0.4.2      2021-01-15 [1]
    ##  farver         2.1.0      2021-02-28 [1]
    ##  fastmap        1.1.0      2021-01-25 [1]
    ##  forcats      * 0.5.1      2021-01-27 [1]
    ##  fs             1.5.0      2020-07-31 [1]
    ##  generics       0.1.0      2020-10-31 [1]
    ##  ggforce        0.3.3      2021-03-05 [1]
    ##  ggplot2      * 3.3.3      2020-12-30 [1]
    ##  ggraph       * 2.0.5      2021-02-23 [1]
    ##  ggrepel        0.9.1      2021-01-15 [1]
    ##  glue           1.4.2      2020-08-27 [1]
    ##  graphlayouts   0.7.1      2020-10-26 [1]
    ##  gridExtra      2.3        2017-09-09 [1]
    ##  gtable         0.3.0      2019-03-25 [1]
    ##  haven          2.4.1      2021-04-23 [1]
    ##  highr          0.9        2021-04-16 [1]
    ##  hms            1.1.0      2021-05-17 [1]
    ##  htmltools      0.5.1.1    2021-01-22 [1]
    ##  htmlwidgets    1.5.3      2020-12-10 [1]
    ##  httr           1.4.2      2020-07-20 [1]
    ##  igraph       * 1.2.6      2020-10-06 [1]
    ##  janitor        2.1.0      2021-01-05 [1]
    ##  jsonlite       1.7.2      2020-12-09 [1]
    ##  KernSmooth     2.23-20    2021-05-03 [1]
    ##  knitr          1.33       2021-04-24 [1]
    ##  labeling       0.4.2      2020-10-20 [1]
    ##  lazyeval       0.2.2      2019-03-15 [1]
    ##  lifecycle      1.0.0      2021-02-15 [1]
    ##  lubridate    * 1.7.10     2021-02-26 [1]
    ##  magrittr       2.0.1      2020-11-17 [1]
    ##  MASS           7.3-54     2021-05-03 [1]
    ##  memoise        2.0.0      2021-01-26 [1]
    ##  modelr         0.1.8      2020-05-19 [1]
    ##  munsell        0.5.0      2018-06-12 [1]
    ##  NHSRtools      0.0.0.9001 2021-05-19 [1]
    ##  pillar         1.6.1      2021-05-16 [1]
    ##  pkgbuild       1.2.0      2020-12-15 [1]
    ##  pkgconfig      2.0.3      2019-09-22 [1]
    ##  pkgload        1.2.1      2021-04-06 [1]
    ##  plotly       * 4.9.3      2021-01-10 [1]
    ##  polyclip       1.10-0     2019-03-14 [1]
    ##  prettyunits    1.1.1      2020-01-24 [1]
    ##  processx       3.5.2      2021-04-30 [1]
    ##  proxy          0.4-25     2021-03-05 [1]
    ##  ps             1.6.0      2021-02-28 [1]
    ##  purrr        * 0.3.4      2020-04-17 [1]
    ##  R6             2.5.0      2020-10-28 [1]
    ##  RColorBrewer   1.1-2      2014-12-07 [1]
    ##  Rcpp           1.0.6      2021-01-15 [1]
    ##  readr        * 1.4.0      2020-10-05 [1]
    ##  readxl         1.3.1      2019-03-13 [1]
    ##  remotes        2.3.0      2021-04-01 [1]
    ##  reprex         2.0.0      2021-04-02 [1]
    ##  rlang          0.4.11     2021-04-30 [1]
    ##  rmarkdown      2.8        2021-05-07 [1]
    ##  rprojroot      2.0.2      2020-11-15 [1]
    ##  rstudioapi     0.13       2020-11-12 [1]
    ##  rvest          1.0.0      2021-03-09 [1]
    ##  scales         1.1.1      2020-05-11 [1]
    ##  sessioninfo    1.1.1      2018-11-05 [1]
    ##  sf             0.9-8      2021-03-17 [1]
    ##  snakecase      0.11.0     2019-05-25 [1]
    ##  stringi        1.6.1      2021-05-10 [1]
    ##  stringr      * 1.4.0      2019-02-10 [1]
    ##  testthat       3.0.2      2021-02-14 [1]
    ##  tibble       * 3.1.2      2021-05-16 [1]
    ##  tidygraph    * 1.2.0      2020-05-12 [1]
    ##  tidyr        * 1.1.3      2021-03-03 [1]
    ##  tidyselect     1.1.1      2021-04-30 [1]
    ##  tidyverse    * 1.3.1      2021-04-15 [1]
    ##  tweenr         1.0.2      2021-03-23 [1]
    ##  units          0.7-1      2021-03-16 [1]
    ##  usethis        2.0.1      2021-02-10 [1]
    ##  utf8           1.2.1      2021-03-12 [1]
    ##  vctrs          0.3.8      2021-04-29 [1]
    ##  viridis        0.6.1      2021-05-11 [1]
    ##  viridisLite    0.4.0      2021-04-13 [1]
    ##  withr          2.4.2      2021-04-18 [1]
    ##  xfun           0.23       2021-05-15 [1]
    ##  xml2           1.3.2      2020-04-23 [1]
    ##  yaml           2.2.1      2020-02-01 [1]
    ##  zeallot      * 0.1.0      2018-01-28 [1]
    ##  source                                    
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  Github (NHS-R-Community/NHSRtools@070b7d0)
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ##  CRAN (R 4.1.0)                            
    ## 
    ## [1] C:/Program Files/R/R-4.1.0/library
