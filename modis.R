getwd()
setwd("C:/Users/tombayu.hidayat/Documents")

# pkgTest is a helper function to load packages and install packages only when they are not installed yet.
pkgTest <- function(x)
{
  if (x %in% rownames(installed.packages()) == FALSE) {
    install.packages(x, dependencies= TRUE)    
  }
  library(x, character.only = TRUE)
}
neededPackages <- c("strucchange","zoo", "bfast", "raster", "leaflet", "MODISTools")
for (package in neededPackages){pkgTest(package)}

mt_to_raster <- function (df = subset) 
{
  dates <- unique(df$calendar_date)
  df$scale[df$scale == "Not Available"] <- 1
  r <- do.call("stack", lapply(dates, function(date) {
    m <- matrix(df$value[df$calendar_date == date] * as.numeric(df$scale[df$calendar_date == 
                                                                           date]), df$nrows[1], df$ncols[1], byrow = TRUE)
    return(raster::raster(m))
  }))
  bb <- MODISTools::mt_bbox(xllcorner = df$xllcorner[1], yllcorner = df$yllcorner[1], 
                            cellsize = df$cellsize[1], nrows = df$nrows[1], ncols = df$ncols[1])
  bb <- as(bb, "Spatial")
  raster::extent(r) <- raster::extent(bb)
  raster::projection(r) <- raster::projection(bb)
  names(r) <- as.character(dates)
  return(r)
}

timeser <- function(index, dt) {
  z <- zoo(index, dt)
  yr <- as.numeric(format(time(z), "%Y"))
  jul <- as.numeric(format(time(z), "%j"))
  delta <- min(unlist(tapply(jul, yr, diff))) # 16
  zz <- aggregate(z, yr + (jul - 1) / delta / 23)
  (tso <- as.ts(zz))
  return(tso)
}

VI <- mt_subset(product = "MOD13Q1",
                site_id = "nl_gelderland_loobos",
                band = "250m_16_days_NDVI",
                start = "2000-01-01",
                km_lr = 2,
                km_ab = 2,
                site_name = "testsite",
                internal = TRUE,
                progress = FALSE)

QA <- mt_subset(product = "MOD13Q1",
                site_id = "nl_gelderland_loobos",
                band = "250m_16_days_pixel_reliability",
                start = "2000-01-01",
                km_lr = 2,
                km_ab = 2,
                site_name = "testsite",
                internal = TRUE,
                progress = FALSE)

# convert df to raster
VI_r <- mt_to_raster(df = VI)
QA_r <- mt_to_raster(df = QA)

## clean the data
# create mask on pixel reliability flag set all values <0 or >1 NA
m <- QA_r
m[(QA_r < 0 | QA_r > 1)] <- NA # obtain good data

# mask all values from VI raster NA
VI_m <- mask(VI_r, m,maskvalue=NA, updatevalue=NA)

# plot the first image
plot(m,1) # plot mask

plot(VI_m,1) # plot cleaned NDVI raster

# extract data from the cleaned raster for selected pixels
click(VI_m, id=TRUE, xy=TRUE, cell=TRUE, n= 1)
?click

library(leaflet)
r <- raster(VI_m,1)
pal <- colorNumeric(c("#ffffff", "#4dff88", "#004d1a"), values(r),
                    na.color = "transparent")

m <- leaflet() %>% addTiles() %>%
  addRasterImage(r, colors = pal, opacity = 0.8) %>%
  addLegend(pal = pal, values = values(r),
            title = "NDVI")
m
getwd()
