# devaccess

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

devaccess is a package that produces a variety of accessiblity measures (e.g., market access, rural access, travel time to cities or other facilities).

## Installation:

    # Install development version from GitHub
    remotes::install_github("takaakimasaki/devaccess")

## Usage:
### Calculating market accessibility and rural access index.
There are currently five different functions in the package: `calc_rai()`, `osrm_matrix()`, `friction_matrix()`, `count_pts()` and `city_bound()`. `calc_rai()` calculates the Rural Access Index, which is defined as the share of rural population living within 2km away from all-season roads, based on administrative boundary, urban extent, and road network shapefiles users provide together with a gridded population dataset. Use  `?devaccess::calc_rai()` for more details.

`osrm_matrix()` and `friction_matrix()` generate a matrix of travel time between different permutations of point data that users provide using the OpenStreetMap-Based Routing Service OSRM or friction maps, which can be downloaded from https://malariaatlas.org/research-project/accessibility_to_cities/ or https://malariaatlas.org/research-project/accessibility-to-healthcare/. Use  `?devaccess::osrm_matrix()` and `?devaccess::friction_matrix()` for more details.

### Demarcating city boundaries
In some countries, you do not necessarily have data on the population size of a city or a shapefile of all urban agglomerations, which then can be used to compute market accessibility measures. One approach would be to use high-resolution population data, apply it to construct your own boundaries of urban agglomerations, and then use them to compute market accessibility measures. 

`city_bound()` allows you to create your own shapefile of city boundaries based on any population raster data and any threshold of population density you choose to determine which area should be considered as part of cities. Use `?devaccess::city_bound()` for more details.

### Counting the number of points by administrative areas
`count_pts()` allows you to count the number of points that lie within each polygon. Use `?devaccess::count_pts()` for more details.
