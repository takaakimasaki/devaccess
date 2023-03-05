#' Compute the share of population in a certain distance from points (e.g., conflicts, cities).
#' @param sf object of class sf containing administrative boundaries.
#' @param pts object of class sf containing points.
#' @param pop object of class raster containing gridded population data.
#' @param epsg_utm integer; reproject line using epsg_utm.
#' @param id location ID.
#' @param dist object of class numeric; the length of a radius around pts to be considered for calculating the share of pop.
#' @export
#' @return `cal_pop_share()` returns a data.frame object with id (row ID of sf), total_pop (total population),pop_buffer (population in buffer areas), and share (% of people in buffer areas).
#' @examples
#' \dontrun{
#' admin <- sf::st_read("inst/extdata/zanzibar_dhs_adm1.shp") ##administrative boundaries
#' tz <- read.csv("inst/extdata/tz.csv") %>%  st_as_sf(coords = c('lng', 'lat'),crs=st_crs(4326))
#' pop <- raster("inst/extdata/zanzibar_ppp_2020_constrainted.tif") ##population raster
#' cal_pop_share(admin, tz, pop, epsg_utm = 21035, dist = 2000, id = "REGNAME")
#' }
#' @import sf dplyr

####################################################################################################
#Count the number of points by location.
####################################################################################################
cal_pop_share <-function(sf,pts,pop,epsg_utm,dist,id){
  id_o <- as.name(id)
  sf <- sf %>%
    mutate(id = seq(1:dim(sf)[1]))

  pts <- st_transform(pts, epsg_utm)
  pts_buffer <- st_buffer(st_union(pts), dist = dist)

  # intersect buffer with sf
  pts <- st_transform(pts, 4326)
  pts_buffer <- st_transform(pts_buffer, 4326)
  sf <- st_transform(sf, 4326)
  sf <-  sf::st_make_valid(sf)
  pts_buffer_in_sf <- st_intersection(sf, pts_buffer)

  # calculate total population & population in buffer
  # total population
  sf$total_pop <- exact_extract(pop, sf, "sum")
  # population in buffer areas
  pts_buffer_in_sf$pop_buffer <- exact_extract(pop, pts_buffer_in_sf, "sum")

  # group by polygon
  pts_buffer_in_sf_grouped <- as.data.frame(pts_buffer_in_sf) %>%
    dplyr::group_by(!!id_o) %>%
    dplyr::summarize(pop_buffer=sum(pop_buffer))
  sf <- left_join(sf, pts_buffer_in_sf_grouped, by=id)

  # calculate the share
  sf <- sf %>%
    mutate(share=(pop_buffer/total_pop)*100) %>%
    mutate(share=case_when(
      share>0~share,
      share==0~as.numeric(NA)
    )) %>%
      dplyr::select(!!id_o, pop_buffer, share) %>%
    st_drop_geometry()
  return(sf)
}

