###########################################################################################
## Nighttime light in Mexican states at analytical units                                 ##
##                                                                                       ##
## Code to export municipal- and electoral sección-level statistics using INE's polygons ##
## (see https://github.com/emagar/luminosity for details)                                ##
##                                                                                       ##
## Prepared by Eric Magar 30apr2021                                                      ##
## emagar at itam dot mx                                                                 ##
###########################################################################################

## # OJO: when using spTranform in script, use line below for google earth, or next line for OSM/google maps
#x.map <- spTransform(x.map, CRS("+proj=longlat +datum=WGS84"))
#x.map <- spTransform(x.map, osm()) # project to osm native Mercator

# to use osm backgrounds
library(rJava)
library(OpenStreetMap)
library(rgdal)
library(raster)

# geospatial data 
#library(spdep);
library(maptools)
# used to determine data's datum
library(rgdal)
#gpclibPermit()


rm(list = ls())

# my state abbrevs
edos <- c("ags", "bc", "bcs", "cam", "coa", "col", "cps", "cua", "df", "dgo", "gua", "gue", "hgo", "jal", "mex", "mic", "mor", "nay", "nl", "oax", "pue", "que", "qui", "san", "sin", "son", "tab", "tam", "tla", "ver", "yuc", "zac")

rd <- c("~/Dropbox/data/mapas/luminosity/")
#md <- c("~/Dropbox/data/elecs/MXelsCalendGovt/redistrict/ife.ine/mapasComparados/loc/maps/0code/")
#md <- c("~/Dropbox/data/elecs/MXelsCalendGovt/redistrict/ife.ine/mapasComparados/")                 # uses 2017 INE maps
md <- c("~/Dropbox/data/mapas/cartografia-2020/")                                                    # uses 2020 INE maps

for (e in 29){
#e <- 13

# select state to process
edon <- e; edo <- edos[edon]
print(paste("Will process", toupper(edo), "stats"))

# state's borders
#tmp <- paste(md, "fed/shp/disfed2018/", edo, sep = "") # archivo con mapas 2017
tmp <- paste(md, edo, sep = "")                         # archivo con mapas 2018
ed.map <- readOGR(dsn = tmp, layer = 'ENTIDAD')
summary(ed.map)
# projects to a different datum with long and lat
ed.map <- spTransform(ed.map, osm())
#
# state's municipios
#tmp <- paste(md, "fed/shp/disfed2018/", edo, sep = "") # archivo con mapas 2017
tmp <- paste(md, edo, sep = "")                         # archivo con mapas 2018
mu.map <- readOGR(dsn = tmp, layer = 'MUNICIPIO')
summary(mu.map)
# projects to a different datum with long and lat
mu.map <- spTransform(mu.map, osm()) # project to osm native Mercator
#plot(mu.map)
#
# state's secciones
#tmp <- paste(md, "fed/shp/disfed2018/", edo, sep = "") # archivo con mapas 2017
tmp <- paste(md, edo, sep = "")                         # archivo con mapas 2018
se.map <- readOGR(dsn = tmp, layer = 'SECCION')
summary(se.map)
# projects to a different datum with long and lat
se.map <- spTransform(se.map, osm()) # project to osm native Mercator
#plot(se.map)
# prepare data.frame to receive luminosity seccion-level stats
dat <- se.map@data
dat$ord <- 1:nrow(dat)

# l will receive state/year's stats, then will be rbound to year's dataframe ly
l <- data.frame(ord = dat$ord, edon = dat$entidad, seccion = dat$seccion); l$median <- l$sd <- l$mean <- NA; l$note <- ""
ses <- l$seccion

calc.yr <- function(yr){
    #yr <- 2000 # debug
    ly <- data.frame()
    # open raster layer
    pth <- paste(rd, "raster/", edo, "/l", yr, ".tif", sep="") # archivo de luminosidad
    r <- raster(pth) # filenames 1992-2013
    # projects to a different datum with long and lat
    r <- projectRaster(r, crs=osm()) # project to osm native Mercator
    # clip raster to state
    r <- mask(r, ed.map)         # approximate poligon only
#drop maybe    r[is.na(r)] <- 0 # make NAs zeroes
    ## # verify
## #    png(file = "../pics/bc.png")
##     par(mar=c(.5,.5,2,1)) ## SETS B L U R MARGIN SIZES
##     plot(r, axes = FALSE, main = edo)
##     plot(ed.map, add = TRUE, lwd = .2)
## #    plot(se.map, add = TRUE, lwd = .1)
#    dev.off()
    #
    # copy master data.frame
    l.work <- l
    # fill row-by-row
    for (i in 1:length(ses)){
        #i <- 100 # debug
        ## if (
        ##   (edon==1  & ses[i] %in% c(318,603:607))  # secciones shapefiles appear to be corrupted
        ## | (edon==7  & ses[i] %in%   2042:2048)
        ## | (edon==16 & ses[i] %in% c(2080,2696:2703))
        ## ){
        ##     l.work$note[i] <- "shapefile corrupted"
        ##     next
        ## }
        message(sprintf("%spct of %s-%s: i=%s sección %s", round(i*100/length(ses),0), edo, yr, i, ses[i]))
        one.se <- subset(se.map, se.map@data$seccion==ses[i])
        #plot(one.se, main=paste("sección", ses[i]))
        # clip raster to seccion
        r.se <- crop(r, extent(one.se)) # crop to plot area
        #plot(r.se, main=paste("sección", ses[i]))
        r.se <- mask(r.se, one.se)         # approximate poligon
        ## # verify
        ## par(mar=c(.5,.5,2,4)) ## SETS B L U R MARGIN SIZES
        ## plot(one.se, main=paste("sección", ses[i]))
        ## plot(r.se, add = TRUE)
        ## plot(one.se, add = TRUE, lwd = .5)
        #
        v <- unlist(extract(r, one.se)) # get values inside poligon
        l.work$mean  [i] <- round(mean  (v),2)
        l.work$sd    [i] <- round(sd    (v),2)
        l.work$median[i] <- round(median(v),2)
    }
    ly <- rbind(ly, l.work)
    return(ly)
}


i <- 1992
for (i in 1992:2018){
    yr <- i
    ly <- calc.yr(yr=yr)
    ly <- ly[order(ly$seccion),] # sort
    ly$ord <- NULL # drop plotting order
    tail(ly)
    pth <- paste(rd, "data/secciones/", edo, "/lum", yr, ".csv", sep="") # archivo de luminosidad
    write.csv(ly, file = pth, row.names=FALSE)
}

# l will receive state/year's stats, then will be rbound to year's dataframe ly
dat.mu <- mu.map@data
dat.mu$ord <- 1:nrow(dat.mu)
l <- data.frame(ord = dat.mu$ord, edon = dat.mu$entidad, munn = dat.mu$municipio, mun = dat.mu$nombre); l$median <- l$sd <- l$mean <- NA; l$note <- ""
mus <- l$munn

calc.yr.mu <- function(yr){
    #yr <- 2000 # debug
    ly <- data.frame()
    # open raster layer
    pth <- paste(rd, "raster/", edo, "/l", yr, ".tif", sep="") # archivo de luminosidad
    r <- raster(pth) # filenames 1992-2013
    # projects to a different datum with long and lat
    r <- projectRaster(r, crs=osm()) # project to osm native Mercator
    # clip raster to state
    r <- mask(r, ed.map)         # approximate poligon only
#drop    r[is.na(r)] <- 0 # make NAs zeroes
    ## # verify
    ## plot(r)
    ## plot(ed.map, add = TRUE, lwd = .2)
    ## plot(se.map, add = TRUE, lwd = .1)
    #
    # copy master data.frame
    l.work <- l
    # fill row-by-row
    for (i in 1:length(mus)){
        #i <- 1 # debug
        ## if (
        ##   (edon==1  & ses[i] %in% c(318,603:607))  # secciones shapefiles appear to be corrupted
        ## | (edon==7  & ses[i] %in%   2042:2048)
        ## | (edon==16 & ses[i] %in% c(2080,2696:2703))
        ## ){
        ##     l.work$note[i] <- "shapefile corrupted"
        ##     next
        ## }
        message(sprintf("%spct of %s-%s: i=%s mun %s", round(i*100/length(mus),0), edo, yr, i, mus[i]))
        one.mu <- subset(mu.map, mu.map@data$municipio==mus[i])
        #plot(one.se, main=paste("sección", ses[i]))
        # clip raster to seccion
        r.mu <- crop(r, extent(one.mu)) # crop to plot area
        #plot(r.se, main=paste("sección", ses[i]))
        r.mu <- mask(r.mu, one.mu)         # approximate poligon
        ## # verify
        ## plot(one.mu)
        ## plot(r.mu, add = TRUE)
        ## plot(one.mu, add = TRUE, lwd = .2)
        #
        v <- unlist(extract(r, one.mu)) # get values inside poligon
        l.work$mean  [i] <- round(mean  (v),2)
        l.work$sd    [i] <- round(sd    (v),2)
        l.work$median[i] <- round(median(v),2)
    }
    ly <- rbind(ly, l.work)
    return(ly)
}

i <- 1992
for (i in 1992:2018){
    yr <- i
    ly <- calc.yr.mu(yr=yr)
    ly <- ly[order(ly$munn),] # sort
    ly$ord <- NULL # drop plotting order
    tail(ly)
    pth <- paste(rd, "data/municipios/", edo, "/lum", yr, ".csv", sep="") # archivo de luminosidad
    write.csv(ly, file = pth, row.names=FALSE)
}
}

