
library(testthat)
context("Dimension testing")

# Read in test map
map     <- read.acmap(testthat::test_path("../testdata/testmap.ace"))
map.cpp <- read.acmap.cpp(testthat::test_path("../testdata/testmap.ace"))

# List case
testthat::test_that("Dimension testing acmap.cpp", {

  results <- dimensionTestMap(map = map,
                              dimensions_to_test = 2,
                              test_proportion = 0.1,
                              minimum_column_basis = "none",
                              column_bases_from_master = TRUE)

  testthat::expect_equal(nrow(results), 1)

})

# C++ case
testthat::test_that("Dimension testing acmap.cpp", {

  results <- dimensionTestMap(map = map.cpp,
                              dimensions_to_test = 2,
                              test_proportion = 0.1,
                              minimum_column_basis = "none",
                              column_bases_from_master = TRUE)

  testthat::expect_equal(nrow(results), 1)

})
