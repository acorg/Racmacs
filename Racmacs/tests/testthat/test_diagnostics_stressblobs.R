
library(testthat)
context("Stress blobs")

# Read in test map
map <- read.acmap.cpp(testthat::test_path("../testdata/testmap.ace"))

# Normal case
testthat::test_that("Default stress blob calculation", {

  blob_data <- calculate_stressBlob(
    map = map
  )

  expect_equal(
    length(blob_data$blob_data$antigens),
    numAntigens(map)
  )

  expect_equal(
    length(blob_data$blob_data$sera),
    numSera(map)
  )

})

# NA coords
map$ag_coords[3,] <- NA
map$sr_coords[2,] <- NA

testthat::test_that("Default stress blob calculation with NA coords", {

  blob_data <- calculate_stressBlob(
    map = map
  )

})
