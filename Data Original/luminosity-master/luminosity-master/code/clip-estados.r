###########################################################################################
## Nighttime light 1992-2018 in Mexican states'                                          ##
##                                                                                       ##
## Code to clip worldwide files using Mexican states' poligons                           ##
## Harmonized luminosity rasters from https://www.nature.com/articles/s41597-020-0510-y  ##
##                                                                                       ##
## Prepared by Eric Magar 27apr2021                                                      ##
## emagar at itam dot mx                                                                 ##
###########################################################################################

## # OJO: when using spTranform in script, use line below for google earth, or next line for OSM/google maps
#x.map <- spTransform(x.map, CRS("+proj=longlat +datum=WGS84"))
#x.map <- spTransform(x.map, osm()) # project to osm native Mercator

# to use osm backgrounds
library(rJava)
library(OpenStreetMap)
library(raster)

rm(list = ls())

edos <- c("ags", "bc", "bcs", "cam", "coa", "col", "cps", "cua", "df", "dgo", "gua", "gue", "hgo", "jal", "mex", "mic", "mor", "nay", "nl", "oax", "pue", "que", "qui", "san", "sin", "son", "tab", "tam", "tla", "ver", "yuc", "zac")

wd <- c("~/Dropbox/data/elecs/MXelsCalendGovt/redistrict/ife.ine/mapasComparados/loc/maps/0code/")
setwd(wd)
dd <- c("~/Dropbox/data/elecs/MXelsCalendGovt/elecReturns/")

# geospatial data 
library(spdep);
library(maptools)
# used to determine what datum rojano data has
library(rgdal)
#gpclibPermit()

# read all state borders from rojano
ed.map <- list()
tmp <- "../../../fed/shp/disfed2018/ags" # archivo con mapas 2018
# tmp <- paste(md, "ags", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$ags <- tmp
#
tmp <- "../../../fed/shp/disfed2018/bc" # archivo con mapas 2018
# ## tmp <- paste(md, "bc", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$bc <- tmp
#
tmp <- "../../../fed/shp/disfed2018/bcs" # archivo con mapas 2018
# ## tmp <- paste(md, "bcs", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$bcs <- tmp
#
tmp <- "../../../fed/shp/disfed2018/cam" # archivo con mapas 2018
## # tmp <- paste(md, "cam", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$cam <- tmp
#
tmp <- "../../../fed/shp/disfed2018/coa" # archivo con mapas 2018
# ## tmp <- paste(md, "coa", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$coa <- tmp
#
tmp <- "../../../fed/shp/disfed2018/col" # archivo con mapas 2018
# ## tmp <- paste(md, "col", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$col <- tmp
#
tmp <- "../../../fed/shp/disfed2018/cps" # archivo con mapas 2018
# ## tmp <- paste(md, "cps", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$cps <- tmp
#
tmp <- "../../../fed/shp/disfed2018/cua" # archivo con mapas 2018
# ## tmp <- paste(md, "cua", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$cua <- tmp
#
tmp <- "../../../fed/shp/disfed2018/df" # archivo con mapas 2018
# ## tmp <- paste(md, "df", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$df <- tmp
#
tmp <- "../../../fed/shp/disfed2018/dgo" # archivo con mapas 2018
# ## tmp <- paste(md, "dgo", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$dgo <- tmp
#
tmp <- "../../../fed/shp/disfed2018/gua" # archivo con mapas 2018
# ## tmp <- paste(md, "gua", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$gua <- tmp
#
tmp <- "../../../fed/shp/disfed2018/gue" # archivo con mapas 2018
# ## tmp <- paste(md, "gue", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$gue <- tmp
#
tmp <- "../../../fed/shp/disfed2018/hgo" # archivo con mapas 2018
# ## tmp <- paste(md, "hgo", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$hgo <- tmp
#
tmp <- "../../../fed/shp/disfed2018/jal" # archivo con mapas 2018
# ## tmp <- paste(md, "jal", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$jal <- tmp
#
tmp <- "../../../fed/shp/disfed2018/mex" # archivo con mapas 2018
# ## tmp <- paste(md, "mex", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$mex <- tmp
#
tmp <- "../../../fed/shp/disfed2018/mic" # archivo con mapas 2018
# ## tmp <- paste(md, "mic", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$mic <- tmp
#
tmp <- "../../../fed/shp/disfed2018/mor" # archivo con mapas 2018
# ## tmp <- paste(md, "mor", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$mor <- tmp
#
tmp <- "../../../fed/shp/disfed2018/nay" # archivo con mapas 2018
# ## tmp <- paste(md, "nay", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$nay <- tmp
#
tmp <- "../../../fed/shp/disfed2018/nl" # archivo con mapas 2018
# ## tmp <- paste(md, "nl", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$nl <- tmp
#
tmp <- "../../../fed/shp/disfed2018/oax" # archivo con mapas 2018
## # tmp <- paste(md, "oax", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$oax <- tmp
#
tmp <- "../../../fed/shp/disfed2018/pue" # archivo con mapas 2018
# ## tmp <- paste(md, "pue", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$pue <- tmp
#
tmp <- "../../../fed/shp/disfed2018/que" # archivo con mapas 2018
# ## tmp <- paste(md, "que", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$que <- tmp
#
tmp <- "../../../fed/shp/disfed2018/qui" # archivo con mapas 2018
# ## tmp <- paste(md, "qui", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$qui <- tmp
#
tmp <- "../../../fed/shp/disfed2018/san" # archivo con mapas 2018
# ## tmp <- paste(md, "san", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$san <- tmp
#
tmp <- "../../../fed/shp/disfed2018/sin" # archivo con mapas 2018
# ## tmp <- paste(md, "sin", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$sin <- tmp
#
tmp <- "../../../fed/shp/disfed2018/son" # archivo con mapas 2018
# ## tmp <- paste(md, "son", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$son <- tmp
#
tmp <- "../../../fed/shp/disfed2018/tab" # archivo con mapas 2018
## # tmp <- paste(md, "tab", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$tab <- tmp
#
tmp <- "../../../fed/shp/disfed2018/tam" # archivo con mapas 2018
# ## tmp <- paste(md, "tam", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$tam <- tmp
## #
tmp <- "../../../fed/shp/disfed2018/tla" # archivo con mapas 2018
# ## tmp <- paste(md, "tla", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$tla <- tmp
#
tmp <- "../../../fed/shp/disfed2018/ver" # archivo con mapas 2018
## # tmp <- paste(md, "ver", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$ver <- tmp
#
tmp <- "../../../fed/shp/disfed2018/yuc" # archivo con mapas 2018
# ## tmp <- paste(md, "yuc", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$yuc <- tmp
#
tmp <- "../../../fed/shp/disfed2018/zac" # archivo con mapas 2018
# ## tmp <- paste(md, "zac", sep = "") # archivo con mapas rojano
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map$zac <- tmp


# open worldwide raster layer downloaded from source
setwd("~/Dropbox/data/mapas/luminosity/raster/") # archivo de luminosidad
#r <- raster("Harmonized_DN_NTL_2014_simVIIRS.tif") # filenames 2014-
r <- raster("Harmonized_DN_NTL_1998_calDMSP.tif") # filenames 1992-2013
xtnt <- extent(-130,-70,10,40) # select rectangle closer to mexico 
r <- crop(r, xtnt)
# projects to a different datum with long and lat
r <- projectRaster(r, crs=osm()) # project to osm native Mercator
#plot(r)
#
# crop luminosity by state
l1998 <- list()
l1998$ags <- crop(r, ed.map$ags)
l1998$bc  <- crop(r, ed.map$bc)
l1998$bcs <- crop(r, ed.map$bcs)
l1998$cam <- crop(r, ed.map$cam)
l1998$coa <- crop(r, ed.map$coa)
l1998$col <- crop(r, ed.map$col)
l1998$cps <- crop(r, ed.map$cps)
l1998$cua <- crop(r, ed.map$cua)
l1998$df  <- crop(r, ed.map$df)
l1998$dgo <- crop(r, ed.map$dgo)
l1998$gua <- crop(r, ed.map$gua)
l1998$gue <- crop(r, ed.map$gue)
l1998$hgo <- crop(r, ed.map$hgo)
l1998$jal <- crop(r, ed.map$jal)
l1998$mex <- crop(r, ed.map$mex)
l1998$mic <- crop(r, ed.map$mic)
l1998$mor <- crop(r, ed.map$mor)
l1998$nay <- crop(r, ed.map$nay)
l1998$nl  <- crop(r, ed.map$nl)
l1998$oax <- crop(r, ed.map$oax)
l1998$pue <- crop(r, ed.map$pue)
l1998$que <- crop(r, ed.map$que)
l1998$qui <- crop(r, ed.map$qui)
l1998$san <- crop(r, ed.map$san)
l1998$sin <- crop(r, ed.map$sin)
l1998$son <- crop(r, ed.map$son)
l1998$tab <- crop(r, ed.map$tab)
l1998$tam <- crop(r, ed.map$tam)
l1998$tla <- crop(r, ed.map$tla)
l1998$ver <- crop(r, ed.map$ver)
l1998$yuc <- crop(r, ed.map$yuc)
l1998$zac <- crop(r, ed.map$zac)
#
for (i in 1:32) writeRaster(l1998[[i]], filename = paste("~/Dropbox/data/mapas/luminosity/raster", edos[i], "l1998.tif", sep = "/"))

plot(l2012$bc)
plot(ed.map$bc, add = TRUE)
plot(ed.map$son, add = TRUE)

