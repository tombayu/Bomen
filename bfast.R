library(bfast)
library(dplyr)

rm(list = ls())
setwd("C:/Users/tombayu.hidayat/Documents/Internship/Shiny/")

ndvi <- readRDS("data/ndvi.rds")
date <- readRDS("data/date.rds")

missingDate <- c("2017-05-01", "2017-11-01", "2018-01-01", "2019-01-01")
missingDate <- as.Date(missingDate, format = "%Y-%m-%d")
ndviSub <- ndvi[,100]
missingNdvi <- c(NA, NA, NA, NA)

completeNDVI <- data.frame("date" = c(date, missingDate), "ndvi" = c(ndviSub, missingNdvi))

completeNDVI <- arrange(completeNDVI, date)
tsNDVI <- ts(data = completeNDVI$ndvi, start = c(2017, 3), frequency = 12)

bfastmonitor(tsNDVI, response ~ trend + harmon, order = 3, start = c(2018, 4), plot = T)
