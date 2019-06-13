library(magrittr)
library(raster)
library(sp)
library(sf)
library(rgdal)

setwd("C:/Users/tombayu.hidayat/Documents/Internship/ProRail/40888/01_DTM")

xy <- list.files() %>%
  gsub(pattern = "LL", replacement = "", x = .) %>%
  gsub(pattern = ".laz", replacement = "", x = .) %>%
  strsplit(split = "_")

x <- list()
y <- list()

for (i in seq_along(xy)) {
  x[i] <- xy[[i]][1]
  y[i] <- xy[[i]][2]
}

x <- as.numeric(unlist(x))
y <- as.numeric(unlist(y))

df <- data.frame("x" = x, "y" = y)

spxy <- SpatialPoints(df)
crs <- "+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.417,50.3319,465.552,-0.398957,0.343988,-1.8774,4.0725 +units=m +no_defs"
attr <- data.frame("id" = 1:length(x))

spxy <- SpatialPointsDataFrame(coords = spxy, data = attr)
crs(spxy) <- crs
plot(spxy)

writeOGR(spxy, "C:/Users/tombayu.hidayat/Documents/spxy.shp", layer = "xy", driver = "ESRI Shapefile")

?writeOGR
