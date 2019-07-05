#' My ugly pre-processing code
#' Author: Patrick Sogno
#' Date: 03.07.2019 (00:21) - I should probably just go to sleep -.-
#' 
#' -----------------------------------------------------------------------------

#----- 0. Set environment ------------------------------------------------------

## paths

#img dir
L <- "D:/Patrick/Documents/Dokumente/SoSe2019/MB3_Steigerwald/Steigerwald_final/Raster_data/LC8"
#mask file
m <- readOGR("D:/Patrick/Documents/Dokumente/SoSe2019/MB3_Steigerwald/Steigerwald_final/Vector_data/ROI_1_Sailershausen.shp")

## cores
ncores <- detectCores()

## packages
loadandinstall <- function(mypkg) {
  if (!is.element(mypkg, installed.packages()[,1])){install.packages(mypkg)}; 
  library(mypkg, character.only=TRUE)  }
packagelist <- as.list(c('rgdal', 'raster', 'RStoolbox', 'landsat', 'foreach',
                         'doParallel', 'naturalsort', 'oce'))
lapply(packagelist, function(x) loadandinstall(x))


#----- 1. Import ---------------------------------------------------------------

Ld <- as.list(list.dirs(L))
Ld
Ld <- Ld[c(2:5)]
Lf <- lapply(Ld, function(x) list.files(x, full.names = T, pattern = "*.TIF$"))
Lm <- lapply(Ld, function(x) list.files(x, full.names = T, pattern = "*MTL.txt$"))
Lm <- lapply(Lm, function(x) readMeta(x))
Lm
L1 <- list()
for(i in 1:length(Lf)) {
  L1[[i]] <- stackMeta(Lm[[i]])
}

#----- 2. Radiometric correction -----------------------------------------------

L1r <- list()
Lr <- list()
for(i in 1:length(L1)) {
  Lr[[i]] <- RStoolbox::radCor(L1[[i]], Lm[[i]],method ="dos")
}

#----- 3. CRS ------------------------------------------------------------------
Lr
plot(Lr[[1]])

#----- 4. Save on disk ---------------------------------------------------------

for (i in 1:length(Lr)) {
  writeRaster(Lr[[i]], paste0(getwd(), "/LC8RadCor1", i, ".tif"))
}

#----- 5. Atmospheric correction -----------------------------------------------

#build call: As you can see I did not do that. Might come in the future. I was
# thinking about a nice system() command to GRASS but I would be happy about
# suggestions :D.

#----- 6. Mask -----------------------------------------------------------------

Lrm <- list()
for(i in 1:length(Lr)) {
  Lrm[[i]] <- crop(Lr[[i]], m, filename = paste0(L, "/LC8RadCor_m_", i, ".tif"), overwrite = T)
} 

#----- 7. Mulit-temporal stack -------------------------------------------------
Lrm
Lrms <- brick(unlist(Lrm))

writeRaster(Lrms, filename = paste0(L, "/LC8RadCor_m_stack.tif"), overwrite = T)
