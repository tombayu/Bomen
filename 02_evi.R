library(raster)
library(sf)
library(rgdal)

rm(list = ls())
setwd("C:/Users/tombayu.hidayat/Documents/Internship/Planet/Baarn/")

files <- list.files("02_Normalized/", full.names = T, pattern = glob2rx("*.tif"))
names <- list.files("02_Normalized/", pattern = glob2rx("*.tif"))
fList <- list()

for (i in seq_along(files)) {
  print(paste0("Start process for ", gsub(".tif", "_evi.tif", names[[i]])))
  fList[[i]] <- brick(files[[i]])
  
  print("Calculating EVI..")
  nir <- fList[[i]][[4]]
  red <- fList[[i]][[3]]
  #blue <- fList[[i]][[1]]
  evi <- 2.5 * ((nir - red) / (nir + (2.4 * red) + 1))
  print("Writing..")
  writeRaster(evi, paste0("03_EVI/", gsub(".tif", "_evi.tif", names[[i]])))
  print("Success!")
}

