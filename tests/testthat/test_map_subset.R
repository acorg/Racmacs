
library(Racmacs)
library(testthat)

# Set test context
context("Subsetting maps")

# Fetch test charts
map <- read.acmap(test_path("../testdata/testmap.ace"))

# Check initial number of antigens and sera
num_antigens <- numAntigens(map)
num_sera     <- numSera(map)

# Subset the maps
Racmacs:::ac_subset_map(map, seq_len(num_antigens - 1), 1 + seq_len(num_sera - 1))

map_subset <- subsetMap(map, antigens = seq_len(num_antigens - 1), sera = 1 + seq_len(num_sera - 1))
map_subset_ags <- subsetMap(map, antigens = seq_len(num_antigens - 1))
map_subset_sr  <- subsetMap(map, sera = 1 + seq_len(num_sera - 1))

test_that("Original map unaffected",{
  expect_equal(numAntigens(map), num_antigens)
  expect_equal(numSera(map), num_sera)
})

test_that("Subset of map is correct",{

  expect_equal(numAntigens(map_subset), num_antigens-1)
  expect_equal(numSera(map_subset), num_sera-1)

  expect_equal(length(agNames(map_subset)), num_antigens-1)
  expect_equal(length(srNames(map_subset)), num_sera-1)

  expect_equal(length(agDates(map_subset)), num_antigens-1)

  expect_equal(dim(titerTable(map_subset)), c(9,4))

})



