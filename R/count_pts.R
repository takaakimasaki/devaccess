#' Count the number of points by location.
#' @param sf object of class sf containing administrative boundaries.
#' @param pts object of class sf containing points.
#' @param id location ID used to aggregate the number of points.
#' @export
#' @return `count_pts()` returns a data.frame object with id (location ID) and number of points by id.
#' @examples
#' \dontrun{
#' admin <- sf::st_read("inst/extdata/zanzibar_dhs_adm1.shp") ##administrative boundaries
#' tz <- read.csv("inst/extdata/tz.csv") %>%  st_as_sf(coords = c('lng', 'lat'),crs=st_crs(4326))
#' count_pts(admin, tz, "REG_ID")
#' }
#' @import sf dplyr

####################################################################################################
#Count the number of points by location.
####################################################################################################
count_pts <-function(sf,pts,id){
  if(projection(sf)!="+proj=longlat +datum=WGS84 +no_defs") {
    sf <- sf %>% st_transform(4326)
  }
  if(projection(pts)!="+proj=longlat +datum=WGS84 +no_defs") {
    pts <- pts %>% st_transform(4326)
  }
  id_o <- as.name(id)
  count <- pts %>%
    st_join(., sf) %>%
    group_by(!!id_o) %>%
    summarise(count = n()) %>%
    select(!!id_o, count) %>%
    st_drop_geometry()

  count <- sf %>%
    left_join(., count, by=id) %>%
    select(!!id_o, count) %>%
    st_drop_geometry() %>%
    mutate(count = ifelse(is.na(count),0,count))
  return(count)
}
