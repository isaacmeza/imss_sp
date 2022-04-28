################################################################
## maps for README                                            ##
## script may require running parts of export-seccion-stats.r ##
################################################################

cuts <- seq(0,50,5)
edon <- 2; edo <- "bc"

i <- 100
one.se <- subset(se.map, se.map@data$seccion==ses[i])

# state lum
pth <- paste(rd, "raster/", edo, "/l", yr, ".tif", sep="") # archivo de luminosidad
r <- raster(pth) # filenames 1992-2013
# projects to a different datum with long and lat
r <- projectRaster(r, crs=osm()) # project to osm native Mercator
# clip raster to state
r <- mask(r, ed.map)         # approximate poligon only
r[is.na(r)] <- 0 # make NAs zeroes
## # verify
png(file = "../pics/bc.png")
par(mar=c(.5,.5,2,1)) ## SETS B L U R MARGIN SIZES
plot(r, axes = FALSE, main = edo)
plot(ed.map, add = TRUE, lwd = .2)
plot(one.se, add = TRUE, lwd = .5, col = "red")
#plot(se.map, add = TRUE, lwd = .1)
dev.off()


# plot crop
        #plot(one.se, main=paste("sección", ses[i]))
        # clip raster to seccion
        r.se <- crop(r, extent(one.se)) # crop to plot area
        ## # verify
        png(file = "../pics/bc-100-crop.png")
        par(mar=c(.5,.5,2,4)) ## SETS B L U R MARGIN SIZES
        plot(one.se, main=paste("sección", ses[i], "(Mexicali)"))
        #plot(r.se, breaks=cuts, col = topo.colors(5), add = TRUE)
        plot(r.se, breaks=cuts, col = topo.colors(10), add = TRUE)
        plot(one.se, add = TRUE, lwd = 1)
        dev.off()

# plot mask
        # clip raster to seccion
        r.se <- crop(r, extent(one.se)) # crop to plot area
        #plot(r.se, main=paste("sección", ses[i]))
        r.se <- mask(r.se, one.se)         # approximate poligon
        #
        v <- unlist(extract(r, one.se)) # get values inside poligon
        tmp.mean   <- round(mean  (v),2)
        tmp.sd     <- round(sd    (v),2)
        tmp.median <- round(median(v),2)
        ## # verify
        png(file = "../pics/bc-100-mask.png")
        par(mar=c(.5,.5,2.5,4)) ## SETS B L U R MARGIN SIZES
        plot(one.se, main=paste("sección", ses[i], "\nmedian =", tmp.median, "mean=", tmp.mean, "sd =", tmp.sd))
        plot(r.se, breaks=cuts, col = topo.colors(10), add = TRUE)
        plot(one.se, add = TRUE, lwd = .5)
        dev.off()

# plot 1994-2018
png(file = "../pics/bc-100-mask-1994-2018.png")
par(mfrow=c(5,5))
for (i in 1994:2018){
    yr <- i
    pth <- paste(rd, "raster/", edo, "/l", yr, ".tif", sep="") # archivo de luminosidad
    r <- raster(pth) # filenames 1992-2013
    # projects to a different datum with long and lat
    r <- projectRaster(r, crs=osm()) # project to osm native Mercator
    # clip raster to state
    r <- mask(r, ed.map)         # approximate poligon only
    r[is.na(r)] <- 0 # make NAs zeroes
        # clip raster to seccion
        r.se <- crop(r, extent(one.se)) # crop to plot area
        #plot(r.se, main=paste("sección", ses[i]))
        r.se <- mask(r.se, one.se)         # approximate poligon
        #
        v <- unlist(extract(r, one.se)) # get values inside poligon
        tmp.mean   <- round(mean  (v),1)
        tmp.sd     <- round(sd    (v),1)
        tmp.median <- round(median(v),1)
        ## # verify
        par(mar=c(.5,.5,2.5,4)) ## SETS B L U R MARGIN SIZES
#        plot(one.se, main=paste(yr, "\nmedian =", tmp.median, "mean=", tmp.mean, "sd =", tmp.sd))
        plot(one.se, main=paste(yr, "\nmean=", tmp.mean))
        plot(r.se, breaks=cuts, col = topo.colors(10), add = TRUE)
        plot(one.se, add = TRUE, lwd = .5)
}
dev.off()


citation("raster")



