
# Function to setup project folder structure

project_setup <-function(){ 
  
  if(!dir.exists("data")){dir.create("data")}
  if(!dir.exists("plots")){dir.create("plots")}
  if(!dir.exists("Archive")){dir.create("Archive")}
  if(!dir.exists("Test")){dir.create("Test")}

} 

# Run code below to use function and create folder structure
project_setup()
