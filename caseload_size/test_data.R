
teams <- c("Apple", "Banana", "Clementine")
dates <- seq(as.Date("2017-01-01"), as.Date("2021-01-01"), "days")

# 5 columns- client id, referral id, team_desc, referral_date, discharge_date

test_frame <- purrr::map_dfr(1 : 100, function(x){
  
  rnum <- sample(1 : 5, 1)
  team_name <- sample(teams, rnum, replace = TRUE)
  ran_date <- sample(dates, rnum)
  
  tibble::tibble("client_id" = rep(x, rnum),
                "referral_id" = 1 : rnum,
                "team_desc" = team_name,
                "referral_date" = ran_date,
                "discharge_date" = ran_date + sample(7 : 365, 1))
  
})

test_frame[sample(nrow(test_frame), 100), "discharge_date"] = NA

