
library(testthat)
context("Plotting a map")

test_that("Plotting a bare bones", {

  map <- acmap(
    ag_coords = matrix(1:10, 5),
    sr_coords = matrix(1:8,  4),
    minimum_column_basis = "none"
  )

  x <- plot(map)
  expect_true(inherits(x, "acmap"))

  export.plot.test(
    plot(map),
    "simplemap.pdf",
    8, 8
  )

})

test_that("Plotting a map with error lines", {

  map <- read.acmap(test_path("../testdata/testmap.ace"))

  x <- plot(map, show_error_lines = TRUE)
  export.plot.test(
    plot(map),
    "simplemap.pdf",
    8, 8
  )

})
