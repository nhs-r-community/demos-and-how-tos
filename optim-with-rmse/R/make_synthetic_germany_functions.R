# Functions for creating a synthetic Germany and selecting the optimal share of East and West Germany to produce it 

# Background: The Human Mortality Database (HMD) includes life expectancy data for Germany (DEUT), East Germany
# (DEUTE) and West Germany (DEUTW). Of course there are no population data for Germany prior to reunification, 
# but there are separate population data maintained for East and West German populations post-reunification. 

# This means DEUTE, DEUTW, and DEUT are reported for a number of common years. 

# The aim of this code is to produce a 'Synthetic Germany' for years prior to reunification. This 'Synthetic Germany'
# is based on a weighted average of East and West German population data. The weighting between these two populations
# is a parameter to determine based on an objective or loss function.
# A objective/loss function is a function that, given one or more numeric inputs (which can be varied), produces
# a single numeric output. The aim is to select the input that minimises the value returned by the function. 

# In this case, the input is the share of a value from the east german series (and so by implication the share
# of West Germany as well), and the output to try to minimise is the root-mean-square-error (RMSE) between the 
# observed life expectancy value from Germany as a whole, and the implied/simulated life expectancy value for 
# a synthetic Germany with the proposed East/West Germany share. 


# The following function makes a synthetic germany series with a particular east germany share (p_east)
# The inputs east_germany and west_germany need to be vectors of the the same length. 
# Additionally the proposed value p_east needs to be between 0 and 1. 

make_synthetic_population <- function(east_series, west_series, p_east){
  stopifnot("Series are of different lengths" = length(east_series) == length(west_series))
  stopifnot("Proportion out of possible bounds" = between(p_east, 0, 1))
  
  east_series * p_east + west_series * (1 - p_east)
}

# The following function compares a proposed synthetic germany series against the referenced/observed values
# The series need to be of the same length to allow them to be pairwise compared. 

# The arguments to what can be one of "RMSE', 'abs', and 'rel'
#  - The match.arg function checks that the input to this argument is one of the three valid inputs. 
#  - the default argument for what is RMSE

compare_synthetic_to_reference <- function(synthetic, reference, what = c("RMSE", "abs", "rel")){
  stopifnot("Synthetic and reference are different lengths" = length(synthetic) == length(reference))
  
  what <- match.arg(what)
  
  if (what == "RMSE"){
    out <- (synthetic - reference)^2 %>% 
      mean() %>% 
      .^(1/2)
    return(out)
  } else if (what == "abs"){
    return(synthetic - reference)
  } else if (what == "rel"){
    out <- (synthetic - reference)/reference
    return(out)
  } else {
    stop("Wrong what argument (which should have been caught earlier")
  }
  NULL
}


# The following function wraps up the two previous functions, including a default proposed p_east share of 0.2 (20%)

# It includes a number of checks that the inputs are of the expected format, and a function within which pulls 
# the columns and rows of interest to populate each series. 

compare_series_get_rmse <- function(data, p_east = 0.20,
                                    east_label = "DEUTE", west_label = "DEUTW", ref_label = "DEUTNP",
                                    comp_period = c(1990, 2010))
{
  
  stopifnot("data is not a dataframe"      = "data.frame" %in% class(e0_e65)         )
  stopifnot("proportion not valid"         = between(p_east, 0, 1)                   )
  stopifnot("comp_period not a range"      = length(comp_period) == 2                )
  stopifnot("comp_period values not valid" = comp_period %>% is.numeric() %>% all()  )
  
  # Get the series 
  extract_series <- function(data = data, code_label, comp_period){
    data %>% 
      filter(code == code_label) %>% 
      filter(between(year, comp_period[1], comp_period[2])) %>% 
      arrange(year) %>% 
      pull(ex)
  }
  
  
  message("getting East series")
  east_series <- extract_series(data, east_label, comp_period)
  message("getting West series")
  west_series <- extract_series(data, west_label, comp_period)
  message("getting reference series")
  ref_series  <- extract_series(data, ref_label,  comp_period)
  
  stopifnot("East/West series lengths differ" = length(east_series) == length(west_series))
  stopifnot("Ref series length differs from EastWest" = length(ref_series) == length(east_series))
  
  message("creating synthetic population and calculating RMSE")
  
  rmse <- make_synthetic_population(east_series, west_series, p_east = p_east) %>% 
    compare_synthetic_to_reference(reference = ref_series)
  
  stopifnot("rmse failed: not length 1" = length(rmse) == 1)
  stopifnot("rmse failed: not right class" = class(rmse) == "numeric")
  
  rmse
}

# The following function (with a function inside it!) runs the optim function and packs the inputs 
# in the way that optim expects. 


run_optim <- function(data){
  pack_for_optim <- function(par, data){
    p_east <- par["p_east"]
    data %>% compare_series_get_rmse(p_east = p_east)
  }
  optim(
    par = c(p_east = 0.5),
    fn = pack_for_optim, data = data,
    lower = 0, upper = 1,
    method = "L-BFGS-B"
  )
}
