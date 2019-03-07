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
  #db_user <- 'root'
  #db_password <- 'sa12345678'
  #db_name <- 'cfe_calificados'
  #db_table <- 'pndmda'
  #db_host <- 'calificados.ckli9mh1ttmi.us-east-2.rds.amazonaws.com' # for local access
  #db_port <- 3306
  
  db_user <- 'root'
  db_password <- 'sa12345678'
  db_name <- 'sumex'
  db_host <- '192.168.1.81' # for local access
  db_port <- 3306

  # 3. Read data from db
  mydb <-  dbConnect(MySQL(), user = db_user, password = db_password, dbname = db_name, host = db_host, port = db_port)
  s <- paste0("select fecha, hora, precio_zonal from pndmda where zona_carga = 'MEXICALI' order by fecha, hora")
  rs <- dbSendQuery(mydb, s)
  dataframe <-  fetch(rs, n = -1)

  on.exit(dbDisconnect(mydb))
  
  x<-dataframe
  k<-7
  k<-k-1

  FORE<-c()
  for(j in 1:24){
    PML <- x$precio_zonal[x$hora==j]
    n<-length(PML)
    DataPML <-data.frame()
    for(i in 1:(n-k)){
      A<-PML[i:(i+k)]
      DataPML<-rbind.data.frame(DataPML,A)
    }
    Names<-c()
    for(i in 0:k)
      Names<-c(paste0('PML',i),Names)
    colnames(DataPML)<-Names
    DataPML$PML0[DataPML$PML0<=2000]<-0
    DataPML$PML0[DataPML$PML0>2000]<-1
    DataPML$PML0<-factor(DataPML$PML0)
    training <- DataPML
    trctrl <- trainControl(method = "repeatedcv", number = 15, repeats = 3)
    svm_Linear <- train(PML0 ~., data = training, method = "svmLinear",
                        trControl=trctrl,
                        preProcess = c("center", "scale"),
                        tuneLength = 10)
    abc<-t(data.frame(tail(PML,k)))
    colnames(abc)<-svm_Linear$coefnames
    test_pred <- predict(svm_Linear, newdata = abc)
    #print(test_pred)
    FORE[j]<-levels(test_pred)[test_pred]
  }
  forecast<-data.frame(1:24,FORE)
  colnames(forecast)<-c("Hora","Prediccion")
  #return(forecast)
  list(
    message = paste(forecast[2])
  )
}


