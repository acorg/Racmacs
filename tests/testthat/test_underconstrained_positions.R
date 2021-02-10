
library(testthat)
library(Racmacs)
context("Test underconstrained positions")

# Read titer_table with missing data

titertable <- read.titerTable("../testdata/titer_tables/titer_table5_underconstrained.csv")
map <- acmap(titer_table = titertable)

test_that("Warn of undercontrained positions", {
  expect_warning(
    optimizeMap(
      map = map,
      number_of_dimensions = 2,
      number_of_optimizations = 1,
      minimum_column_basis = "none",
    ),
    "Some points are undercontrained for the given dimension"
  )
})

test_that("Optimize points if underconstrained but have finite positions", {
  res <- optimizeMap(
    map = map,
    number_of_dimensions = 2,
    number_of_optimizations = 1,
    minimum_column_basis = "none",
  )
  expect_false(anyNA(agBaseCoords(res, 1)))
})

test_that("Error for undercontrained points with infinite positions", {
  titerTable(map)[4, 2] <- "*"
  expect_error(
    optimizeMap(
      map = map,
      number_of_dimensions = 2,
      number_of_optimizations = 1,
      minimum_column_basis = "none",
    ),
    "Some points are undercontrained for the given dimension"
  )
})
