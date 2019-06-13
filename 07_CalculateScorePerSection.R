library(sf)
library(sp)
library(rgdal)
library(raster)
library(magrittr)

rm(list = ls())
setwd("C:/Users/tombayu.hidayat/Documents/Internship/ProRail")

# The geodatabases
input <- "InputData.gdb"
result <- "Result.gdb"
# Read the data from it!
spoor <- readOGR(input, "SpoorSplit")
trees <- readOGR(result, "D_LeafyTree")

# Make a buffer around the spoor lines, per section
spoorBuffer <- buffer(spoor, 30, dissolve = F)
sections <- as.character(spoorBuffer@data$TrackID)
score <- list()

for (i in seq_along(sections)) {
  print(i)
  s <- spoorBuffer[spoorBuffer$TrackID == sections[i], ] %>%
    intersect(trees)
  # plot(s, main = sections[[i]])
  score[i] <- sum(s@data$LEAFSCORE)
}

sectionScores <- data.frame("TrackID" = sections, "Score"= unlist(score))
scoredSpoor <- sp::merge(spoor, sectionScores, by = "TrackID")

writeOGR(scoredSpoor, dsn = "Result", layer = "E_ScoredSpoor", driver = "ESRI Shapefile")
writeOGR(scoredSpoor, dsn = "Result/ScoredSpoor.geojson", "ScoredSpoor", driver = "GeoJSON")
