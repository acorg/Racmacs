
library(testthat)
context("Plotting a map")

run.maptests(
  bothclasses = TRUE,
  loadlocally = FALSE,
  {

  test_that(paste("Plotting a bare bones", maptype), {

    map <- make.map(
      ag_coords = matrix(1:10, 5),
      sr_coords = matrix(1:8,  4),
      minimum_column_basis = "none"
    )

    x <- plot(map)
    testthat::expect_null(x)

  })

})



