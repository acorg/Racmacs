
library(testthat)
context("Plotting a map")

run.maptests(
  bothclasses = TRUE,
  loadlocally = FALSE,
  {

  test_that("Plotting a bare bones", {

    map <- make.map(
      ag_coords = matrix(1:10, 5),
      sr_coords = matrix(1:8,  4),
      minimum_column_basis = "none"
    )

    x <- plot(map)
    expect_null(x)

  })

})



