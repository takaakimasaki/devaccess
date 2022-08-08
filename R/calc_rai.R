#' Calculate rural access index.
#' @param admin object of class sf.
#' @param line object of class sf.
#' @param urban object of class sf.
#' @param pop object of class raster.
#' @param epsg_utm integer; reproject line using epsg_utm.
#' @param distance numeric; buffer distance for all, or for each of the elements in x.
#' @export
#' @return calc_rai returns a data.frame object with pop_rural (rural population), pop_urban (urban population), pop_urban_s (percent of urban population), pop_rural_osm (rural population living under dist km from line), and rai (Rural Access Index or percent of rural population living under dist km from line).
#' @examples
#'\dontrun{
#' line <- sf::st_read("data/zamzibar_osm_road.shp") ##road network
#' urban <- sf::st_read("data/urban_tanzania.shp") ##urban area
#' admin <- sf::st_read("data/zanzibar_dhs_adm1.shp") ##administrative boundaries
#' pop <- raster("data-raw/zanzibar_ppp_2020_constrainted.tif") ##population raster
#' rai <- calc_rai(admin, line, urban, pop, epsg_utm = 21035, dist = 2000)
#'}
#' @import sf dplyr exactextractr
#' @importFrom raster raster crop mask

####################################################################################################
#Compute Rural Access Index
####################################################################################################
calc_rai <- function(admin, line, urban, pop, epsg_utm, dist) {
#epsg_utm = 21035
#dist = 2000

##now create buffer
line <- line %>%
  st_transform(epsg_utm) %>%
  st_buffer(dist = dist) %>% #2km radius
  st_union()

admin$id <- seq(1:dim(admin)[1])
admin <- admin %>% st_transform(4326) %>% st_make_valid()
urban <- st_transform(urban,4326) %>% st_make_valid()
line <- st_transform(line,4326) %>% st_make_valid()

##urban population
comb_admin_urban <- st_intersection(admin,urban)
##population within 2km away from all-season lines
comb_admin_line <- st_intersection(admin, line)
##urban population within 2km away from all-season lines
comb_admin_line <- comb_admin_line %>% st_make_valid()
comb_line_urban <- st_intersection(comb_admin_line, urban)

#ok now compute population in each of the layers being created above
##read population data
#now compute zonal statistics of population
stats <- c('sum')
admin_pop <- exact_extract(pop,admin, stats) %>% as.data.frame()
names(admin_pop) <- c("pop1")
admin <- cbind(admin,admin_pop)

comb_admin_urban_pop <- exact_extract(pop, comb_admin_urban, stats) %>% as.data.frame()
names(comb_admin_urban_pop) <- c("pop2")
comb_admin_urban <- cbind(comb_admin_urban,comb_admin_urban_pop)
pop2 <- comb_admin_urban %>% group_by(id) %>% summarize(pop2=sum(pop2))

comb_admin_line_pop <- exact_extract(pop, comb_admin_line, stats) %>% as.data.frame()
names(comb_admin_line_pop) <- c("pop3")
comb_admin_line <- cbind(comb_admin_line,comb_admin_line_pop)
pop3 <- comb_admin_line %>% group_by(id) %>% summarize(pop3=sum(pop3))

comb_line_urban_pop <- exact_extract(pop, comb_line_urban, stats) %>% as.data.frame()
names(comb_line_urban_pop) <- c("pop4")
comb_line_urban <- cbind(comb_line_urban,comb_line_urban_pop)
pop4 <- comb_line_urban %>% group_by(id) %>% summarize(pop4=sum(pop4))

#ok now combine all the datasets
admin_df <- data.frame(admin)
pop2 <- data.frame(pop2)
pop3 <- data.frame(pop3)
pop4 <- data.frame(pop4)
admin_df <- admin_df %>%
  left_join(.,pop2,by="id") %>%
  left_join(.,pop3,by="id") %>%
  left_join(.,pop4,by="id")

admin_df <- admin_df[,c("id","pop1","pop2","pop3","pop4")]
admin_df[is.na(admin_df)] <- 0

sum(admin_df$pop1)
admin_df <- admin_df %>%
  mutate(pop_rural = pop1 - pop2,
         pop_urban = pop2,
         pop_urban_s = (pop2/pop1)*100,
         pop_rural_osm = pop3 - pop4,
         rai = (pop_rural_osm/pop_rural)*100) %>%
  dplyr::select(-pop1,-pop2,-pop3,-pop4)

admin_df <- admin_df %>%
  mutate(rai=replace(rai, pop_urban_s==100, 100))
admin_df
}

#rai <- devaccess::calc_rai(admin, line, urban, pop, epsg_utm = 21035, dist = 2000)
