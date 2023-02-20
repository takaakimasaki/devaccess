testthat::test_that("Check if points are counted properly.", {
  expect_equal({
    tz <- devaccess::tz %>%  st_as_sf(coords = c('lng', 'lat'),crs=st_crs(4326))
    counts <- devaccess::count_pts(sf=devaccess::bounds_adm1,pts=tz, id="REGNAME")
    sum(counts$count)
  }, 30)
})
