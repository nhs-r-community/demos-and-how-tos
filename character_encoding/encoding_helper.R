reprex({
  library(DBI)
  
  con <- DBI::dbConnect(odbc::odbc(),
                        Driver   = "MySQL ODBC 8.0 Unicode Driver",
                        Server   = Sys.getenv("HOST_NAME"),
                        UID      = Sys.getenv("DB_USER"),
                        PWD      = Sys.getenv("MYSQL_PASSWORD"),
                        Port     = 3306,
                        database = "SUCE",
                        encoding = "UTF-8")
  
  df <- data.frame(x = 1, y = "佃煮惣菜", z = "It's okay", a = "Zürich")
  dbWriteTable(con, 'test-utf8', df, temporary = TRUE)
  dbReadTable(con, 'test-utf8')
  
  dbDisconnect(con)
  
  ### SQLlite
  
  # Create an ephemeral in-memory RSQLite database
  con <- dbConnect(RSQLite::SQLite(), ":memory:")
  
  dbListTables(con)
  
  df <- data.frame(x = 1, y = "佃煮惣菜", z = "It's okay", a = "Zürich")
  dbWriteTable(con, 'test-utf8', df, temporary = TRUE)
  dbReadTable(con, 'test-utf8')
  
  dbDisconnect(con)
})
