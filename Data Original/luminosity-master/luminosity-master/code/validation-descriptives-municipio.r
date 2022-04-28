############################################################################
## Nighttime light in Mexican states at analytical units                  ##
##                                                                        ##
## Code to debug, validate, describe MUNICIPIO electoral-level statistics ##
##                                                                        ##
## Prepared by Eric Magar 6may2021                                        ##
## emagar at itam dot mx                                                  ##
############################################################################

library(DataCombine) # easy lags with slide

rm(list = ls())

edos <- c("ags", "bc", "bcs", "cam", "coa", "col", "cps", "cua", "df", "dgo", "gua", "gue", "hgo", "jal", "mex", "mic", "mor", "nay", "nl", "oax", "pue", "que", "qui", "san", "sin", "son", "tab", "tam", "tla", "ver", "yuc", "zac")
estados <- c("Aguascalientes", "Baja California", "Baja California Sur", "Campeche", "Coahuila", "Colima", "Chiapas", "Chihuahua", "Ciudad de México", "Durango", "Guanajuato", "Guerrero", "Hidalgo", "Jalisco", "México", "Micchoacán", "Morelos", "Nayarit", "Nuevo León", "Oaxaca", "Puebla", "Querétaro", "Quintana Roo", "San Luis Potosí", "Sinaloa", "Sonora", "Tabasco", "Tamaulipas", "Tlaxcala", "Veracruz", "Yucatán", "Zacatecas")

# select state to process
edon <- 1; edo <- edos[edon]; estado <- estados[edon]; print(paste("Will describe", toupper(estado), "stats"))

# municipios
dd <- c(paste0("~/Dropbox/data/mapas/luminosity/data/municipios/", edo, "/")) # municipios
setwd(dd)

# read state data into data.frames
yr <- 1992
tmp <- read.csv(file = paste0("lum", yr, ".csv"), stringsAsFactors = FALSE)
tmp$sd[is.na(tmp$sd)] <- 0 # missing sd due to single pixel, should be zero
#
l.mean   <- tmp; l.mean$median <- l.mean$sd <- l.mean$note <- NULL; colnames(l.mean)[4] <- "y1992"
l.median <- tmp; l.median$mean <- l.median$sd <- l.median$note <- NULL; colnames(l.median)[4] <- "y1992"
l.sd     <- tmp; l.sd$mean <- l.sd$median <- l.sd$note <- NULL; colnames(l.sd)[4] <- "y1992"

for (yr in 1993:2018){
    #yr <- 1993 # debug
    tmp <- read.csv(file = paste0("lum", yr, ".csv"), stringsAsFactors = FALSE)
    tmp$sd[is.na(tmp$sd)] <- 0 # missing sd due to single pixel, should be zero
    # plug yr's stats into relevant data.frame
    l.mean <- cbind(l.mean, tmp$mean); colnames(l.mean)[ncol(l.mean)] <- paste0("y", yr)
    l.median <- cbind(l.median, tmp$median); colnames(l.median)[ncol(l.median)] <- paste0("y", yr)
    l.sd <- cbind(l.sd, tmp$sd); colnames(l.sd)[ncol(l.sd)] <- paste0("y", yr)
}

# first differences and relative change
l.dif0 <- l.mean[,-c(1:3)] # drop edon seccion
l.dif1 <- l.dif0[,-1]; l.dif1 <- cbind(l.dif1, y2019=rep(NA,nrow(l.dif0)))
l.rel1 <- round((l.dif1 - l.dif0) / (l.dif0 + .001), 3) # +.001 to avoid indeterminacy when base is zero 
l.dif1 <- l.dif1 - l.dif0 #  1st difference
l.dif1$y2019 <- l.rel1$y2019 <- NULL # drop last year indetermined
rm(l.dif0) # clean
l.dif1 <- cbind(l.mean[,c(1:3)], l.dif1) # add edon seccion again
l.rel1 <- cbind(l.mean[,c(1:3)], l.rel1) # add edon seccion again
head(l.dif1)
head(l.rel1)

# 1992 = 100
l.rel0 <- l.mean
#l.rel0[,-c(1:3)] <- l.rel0[,-c(1:3)] + 0.001 # smallest measure>0 is 0.01, add 0.001 to avoid indeterminacy
l.rel0[,-c(1:3)] <- l.rel0[,-c(1:3)] + 100 # largest measure is 63, sliding up to 100 should work
l.rel0[,-c(1:3)] <- l.rel0[,-c(1:3)] *100 / l.rel0[,4]


# plot y1992 = 100
clr <- rgb(190, 190, 190, maxColorValue = 255, alpha = 50)
plot(x=1992:2018,l.rel0[1,-1:-3],ylim=c(50,160),type="n", axes=FALSE,
     main = paste0(estado, ", municipios"), ylab = "Relative luminosity (1992 = 100)", xlab = "")
axis(1, at = seq(1992,2018,1), labels = FALSE)
axis(1, at = c(1992,seq(1995,2015,5),2018))
axis(2)
for (i in 1:nrow(l.rel0)) lines(x=1992:2018,l.rel0[i,-1:-3],col=clr,lwd=1)
abline(h=100,col="red")

# trend and plot it
trend <- as.list(rep(NA, nrow(l.mean)))
names(trend) <- l.mean$munn
#
for (i in 1:nrow(l.mean)){
    dat    <- data.frame(x = c(1992:2018) - 1992) # start from 0,0
    #dat    <- data.frame(x = 1992:2018)
    dat$y <- t(l.rel0[i,-c(1:3)]) - 100
    #dat$y <- t(l.rel0[i,-c(1:3)])
    #dat$y <- t(l.mean[i,-c(1:3)])
    trend[[i]] <- lm( y ~ x - 1, data = dat)
}
#
clr <- rgb(190, 190, 190, maxColorValue = 255, alpha = 50)
plot(x=1992:2018,l.rel0[1,-1:-3],ylim=c(50,160),type="n", axes=FALSE,
     main = paste0(estado, ", municipios"), ylab = "Time trend in rel. luminosity (1992 = 100)", xlab = "")
axis(1, at = seq(1992,2018,1), labels = FALSE)
axis(1, at = c(1992,seq(1995,2015,5),2018))
axis(2)
for (i in 1:length(trend)) abline(a=summary(trend[[i]])$coefficients[1,1],col=clr,lwd=1)
#for (i in 1:length(trend)) abline(trend[[i]],col=clr,lwd=1)
abline(h=100,col="red")


# 1107819448674 # folio cancelacion izzi 6may2021

## # OJO: when using spTranform in script, use line below for google earth, or next line for OSM/google maps
#x.map <- spTransform(x.map, CRS("+proj=longlat +datum=WGS84"))
#x.map <- spTransform(x.map, osm()) # project to osm native Mercator

# to use osm backgrounds
library(rJava)
library(OpenStreetMap)
library(raster)

# geospatial data 
#library(spdep);
library(maptools)
# used to determine what datum rojano data has
library(rgdal)
#gpclibPermit()

rd <- c("~/Dropbox/data/mapas/luminosity/")
md <- c("~/Dropbox/data/elecs/MXelsCalendGovt/redistrict/ife.ine/mapasComparados/")

# state's borders
tmp <- paste(md, "fed/shp/disfed2018/", edo, sep = "") # archivo con mapas 2017
tmp <- readOGR(dsn = tmp, layer = 'ENTIDAD')
# projects to a different datum with long and lat
tmp <- spTransform(tmp, osm())
ed.map <- tmp
#
# state's municipios
tmp <- paste(md, "fed/shp/disfed2018/", edo, sep = "") # archivo con mapas 2017
mu.map <- readOGR(dsn = tmp, layer = 'MUNICIPIO')
summary(mu.map)
# projects to a different datum with long and lat
mu.map <- spTransform(mu.map, osm()) # project to osm native Mercator
#plot(mu.map)
#
# state's secciones
tmp <- paste(md, "fed/shp/disfed2018/", edo, sep = "") # archivo con mapas 2017
se.map <- readOGR(dsn = tmp, layer = 'SECCION')
summary(se.map)
# projects to a different datum with long and lat
se.map <- spTransform(se.map, osm()) # project to osm native Mercator
#plot(se.map)
# prepare data.frame to receive luminosity seccion-level stats
dat <- se.map@data
dat$ord <- 1:nrow(dat)

pth <- paste(rd, "raster/", edo, "/l", yr, ".tif", sep="") # archivo de luminosidad
r <- raster(pth) # filenames 1992-2013
    # projects to a different datum with long and lat
r <- projectRaster(r, crs=osm()) # project to osm native Mercator
    # clip raster to state
r <- mask(r, ed.map)         # approximate poligon only
r[is.na(r)] <- 0 # make NAs zeroes
    # verify
#    png(file = "../pics/bc.png")
par(mar=c(.5,.5,2,1)) ## SETS B L U R MARGIN SIZES
plot(r, lwd = 1)
plot(r, axes = FALSE, main = edo)
plot(ed.map, add = TRUE, lwd = 1)
#    plot(se.map, add = TRUE, lwd = .1)
plot(se.map[which(dat$seccion %in% sel),], add = TRUE, lwd = 1, col = "red")
#    dev.off()
    #
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
    r[is.na(r)] <- 0 # make NAs zeroes
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

