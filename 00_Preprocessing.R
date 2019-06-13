library(xml2)

rm(list = ls())

setwd("C:/Users/tombayu.hidayat/Documents/Internship/Planet/Baarn/")

doc <- read_xml("1802_feb/20180216_095751_0f2d/20180216_095751_0f2d_3B_AnalyticMS_metadata.xml")
nodes <- xml_find_all(doc, ".//ps:reflectanceCoefficient")
refCoeff <- xml_double(nodes)

ras <- brick("1802_feb/20180216_095751_0f2d/20180216_095751_0f2d_3B_AnalyticMS.tif")
copy <- brick("1802_feb/20180216_095751_0f2d/20180216_095751_0f2d_3B_AnalyticMS.tif")

for (i in seq_along(refCoeff)) {
  ras[[i]] <- ras[[i]] * refCoeff[[i]]
}

ndvi <- (ras[[4]] - ras[[3]]) / (ras[[4]] + ras[[3]])

writeRaster(ndvi, "ndvitoa.tif")
