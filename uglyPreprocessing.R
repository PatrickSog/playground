#' My ugly pre-processing code
#' Author: Patrick Sogno
#' Date: 03.07.2019 (00:21) - I should probably just go to sleep -.-
#' 
#' -----------------------------------------------------------------------------

#----- 0. Set environment ------------------------------------------------------

## paths
L <- "D:/Patrick/Documents/Dokumente/SoSe2019/MB3_Steigerwald/Steigerwald_final/Raster_data/LC8"

## cores
ncores <- detectCores()

## packages
loadandinstall <- function(mypkg) {
  if (!is.element(mypkg, installed.packages()[,1])){install.packages(mypkg)}; 
  library(mypkg, character.only=TRUE)  }
packagelist <- as.list(c('rgdal', 'raster', 'RStoolbox', 'landsat', 'foreach',
                         'doParallel'))
lapply(packagelist, function(x) loadandinstall(x))


#----- 1. Import ---------------------------------------------------------------

Ld <- as.list(list.dirs(L))
Ld <- Ld[c(2:5)]
Lf <- lapply(Ld, function(x) list.files(x, full.names = T, pattern = "*.TIF$"))
Lm <- lapply(Ld, function(x) list.files(x, full.names = T, pattern = "*MTL.txt$"))

for (i in 1:length(Lf)) {
  Lf[[i]] <- Lf[[i]][c(1, 4:9, 11)]
}
L1 <- lapply(Lf, function(x) stack(unlist(x)))
L1


#----- 2. Radiometric correction -----------------------------------------------

L1r <- list()

registerDoParallel(ncores-1) # parallel processing
foreach(i=1:length(L1)) %dopar%{
  L1r[[i]] <- RStoolbox::radCor(L1[[i]], Lm[[i]], method = "rad", bandSet = "full")
}
stopImplicitCluster() # don't forget to clean up the cores after processing.

