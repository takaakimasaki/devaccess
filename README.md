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
There are currently three different functions in the package: `calc_rai()`, `osrm_matrix()` and `friction_matrix()`. `calc_rai()` calculates the Rural Access Index, which is defined as the share of rural population living within 2km away from all-season roads, based on administrative boundary, urban extent, and road network shapefiles users provide together with a gridded population dataset. `osrm_matrix()` and `friction_matrix()` generate a matrix of travel time between different permutations of point data that users provide using the OpenStreetMap-Based Routing Service OSRM or friction maps, which can be downloaded from https://malariaatlas.org/research-project/accessibility_to_cities/ or https://malariaatlas.org/research-project/accessibility-to-healthcare/.
