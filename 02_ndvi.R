library(raster)
library(sf)
library(rgdal)

rm(list = ls())
setwd("C:/Users/tombayu.hidayat/Documents/Internship/Planet/Baarn/")

files <- list.files("02_Normalized/", full.names = T, pattern = glob2rx("*.tif"))
names <- list.files("02_Normalized/", pattern = glob2rx("*.tif"))
fList <- list()

for (i in seq_along(files)) {
  print(paste0("Start process for ", gsub(".tif", "_ndvi.tif", names[[i]])))
  fList[[i]] <- brick(files[[i]])
  print("Calculating NDVI..")
  ndvi <- (fList[[i]][[4]] - fList[[i]][[3]]) / (fList[[i]][[4]] + fList[[i]][[3]])
  print("Writing..")
  writeRaster(ndvi, paste0("03_NDVI/", gsub(".tif", "_ndvi.tif", names[[i]])))
  print("Success!")
}

