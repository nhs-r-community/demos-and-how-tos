

get_data <- function(){
  print("GETTING SOME DATA")
  Sys.sleep(3)
  print("Boy this is taking a while....")
  Sys.sleep(3)
  print("I wonder if there's time to get a cup of tea...")
  Sys.sleep(5)
  print("OK it's finished.")
  tibble(a=c(1,2,3), b=c(4,5,6))
}