#' Construct a shapefile containing city boundaries based on high-resolution population map.
#' @param pop object of class raster containing gridded population data.
#' @param threshold object of class numeric; used as a threshold to define which areas should be considered as part of city.
#' @param dist object of class numeric; used as a threshold to be used as a radius/shell size of the burning procedure in cca().
#' @param pop_sum object of class numeric; this sets a threshold for the minimum population size of a geographical cluster to qualify as a urban agglomeration.

#' @export
#' @return `city_bound()` returns a sf object with polygon boundaries of urban agglomerations with a population size greater than pop_sum.
#' @examples
#'\dontrun{
#' filename <- paste0("inst/extdata/zanzibar_ppp_2020_constrainted.tif")
#' pop <- raster(filename) %>%
#' raster::calc(function(x) ifelse(is.na(x), 0, x)) %>%
#' raster::aggregate(., fact=10, "sum")
#' threshold <- 1000
#' dist <- 1000
#' pop_sum <- 5000
#' pop <- raster::raster(filename)
#' city_bound(pop,threshold, dist, pop_sum)
#'}
#' @import sf dplyr
#' @importFrom raster raster crop mask
#' @importFrom osc cca
#' @importFrom stars st_as_stars

#####################################################################################################################
#identify city boundaries based on WorldPop 2000-2020

city_bound <- function(pop,threshold,dist,pop_sum) {
names(pop) <- "value"
pop_b <- pop %>%
  raster::calc(function(x) ifelse(is.na(x), 0, x)) %>%
  raster::calc(function(x) ifelse(x > threshold, 1, 0))
res.x <- raster::res(pop)[1]
res.y <- raster::res(pop)[2]
cluster <- osc::cca(pop_b,
                    s=dist,
                    unit="m",
                    res.x,
                    res.y,
                    cell.class=1)
cluster <- cluster$cluster %>%
  st_as_sf(., coords = c("long", "lat"),
           crs = 4326)

city_bound <- pop %>%
  stars::st_as_stars() %>%
  st_as_sf()

city_clusters <- city_bound %>%
  st_join(., cluster) %>%
  filter(!is.na(cluster_id)) %>%
  group_by(cluster_id) %>%
  summarise(pop = sum(value)) %>%
  filter(pop>pop_sum)
return(city_clusters)
}
