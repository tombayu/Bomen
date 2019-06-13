library(bfast)

ndvi <- readRDS("C:/Users/tombayu.hidayat/Documents/Internship/Shiny/data/ndviData.rds")
date <- readRDS("C:/Users/tombayu.hidayat/Documents/Internship/Shiny/data/date.rds")

ndvi[,1]
data.frame("date" = date, "ndvi" = ndvi[,1])
