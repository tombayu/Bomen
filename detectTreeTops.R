# An attempt to extract stem of the trees.

rm(list = ls())

library(lidR)
library(raster)
library(dplyr)
library(rgl)
library(rgdal)
library(sf)

setwd("C:/Users/tombayu.hidayat/Documents/Data/")

# Read the file
las <- readLAS("detectTreeTops.las")

# Classify the ground point
las <- lasground(las, csf())
plot(las, color = "Classification")

# Normalise the height
# Set the gound at 0.
las <- lasnormalize(las, tin())
plot(las)
setwd("C:/Users/tombayu.hidayat/Documents/Tree Extraction/Results/Extraction_Color/")

# Extract the trees, by first detecting the tree tops.
treeTops <- tree_detection(las, lmf(ws = 6))
#treeTopsManual <- tree_detection(las, manual(detected = treeTops))
#saveRDS(treeTopsManual, file = "treetops.rds")
treeTopsManual <- readRDS("treetops.rds")
treeTopsManual <- tree_detection(las, manual(detected = treeTops))


#st_transform(treeTopsManual, CRS("+init=epsg:4326"))
writeOGR(treeTopsManual, "treeTops.shp", layer = "treeTops", driver = "ESRI Shapefile")
treet <- readOGR("treeTops.shp")
treet
treet <- spTransform(treet, CRS("+init=epsg:4326"))
writeOGR(treet, "treeTops.kml", layer = "treeTops", driver = "KML")
writeOGR(treet, "treeTopsPrj.shp", layer = "treeTops", driver = "ESRI Shapefile")


unique(las@data$ReturnNumber)

# Construct Canopy Height Model
chm_pit <- grid_canopy(las, 0.1, pitfree(c(0,2,5,10,15), c(0,1), subcircle = 0.1))
treeSilva <- lastrees(las, silva2016(chm_pit, treeTopsManual))
treeSilva <- lasfilter(treeSilva, !is.na(treeID))
trunk <- lasfilter(treeSilva, NumberOfReturns == 1)
trunk <- lasfilter(trunk, Classification == 1)
plot(trunk)
plot(treeSilva, color = "NumberOfReturns")
unique(treeSilva@data$NumberOfReturns)

las@data$ReturnNumber
plot(treeSilva, color = "treeID")
