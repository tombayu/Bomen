library(raster)
library(sf)
library(rgdal)
library(xml2)

rm(list = ls())

setwd("C:/Users/tombayu.hidayat/Documents/Internship/Planet/Baarn/")

directory <- list.dirs("C:/Users/tombayu.hidayat/Documents/Internship/Planet/Baarn/00_Unprocessed", full.names = T, recursive = F)
fNames <- list.dirs("C:/Users/tombayu.hidayat/Documents/Internship/Planet/Baarn/00_Unprocessed", full.names = F, recursive = F)

# Function to get the reflectance coefficient
getCoeff <- function(path) {
  doc <- read_xml(path)
  coeff <- xml_find_all(doc, ".//ps:reflectanceCoefficient")
  coeff <- xml_double(coeff)
  return(coeff)
}

# Function to mosaic the tiles
# For each time period..
# seq_along(directory)
for (i in 1:7) {
  print(fNames[[i]])
  tileDir <- list.dirs(directory[[i]], recursive = F)
  if (length(tileDir) > 1) {
    print("**Multi-scene data**")
    # Get the path of each scene
    rasList <- list.files(tileDir, full.names = T, pattern = glob2rx("*MS.tif"))
    xmlList <- list.files(tileDir, full.names = T, pattern = glob2rx("*.xml"))
    ras <- list()
    xml <- list()
    
    for (j in seq_along(rasList)) {
      # Read each rasterbrick and corresponding metadata
      ras[[j]] <- brick(rasList[[j]])
      xml[[j]] <- getCoeff(xmlList[[j]])
      # Apply the coefficient to normalize to TOA
      for (k in 1:4) {
        ras[[j]][[k]] <- ras[[j]][[k]] * xml[[j]][[k]]
      }
    }
    
    # Stitch and write.
    ras$fun <- mean
    ras$na.rm <- T
    print("Stitching..")
    stitched <- do.call(mosaic, ras)
    print("Writing raster..")
    writeRaster(stitched, paste0("02_Normalized/", fNames[[i]], ".tif"))
    print("Success!")
    
  } else {
    print("**Single-scene data**")
    # Get the path and coefficient of the data
    rasList <- list.files(tileDir, full.names = T, pattern = glob2rx("*MS.tif"))
    xmlList <- list.files(tileDir, full.names = T, pattern = glob2rx("*.xml"))
    ras <- brick(rasList)
    coeff <- getCoeff(xmlList)
    # Apply and write the new raster
    print("Applying coefficient..")
    for (j in 1:4) {
      ras[[j]] <- ras[[j]] * coeff[[j]]
    }
    print("Writing raster..")
    writeRaster(ras, paste0("02_Normalized/", fNames[[i]], ".tif"))
    print("Success!")
  }
}
