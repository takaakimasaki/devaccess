#' Calculate distance matrix based on OpenStreetMap-Based Routing Service OSRM.
#' @param x a numeric vector of longitude and latitude (WGS84), an sf object of the origin point.
#' @param y a numeric vector of longitude and latitude (WGS84), an sf object of the origin point.
#' @param osrm.profile the routing profile to use, e.g. "car", "bike" or "foot" (when using the routing.openstreetmap.de test server). "car" is the default.
#' @export
#' @return osrm_matrix() returns a data.frame object with id_o (row ID of x), id_d (row ID of y), and dur (travel time between each element of x and that of y) in minutes.
#' @examples
#' tz <- read.csv("data/tz.csv") %>%  st_as_sf(coords = c('lng', 'lat'),crs=st_crs(4326))
#' osrm_matrix(tz, tz, "car")
#' @import sf osrm
#' @importFrom reshape melt

####################################################################################################
#Compute distance matrix using OpenStreetMap-Based Routing Service OSRM
####################################################################################################

osrm_matrix <- function(x,y,osrm.profile) {
# Travel time matrix
df <- data.frame(id_o=as.numeric(),
                 id_d=as.numeric(),
                 dur=as.numeric(),
                 stringsAsFactors=FALSE)

for(m in 1:dim(x)[1]) {
  for(n in 1:dim(y)[1]) {
      dist <- osrmTable(src = x[m,],
                        dst = y[n,],
                        osrm.profile = osrm.profile)
      dist <- as.data.frame(dist$duration)
      dist$id <- row.names(dist)
      dist <- reshape::melt(dist, id=c("id"))
      colnames(dist) <- c("id_o","id_d","dur")
      df <- rbind(df,dist)
      print(paste0("done with x=",n,", y=",m))
  }
}
df
}
