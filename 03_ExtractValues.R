library(sf)
library(sp)
library(rgdal)
library(raster)
library(tidyr)
library(xml2)
library(ggplot2)

rm(list = ls())
setwd("C:/Users/tombayu.hidayat/Documents/Internship/Planet/Baarn")

# Function to extract an info from XML
extractXML <- function(path, key) {
  doc <- read_xml(path)
  val <- xml_find_all(doc, key)
  val <- xml_text(val)
  return(val)
}
directory <- list.dirs("C:/Users/tombayu.hidayat/Documents/Internship/Planet/Baarn/00_Unprocessed", full.names = T, recursive = F)
date <- list()

for (i in seq_along(directory)) {
  dirs <- list.dirs(directory[[i]], recursive = F)
  for (j in seq_along(dirs)) {
    xmlPath <- list.files(dirs[[j]], pattern = glob2rx("*.xml"), full.names = T)
    date[[i]] <- extractXML(xmlPath, ".//eop:acquisitionDate")
  }
}

date <- strsplit(unlist(date), "T")
for (i in seq_along(date)) {
  date[[i]] <- date[[i]][1]
}
date <- as.Date(unlist(date))

# Load the supplementary data: extent, trees, railways lines..
trees <- readOGR("Supplementary/dummyTrees.geojson")
trees <- spTransform(trees, CRS("+init=epsg:32631"))
railways <- readOGR("Supplementary/spoorwegen.shp")
railways <- spTransform(railways, CRS("+init=epsg:32631"))
extent <- readOGR("Supplementary/Extent.shp")

# Load the NDVI bands, harmonize the extent
fList <- list.files("03_NDVI/", full.names = T, pattern = glob2rx("*.tif"))
ndvi <- list()
for (i in seq_along(fList)) {
  print(i)
  ndvi[[i]] <- raster(fList[[i]])
  ndvi[[i]] <- crop(ndvi[[i]], extent)
}

ndvi <- brick(ndvi)

# Extract the values!
ndviTrees <- raster::extract(ndvi, trees, fun = mean, df = T)
ndviTrees
colnames(ndviTrees) <- c("TreeID", as.character(date))
ndviTrees
ndviTrees[2:16]
new <- raster::extract(ndvi, trees, fun = mean, sp = T)
new
ggplot(ndviTrees)
