#  Code for using numerical optimisation for producing a 'Synthetic Germany' which has similar life expectancy 
# at birth and at age 65 to Germany as a whole (for estimating life expetancies in Germany as a whole prior to 
# reunification )

# An application of the optim function! 

# Author: Jon Minton
# Date: 23 Feb 2022

# First we need the packages
pacman::p_load(tidyverse, here)
# If getting from HMD directly we can use a script 
# get_data_from_hmd.R
# as follows
# pacman::p_load(HMDHFDplus)
# source(here("R", "get_data_from_hmd.R"))

# We need life expectancy at age 0 and 65, which we can get from the lifetables 

# We will load these lifetables directly (rather than using the script) 

# To allow this script to be self-contained we will refer to the github file location directly

hmd_lt <- read_rds("https://github.com/JonMinton/change-in-ex/blob/main/data/lifetables.rds?raw=true")

# We will now just look for German data, and for ages 0 and 65 only 

e0_e65 <- 
  hmd_lt  %>% 
    filter(Age %in% c(0, 65)) %>% 
    filter(str_detect(code, "DEU")) %>% 
    select(code, sex, year = Year, x = Age, ex) %>% 
    arrange(year) 


# For each combination of x and sex, I want to
# - pull the east series
# - pull the west series
# - pull the reference series 
# - find the proportion that minimises RMSE 


# For each of these want to 
# - pull the series for the right years in the east population
# - pull the series 

# We want to create a synthetic Germany for 1980-89 which is a 
# mixture of West and East German populations 

# We can load the various functions created for this purpose:

source(here("optim-with-rmse", "R", "make_synthetic_germany_functions.R"))

# The code below shows how I started: pulling out the series manually 
# and using a simple grid-search approach to find the value to the nearest 1%.

# Comparator period 1990-2010

# this pulls out the series of values for East Germany
east_series <- 
  e0_e65 %>% 
    filter(x == 0) %>% 
    filter(code == "DEUTE") %>% 
    filter(between(year, 1990, 2010)) %>% 
    filter(sex == "female") %>% 
    arrange(year) %>% 
    pull(ex)

# This pulls out out for West Germany 
west_series <- 
  e0_e65 %>% 
  filter(x == 0) %>% 
  filter(code == "DEUTW") %>% 
  filter(between(year, 1990, 2010)) %>% 
  filter(sex == "female") %>% 
  arrange(year) %>% 
  pull(ex)

# And this pulls it out for Germany as a whole
ref_series <-
  e0_e65 %>% 
  filter(x == 0) %>% 
  filter(code == "DEUTNP") %>% 
  filter(between(year, 1990, 2010)) %>% 
  filter(sex == "female") %>% 
  arrange(year) %>% 
  pull(ex)


# And this function looks at each percentage value for share of East Germany 
# between 0% and 100%, and pulls out the RMSE given this. 

grid_pshare <- 
  tibble(
    p_share = seq(0, 1, by = 0.01)
  ) %>% 
    mutate(
      rmse = map_dbl(
        p_share, 
        ~ make_synthetic_population(east_series, west_series, p_east = .x) %>% 
          compare_synthetic_to_reference(., reference = ref_series))
    )
# The contents of the mutate function are complicated. Probably too complicated. ;) 
# firstly they evoke map_dbl. This is a particular type of map function that forces the output 
# to be a numeric (double) value. This is what we want as RMSE should be a number, and won't be 
# a whole number (integer)

# The first argument map_dbl takes is p_share, this is the contents of the p_share column 
# created alongside the tibble in the previous step. 

# The next step is a function, make up of two steps joined together with the pipe operator %>%
# The use of the ~ at the start is tidyverse shorthand for 'function'. 
# The argument which will be varying is p_share. Unfortunately this isn't the first argument to the 
# first function - make_synthetic_population - which it's passed to. 
# By default, the map function, like the pipe operator, will pass to the first argument slot in the 
# function being passed to. To override this, the .x operator is used.
# This explicitly tells the map function where to put the argument of interest (p_share) in this case. 
# (.x is used because there are map2 functions, taking two inputs. The first of these is referred to as 
# .x, and the second as .y. This convention is also followed here for a single argument.)
# The result of the first step (before the pipe) of this operation in map_dbl is then passed to
# another function, compare_synthetic_to_reference, and fits in its first slot (marked with a . in this case)

# This isn't the most clear way of creating the operation. Instead, declaring a single function 
# beforehand would likely be easier to understand. However it's a fairly concise shorthand that works! 

# We can see the RMSE for each proposed p_east as follows:
grid_pshare

# And we can visualise the relationship between p_share and rmse as follows:

grid_pshare %>% 
  ggplot(aes(p_share, rmse)) + 
  geom_point()

# So, there's a clear minimal RMSE when around 20% (p = 0.20) is proposed. 

#Is it exactly 20%? Let's check
grid_pshare %>% 
  filter(rmse == min(rmse))

# Yes, it's at 20% exactly (to the nearest %)

# And what does the Synthetic Germany look like when this proposed mix is used? 

e0_e65 %>% 
  filter(code %in% c("DEUTE", "DEUTW", "DEUTNP")) %>% 
  filter(sex == "female") %>% 
  filter(x == 0) %>% 
  pivot_wider(names_from = code, values_from = ex, values_fill = NA)  %>% 
  arrange(year) %>% 
  mutate(DEUT_SYNTH = 0.2 * DEUTE + (1 - 0.2) * DEUTW) %>% 
  pivot_longer(cols = c("DEUTNP", "DEUTE", "DEUTW", "DEUT_SYNTH"), names_to = "code", values_to = "e0") %>% 
  ggplot(aes(x = year, y = e0, group = code, colour = code)) + 
  geom_line() +
  labs(
    x = "Year",
    y = "Life expectancy at birth",
    title = "Life expectancy for Synthetic Germany (DEUT_SYNTH) compared with Germany (DEUTNP)",
    subtitle = "Females only. DEUTE: East Germany; DEUTW: West Germany"
  )


# This is a slightly laborious process, however, involving quite a bit of manual copying and 
# pasting of bits of code. For example the above is only for females, and we might want to know 
# the equivalent value for males. We might also want to calculate life expectancy for different ages. 

# To start to automate further we can look at where the code above is repetitive, work out the 
# common patterns in the repeated sections of code, and build functions around them. 
# We can also look for where we've hard-coded values, and replace them with objects/references. 

# Within the functions developed, a function called get_series() within the compare_series_get_rmse 
# standardises the extraction of series. It looks as follows:

# extract_series <- function(data = data, code_label, comp_period){
#   data %>% 
#     filter(code == code_label) %>% 
#     filter(between(year, comp_period[1], comp_period[2])) %>% 
#     arrange(year) %>% 
#     pull(ex)
# }

# We can use this extract_series function within the broader function to get the RMSE for a given p_east 
# in fewer steps (for us)

e0_e65 %>% 
  filter(x == 0) %>% 
  filter(sex == "female") %>% 
  compare_series_get_rmse(data =., p_east = 0.2)

# This makes it easier to look for another manual combination of starting age (x) and sex

e0_e65 %>% 
  filter(x == 65) %>% 
  filter(sex == "male") %>% 
  compare_series_get_rmse(data =., p_east = 0.2)

# We can also use map_dbl and nesting to pass different datasets to this function

e0_e65 %>% 
  group_by(sex, x) %>% 
  nest() %>% 
  mutate(rmse = map_dbl(data, compare_series_get_rmse, p_east = 0.2))

# We can repeat the grid search approach by adding a third column, p_share, containing 
# a sequence of possible values of the p_east share. We can get all permutations of 
# data and p_share using expand_grid (or expand.grid) as follows:

expand_grid(
  e0_e65 %>% 
    group_by(sex, x) %>% 
    nest(), 
  p_share = seq(0, 1, by = 0.01)
) %>% 
  select(sex, x, p_share, data)

# Then we can pass to the function we used above to get the RMSE, as well as save to a new object

grid_search_pshares <- 
  expand_grid(
    e0_e65 %>% 
      group_by(sex, x) %>% 
      nest(), 
    p_share = seq(0, 1, by = 0.01)
  ) %>% 
  select(sex, x, p_share, data) %>% 
  mutate(rmse = map2_dbl(data, p_share, ~compare_series_get_rmse(data = .x, p_east = .y)))

grid_search_pshares
# This has now produced a lot of operations! 
# What does it show? 

grid_search_pshares %>% 
  ggplot(aes(x=p_share, y = rmse)) + 
  geom_line() + geom_point() + 
  facet_grid(sex ~ factor(x))

# So, it looks like approximately the same answer for each of the four groups. Let's check

grid_search_pshares %>% 
  group_by(x, sex) %>% 
  filter(rmse == min(rmse)) 

# So, to the nearest whole %, the proposed share is 20% except for males at age 65, where 
# it's 18%. 

# Using the grid search approach above, we could get more precise answers to the best share by 
# making the grid search 'mesh' smaller. For example, we could include the resolution 10% by changing 
# the by= argument in seq from 0.01 to 0.001.
# i.e. 
# grid_search_pshares <- 
#   expand_grid(
#     e0_e65 %>% 
#       group_by(sex, x) %>% 
#       nest(), 
#     p_share = seq(0, 1, by = 0.001) # change from by=0.01 here
#   ) %>% 
#   select(sex, x, p_share, data) %>% 
#   mutate(rmse = map2_dbl(data, p_share, ~compare_series_get_rmse(data = .x, p_east = .y)))

# But this would take ten times as long to run, as there are ten times as many values to consider. 

# We could also narrow the search space, to say between 0.15 and 0.25, and then narrow the mesh size too

# grid_search_pshares <- 
#   expand_grid(
#     e0_e65 %>% 
#       group_by(sex, x) %>% 
#       nest(), 
#     p_share = seq(0.15, 0.25, by = 0.001) # change from by=0.01, and start and end to 0.15 and 0.25 respectively
#   ) %>% 
#   select(sex, x, p_share, data) %>% 
#   mutate(rmse = map2_dbl(data, p_share, ~compare_series_get_rmse(data = .x, p_east = .y)))

# But again, we only know to do this because we first did the coarser search over the full range of values

# And now imagine if we wanted to do this for each individual age, or for many other countries 
# with similar East/West (or North/South) population breakdowns. Or for many different reference periods


# The grid search approach can quickly become too computationally intensive. That's where numerical 
# optimisation algorithms can be used instead.

# Within R, the standard function to use for numerical optimisation is optim.
# Optim passes a value or values to a function, and tries to get the smallest or largest value 
# out of this function, rejigging the value/values passed to the function multiple times until it can't 
# get a substantially improved (as in minimised/maximised) value from the function. 
# 

# To make the optim function work well with the functional programming approach used by the map functions
# I made a small wrapper function for optim:


# run_optim <- function(data){
#   pack_for_optim <- function(par, data){
#     p_east <- par["p_east"]
#     data %>% compare_series_get_rmse(p_east = p_east)
#   }
#   optim(
#     par = c(p_east = 0.5),
#     fn = pack_for_optim, data = data,
#     lower = 0, upper = 1,
#     method = "L-BFGS-B"
#   )
# }

# This function also specifies that a particular method, 'L-BFGS-B', which 
# gives performs bounded optimisation be used, along with the lower and upper bounds

# I've also given the algorithm a starting value of p = 0.5, which we might assume if we had 
# not looked at the data and performed the analysis previously. 

# Having done this packing, we now can use optim for each combination of age and sex to get the 
# best estimate for p_east in far fewer computational steps, and with much higher resolution

synth_germany_best_shares_via_optim <-
  e0_e65 %>% 
  group_by(sex, x) %>% 
  nest() %>% 
  mutate(
    optim_outputs = map(data, run_optim)
  ) %>% 
  mutate(
    optim_share = map_dbl(optim_outputs, pluck, "par")
  )

synth_germany_best_shares_via_optim

# The optim function contains a lot of additional information. For example, we could get the 
# best RMSE by interrogating the 'value' element as follows:

synth_germany_best_shares_via_optim %>% 
  mutate(
    rmse_at_optim_pshare = map_dbl(optim_outputs, pluck, "value")
  )

# So, the best value for RMSE was higher (worse) for males at birth, and lowest (better) for 
# males at age 65. 


# Summary
# optim, and the algorithms it evokes, are the workhorses of many numerical optimisation processes
# used in statistics, in particular for finding maximum likelihood for generalised linear models 
# such as logistic regression. In these cases unbounded rather than bounded estimation methods are used
# with log likelihood being used to allow the whole number spectrum to be considered.
# However optim is usually used at one or two steps removed, rather than directly. 
# In the above, we have an example where it evoked directly, and to optimise over an objective/loss 
# function other than log likelihood. 

# We have also considered how to start making sense of a specific problem (producing a 'synthetic germany'
# when no unified Germany existed), and how to move towards more automated and standardised ways of 
# solving such problems in more general cases through functions and functional programming.


