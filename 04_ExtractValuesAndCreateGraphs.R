library(sf)
library(sp)
library(rgdal)
library(raster)
library(tidyr)
library(xml2)
library(ggplot2)
library(magrittr)

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
saveRDS(date, "C:/Users/tombayu.hidayat/Documents/Internship/Shiny/data/date.rds")

# Load the supplementary data: extent, trees, railways lines..
# trees <- readOGR("Supplementary/dummyTrees.geojson")
trees <- readOGR("C:/Users/tombayu.hidayat/Documents/Internship/Shiny/data/KroonBuffer.geojson")
trees <- spTransform(trees, CRS("+init=epsg:32631"))
# railways <- readOGR("Supplementary/spoorwegen.shp")
# railways <- spTransform(railways, CRS("+init=epsg:32631"))
extent <- readOGR("Supplementary/Extent.shp")

# Load the NDVI bands, harmonize the extent
# NDVI
fList <- list.files("03_NDVI/", full.names = T, pattern = glob2rx("*.tif"))
ndvi <- list()
for (i in seq_along(fList)) {
  print(i)
  ndvi[[i]] <- raster(fList[[i]])
  ndvi[[i]] <- crop(ndvi[[i]], extent)
}

ndvi <- brick(ndvi)

# EVI
fList <- list.files("03_EVI/", full.names = T, pattern = glob2rx("*.tif"))
evi <- list()
for (i in seq_along(fList)) {
  print(i)
  evi[[i]] <- raster(fList[[i]])
  evi[[i]] <- crop(evi[[i]], extent)
}

evi <- brick(evi)

# LAI Alex - EVI
fList <- list.files("04_LAI/", full.names = T, pattern = glob2rx("*alex_evi.tif"))
lai1 <- list()
for (i in seq_along(fList)) {
  print(i)
  lai1[[i]] <- raster(fList[[i]])
  lai1[[i]] <- crop(lai1[[i]], extent)
}

lai1 <- brick(lai1)

# LAI Wang - EVI
fList <- list.files("04_LAI/", full.names = T, pattern = glob2rx("*wang_evi.tif"))
lai2 <- list()
for (i in seq_along(fList)) {
  print(i)
  lai2[[i]] <- raster(fList[[i]])
  lai2[[i]] <- crop(lai2[[i]], extent)
}

lai2 <- brick(lai2)

# LAI Wang  - NDVI
fList <- list.files("04_LAI/", full.names = T, pattern = glob2rx("*wang_ndvi.tif"))
lai3 <- list()
for (i in seq_along(fList)) {
  print(i)
  lai3[[i]] <- raster(fList[[i]])
  lai3[[i]] <- crop(lai3[[i]], extent)
}

lai3 <- brick(lai3)

# Extract the values!
# NDVI
ndviTrees <- raster::extract(ndvi, trees, fun = mean, df = T)
ndviTrees <- t(ndviTrees)[-1,]
saveRDS(ndviTrees, "C:/Users/tombayu.hidayat/Documents/Internship/Shiny/data/ndvi.rds")
# EVI
eviTrees <- raster::extract(evi, trees, fun = mean, df = T)
eviTrees <- t(eviTrees)[-1,]
saveRDS(eviTrees, "C:/Users/tombayu.hidayat/Documents/Internship/Shiny/data/evi.rds")
# LAI Alex - EVI
lai1Trees <- raster::extract(lai1, trees, fun = mean, df = T)
lai1Trees <- t(lai1Trees)[-1,]
saveRDS(lai1Trees, "C:/Users/tombayu.hidayat/Documents/Internship/Shiny/data/lai1.rds")
# LAI Wang - EVI
lai2Trees <- raster::extract(lai2, trees, fun = mean, df = T)
lai2Trees <- t(lai2Trees)[-1,]
saveRDS(lai2Trees, "C:/Users/tombayu.hidayat/Documents/Internship/Shiny/data/lai2.rds")
# LAI Wang - NDVI
lai3Trees <- raster::extract(lai3, trees, fun = mean, df = T)
lai3Trees <- t(lai3Trees)[-1,]
saveRDS(lai3Trees, "C:/Users/tombayu.hidayat/Documents/Internship/Shiny/data/lai3.rds")
#ndviTrees <- data.frame(date, ndviTrees)
#colnames(ndviTrees) <- c(1:(NCOL(ndviTrees)))
row.names(ndviTrees) <- NULL

# Input: ID of the tree, according to the FID
createPlot <- function(tree) {
  data <- data.frame("Date" = date, "NDVI" = ndviTrees[, (tree + 1)])
  plot <- ggplot(data, aes(Date, NDVI)) +
    geom_line(size = 1.5) +
    geom_point(shape = 21, size = 5, color = "black", fill = "white") +
    scale_x_date(date_labels = "%b-%Y", date_breaks = "3 month", date_minor_breaks = "1 month") +
    theme_light()
  return(plot)
}

createPlot(3111)

ggplot(ndviTrees)
