
library(Racmacs)

# Get a record of the start environment
environment_objects <- ls()

# Load the map and the chart
testthat::context("Conversion of maps")

# Fetch test charts
chart <- read.acmap.cpp(testthat::test_path("../testdata/testmap.ace"))
map <- read.acmap(testthat::test_path("../testdata/testmap.ace"))


testthat::test_that("Conversion to chart and back", {

  acmapChart      <- as.cpp(map)
  acmapChartAcmap <- as.list(acmapChart)
  testthat::expect_equal(map, acmapChartAcmap)

})


testthat::test_that("Converting empty chart", {

  hitable <- matrix("20", 2, 2)
  chart   <- acmap.cpp(table = hitable)
  map     <- acmap(table = hitable)
  testthat::expect_equal(titerTable(map), titerTable(chart))

})


# Converting to the json format
testthat::test_that("Converting to json format", {

  chart_json  <- as.json(chart)
  racmap_json <- as.json(map)

  testthat::expect_equal(chart_json, racmap_json)

})

# Clean up
rm(list = ls()[!ls() %in% environment_objects])
