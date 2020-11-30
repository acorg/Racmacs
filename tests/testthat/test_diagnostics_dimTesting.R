
library(testthat)
context("Dimension testing")


map <- read.acmap(test_path("../testdata/testmap.ace"))
test_that("Dimension testing acmap.cpp", {

  results <- dimensionTestMap(
    map                       = map,
    dimensions_to_test        = 2,
    test_proportion           = 0.1,
    minimum_column_basis      = "none",
    column_bases_from_master  = TRUE,
    number_of_optimizations   = 10,
    replicates_per_proportion = 20
  )

  expect_equal(nrow(results), 1)

})

test_that("Dimension testing acmap.cpp and saving intermediate maps", {

  tdir <- tempdir()
  results <- dimensionTestMap(
    map                       = map,
    dimensions_to_test        = 2,
    test_proportion           = 0.1,
    minimum_column_basis      = "none",
    column_bases_from_master  = TRUE,
    number_of_optimizations   = 10,
    replicates_per_proportion = 20,
    storage_directory         = tdir
  )

  expect_equal(nrow(results), 1)
  expect_gt(
    length(list.files(tdir)),
    0
  )

})

