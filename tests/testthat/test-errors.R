
library(testthat)
context("Test errors")

map <- acmap(
  titer_table = matrix("20", 3, 3)
)

test_that("errors when no optimizations are available", {

  expect_error(
    colBases(map),
    "Map has no optimization runs"
  )

})
