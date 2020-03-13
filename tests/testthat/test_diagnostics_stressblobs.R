
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
agCoords(map)[3,] <- NA
srCoords(map)[2,] <- NA

testthat::test_that("Default stress blob calculation with NA coords", {

  blob_data <- calculate_stressBlob(
    map = map
  )

})


run.maptests(
  bothclasses = TRUE,
  loadlocally = FALSE,
  {

    map <- read.map(testthat::test_path("../testdata/testmap.ace"))
    expect_error(stressBlobs(map, progress_fn = function(x){}))

    # General stress blob viewing
    map <- relaxMap(map)
    export.viewer.test(
      view(stressBlobs(map, progress_fn = function(x){})),
      filename = "map_with_stressblobs.html"
    )

  }
)
