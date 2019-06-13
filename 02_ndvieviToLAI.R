library(raster)
library(sf)
library(rgdal)

rm(list = ls())
setwd("C:/Users/tombayu.hidayat/Documents/Internship/Planet/Baarn/")

filesNDVI <- list.files("03_NDVI/", full.names = T, pattern = glob2rx("*.tif"))
namesNDVI <- list.files("03_NDVI/", pattern = glob2rx("*.tif"))
fListNDVI <- list()

filesEVI <- list.files("03_EVI/", full.names = T, pattern = glob2rx("*.tif"))
namesEVI <- list.files("03_EVI/", pattern = glob2rx("*.tif"))
fListEVI <- list()
#seq_along(filesNDVI)
for (i in 21:22) {
  print(paste0("Start process for ", gsub("_ndvi.tif", ".tif", namesNDVI[[i]])))
  ndvi <- raster(filesNDVI[[i]])
  evi <- raster(filesEVI[[i]])
  # fListNDVI[[i]] <- raster(filesNDVI[[i]])
  # ras <- raster(filesNDVI[[i]])
  
  print("Calculating LAI..")
  print("Alexandridis et al. (2019) - EVI")
  lai1 <- (7.1751 * evi) - 0.8298
  print("Wang et al. (2005) - EVI")
  lai2 <- (7.9217 * evi) + 0.9508
  print("Wang et al. (2005) - NDVI")
  lai3 <- (23.299 * ndvi) - 13.203
  
  print("Writing..")
  print("1...")
  writeRaster(lai1, paste0("04_LAI/", gsub("_ndvi.tif", "_alex_evi.tif", namesNDVI[[i]])))
  print("2...")
  writeRaster(lai2, paste0("04_LAI/", gsub("_ndvi.tif", "_wang_evi.tif", namesNDVI[[i]])))
  print("3...")
  writeRaster(lai3, paste0("04_LAI/", gsub("_ndvi.tif", "_wang_ndvi.tif", namesNDVI[[i]])))
  print("Success!")
}

