#' Calculate distance matrix using your own specified friction map.
#' @param x a numeric vector of longitude and latitude (WGS84), an sf object of the origin point.
#' @param y a numeric vector of longitude and latitude (WGS84), an sf object of the origin point.
#' @param friction friction maps (available in GEOTIFF) which can be downloaded from https://malariaatlas.org/research-project/accessibility_to_cities/ or https://malariaatlas.org/research-project/accessibility-to-healthcare/.
#' @export
#' @return friction_matrix() returns a data.frame object with id_o (row ID of x), id_d (row ID of y), and dur (travel time between each element of x and that of y) in minutes.
#' @examples
#' tz <- read.csv("data/tz.csv") %>%  st_as_sf(coords = c('lng', 'lat'),crs=st_crs(4326))
#' friction <- raster("data/2015_friction_surface_v1.geotiff) ## this needs to be downloaded
#' friction_matrix(tz, tz, friction)
#' @import sf reshape gdistance

####################################################################################################
#Compute distance matrix using OpenStreetMap-Based Routing Service OSRM
####################################################################################################
friction_matrix <- function(x, y, friction) {
e <- extent(x)
xmin <- e[1] - 1
xmax <- e[2] + 1
ymin <- e[3] - 1
ymax <- e[4] + 1
e <- c(xmin, xmax, ymin, ymax)

#Now use scripts from https://insileco.github.io/2019/04/08/r-as-a-ruler-how-to-calculate-distances-between-geographical-objects/
###The above code to get friction surface just takes so much time...
friction <- friction %>% crop(., e)
T <- gdistance::transition(friction, function(x) 1/mean(x), 8)
T.GC <- gdistance::geoCorrection(T)
x <- as_Spatial(x)
x$id <- seq(1:dim(x)[1])
y <- as_Spatial(y)
y$id <- seq(1:dim(y)[1])
dist.mat <- data.frame(id=as.numeric(),
                       variable=character(),
                       value=as.numeric(),
                       stringsAsFactors=FALSE)

d_list <- unique(y$id)
for(n in d_list) {
  dist <- costDistance(T.GC,
                       fromCoords = x[x$id==n,],
                       toCoords = y)
  dist_df <- data.frame(dist)
  dist_df$id <- n
  dist_df <- melt(dist_df, id=c("id"))
  dist.mat <- rbind(dist.mat, dist_df)
  print(paste0("done with x =",n))
}
colnames(dist.mat) <- c("id_o","id_d","dur")
dist.mat
}
