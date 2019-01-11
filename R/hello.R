#' Hello World
#' 
#' Basic hello world function to be called from the demo app
#' 
#' @export
#' @param myname your name. Required.
#hello <- function(myname = ""){
#  if(myname == ""){
#    stop("Dime tu nombre!")
#  }
#  list(
#    message = paste("hello", myname, "! This is", R.Version()$version.string)
#  )
#}


hello<-function(myname = ""){
  #library(RODBC)
  library(RMySQL)
  library(caret)
  #channel <- odbcConnect("sumex")
  #dataframe <- RODBC::sqlQuery(channel, "
  #                      select fecha, hora, precio_zonal from
  #                             pnd_mda
  #                             where zona_carga = 'MEXICALI' order by
  #fecha, hora")
  #close(channel)
  db_user <- 'root'
  db_password <- 'sa12345678'
  db_name <- 'cfe_calificados'
  db_table <- 'pndmda'
  db_host <- 'calificados.ckli9mh1ttmi.us-east-2.rds.amazonaws.com' # for local access
  db_port <- 3306

  # 3. Read data from db
  mydb <-  dbConnect(MySQL(), user = db_user, password = db_password, dbname = db_name, host = db_host, port = db_port)
  s <- paste0("select fecha, hora, precio_zonal from pnd_mda where zona_carga = 'MEXICALI' order by fecha, hora")
  rs <- dbSendQuery(mydb, s)
  dataframe <-  fetch(rs, n = -1)

  on.exit(dbDisconnect(mydb))
  
  list(
    message = paste(dataframe)
)
}


