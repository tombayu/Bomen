library(rgdal)
library(sp)
library(raster)

rm(list = ls())

setwd("C:/Users/tombayu.hidayat/Documents/Internship/ProRail/Extent/")

spoor <- readOGR("C:/Users/tombayu.hidayat/Documents/Internship/ProRail/Extent/SpoorSplit.shp")
spoor <- spTransform(spoor, CRS("+init=epsg:4326"))

kroon <- readOGR("C:/Users/tombayu.hidayat/Documents/Internship/ProRail/Extent/Kroon.shp")
crs(kroon) <- "+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.417,50.3319,465.552,-0.398957,0.343988,-1.8774,4.0725 +units=m +no_defs"
kroon$id <- c(1:length(kroon$BOOMHOOGTE))
kroon <- spTransform(kroon, CRS("+init=epsg:4326"))

kroonbuffer <- readOGR("C:/Users/tombayu.hidayat/Documents/Internship/ProRail/Extent/KroonBuffer.shp")
crs(kroonbuffer) <- "+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.417,50.3319,465.552,-0.398957,0.343988,-1.8774,4.0725 +units=m +no_defs"
kroonbuffer <- spTransform(kroonbuffer, CRS("+init=epsg:4326"))

boom <- readOGR("Boom.shp")
crs(boom) <- "+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.417,50.3319,465.552,-0.398957,0.343988,-1.8774,4.0725 +units=m +no_defs"
boom <- spTransform(boom, CRS("+init=epsg:4326"))

maaiveld <- readOGR("Maaiveld.shp")
crs(maaiveld) <- "+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.417,50.3319,465.552,-0.398957,0.343988,-1.8774,4.0725 +units=m +no_defs"
maaiveld <- spTransform(maaiveld, CRS("+init=epsg:4326"))

# GeoJSON
writeOGR(spoor, dsn = "SpoorSplit.geojson", layer = "spoor", driver = "GeoJSON")
writeOGR(kroon, dsn = "Kroon.geojson", layer = "projectie", driver = "GeoJSON")
writeOGR(kroonbuffer, dsn = "KroonBuffer.geojson", layer = "buffer", driver = "GeoJSON")
writeOGR(maaiveld, dsn = "Maaiveld.geojson", layer = "maaiveld", driver = "GeoJSON")

# shp
writeOGR(spoor, dsn = "Transform/SpoorSplit.shp", layer = "spoor", driver = "ESRI Shapefile")
writeOGR(kroon, dsn = "Transform/Kroon.shp", layer = "projectie", driver = "ESRI Shapefile")
writeOGR(kroonbuffer, dsn = "Transform/KroonBuffer.shp", layer = "buffer", driver = "ESRI Shapefile")
writeOGR(boom, dsn = "Transform/Boom.shp", layer = "boom", driver = "ESRI Shapefile")
writeOGR(maaiveld, dsn = "Transform/Maaiveld.shp", layer = "maaiveld", driver = "ESRI Shapefile")

# Re-write as geojson
boom <- readOGR("Transform/Boom.shp")
kroon <- readOGR("Transform/Kroon.shp")
kroonBuffer <- readOGR("Transform/KroonBuffer.shp")
spoor <- readOGR("Transform/SpoorSplit.shp")


# GeoJSON
writeOGR(boom, dsn = "Transform/Boom.geojson", layer = "spoor", driver = "GeoJSON")
writeOGR(spoor, dsn = "Transform/SpoorSplit.geojson", layer = "spoor", driver = "GeoJSON")
writeOGR(kroon, dsn = "Transform/Kroon.geojson", layer = "projectie", driver = "GeoJSON")
writeOGR(kroonbuffer, dsn = "Transform/KroonBuffer.geojson", layer = "buffer", driver = "GeoJSON")

scored <- readOGR("C:/Users/tombayu.hidayat/Documents/Internship/ProRail/Result/E_ScoredSpoor.shp") %>%
  spTransform(CRS("+init=epsg:4326")) %>%
  writeOGR(dsn = "C:/Users/tombayu.hidayat/Documents/Internship/Shiny/data/ScoredSpoor.geojson", layer = "ScoredSpoor", 
           driver = "GeoJSON")
plot(scored)
plot(kroon, add = T)
