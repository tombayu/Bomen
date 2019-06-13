library(canopyLazR)
library(lidR)

download.file(url = "https://ndownloader.figshare.com/files/7024955",
              destfile = file.path("C:/Users/tombayu.hidayat/Documents/Data/canopyLazR/neon_lidar_example.las"),
              method = "auto",
              mode = "wb")

setwd("C:/Users/tombayu.hidayat/Documents/Data/")

# Convert .laz or .las files into a list of voxelized lidar arrays
# Default data "./canopyLazR"
# Sjoerd's data "./Railway"

laz.data <- laz.to.array(laz.files.path = "./canopyLazR", 
                         voxel.resolution = 0.5, 
                         z.resolution = 1,
                         use.classified.returns = TRUE)

# Level each voxelized array in the list to mimic a canopy height model
level.canopy <- canopy.height.levelr(lidar.array.list = laz.data)

# Estimate LAD for each voxel in leveled array in the list 
lad.estimates <- machorn.lad(leveld.lidar.array.list = level.canopy, 
                             voxel.height = 1, 
                             beer.lambert.constant = NULL)

# Convert the list of LAD arrays into a single raster stack
lad.raster <- lad.array.to.raster.stack(lad.array.list = lad.estimates, 
                                        laz.array.list = laz.data, 
                                        epsg.code = 32611)

# Create a single LAI raster from the LAD raster stack
lai.raster <- raster::calc(lad.raster, fun = sum, na.rm = TRUE)

# Generate a quick raster plot of the resulting total canopy LAI values for each pixel
plot(lai.raster)

# Convert the list of LAZ arrays into a ground and canopy height raster
grd.can.rasters <- array.to.ground.and.canopy.rasters(laz.data, 32611)

# Plot the ground raster
plot(grd.can.rasters$ground.raster)

#Plot the canopy height raster
plot(grd.can.rasters$canopy.raster)
