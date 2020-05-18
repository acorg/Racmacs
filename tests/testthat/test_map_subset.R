
library(Racmacs)
library(testthat)

# Set test context
context("Subsetting maps")

# Fetch test charts
run.maptests(
  bothclasses = TRUE,
  loadlocally = FALSE,
  {

    map <- read.map(testthat::test_path("../testdata/testmap.ace"))

    # Check initial number of antigens and sera
    num_antigens <- numAntigens(map)
    num_sera     <- numSera(map)

    # Subset the maps
    map_subset <- subsetMap(map, antigens = seq_len(num_antigens - 1), sera = 1 + seq_len(num_sera - 1))
    map_subset_ags <- subsetMap(map, antigens = seq_len(num_antigens - 1))
    map_subset_sr  <- subsetMap(map, sera = 1 + seq_len(num_sera - 1))

    testthat::test_that("Original map unaffected",{
      testthat::expect_equal(numAntigens(map), num_antigens)
      testthat::expect_equal(numSera(map), num_sera)
    })

    testthat::test_that("Subset of map is correct",{

      testthat::expect_equal(numAntigens(map_subset), num_antigens-1)
      testthat::expect_equal(numSera(map_subset), num_sera-1)

      testthat::expect_equal(length(agNames(map_subset)), num_antigens-1)
      testthat::expect_equal(length(srNames(map_subset)), num_sera-1)

      testthat::expect_equal(length(agDates(map_subset)), num_antigens-1)

      testthat::expect_equal(dim(titerTable(map_subset)), c(9,4))

    })

})



