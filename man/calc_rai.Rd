% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calc_rai.R
\name{calc_rai}
\alias{calc_rai}
\title{Calculate rural access index.}
\usage{
calc_rai(admin, line, urban, pop, epsg_utm, dist)
}
\arguments{
\item{admin}{object of class sf.}

\item{line}{object of class sf.}

\item{urban}{object of class sf.}

\item{pop}{object of class raster.}

\item{epsg_utm}{integer; reproject line using epsg_utm.}

\item{dist}{numeric; buffer distance for all, or for each of the elements in x.}
}
\value{
`calc_rai()` returns a data.frame object with pop_rural (rural population), pop_urban (urban population), pop_urban_s (percent of urban population), pop_rural_osm (rural population living under dist km from line), and rai (Rural Access Index or percent of rural population living under dist km from line).
}
\description{
Calculate rural access index.
}
\examples{
\dontrun{
line <- sf::st_read("inst/extdata/zamzibar_osm_road.shp") ##road network
urban <- sf::st_read("inst/extdata/urban_tanzania.shp") ##urban area
admin <- sf::st_read("inst/extdata/zanzibar_dhs_adm1.shp") ##administrative boundaries
pop <- raster("inst/extdata/zanzibar_ppp_2020_constrainted.tif") ##population raster
rai <- calc_rai(admin, line, urban, pop, epsg_utm = 21035, dist = 2000)
}
}
