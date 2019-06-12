
library(Racmacs)

# Get a record of the start environment
environment_objects <- ls()

# Load the map and the chart
testthat::context("Subsetting maps")

# Fetch test charts
chart <- read.acmap.cpp(testthat::test_path("../testdata/testmap.ace"))
acmap <- read.acmap(testthat::test_path("../testdata/testmap.ace"))

# Check initial number of antigens and sera
num_antigens <- numAntigens(chart)
num_sera     <- numSera(chart)

# Subset the maps
chart_subset <- subsetMap(chart, antigens = seq_len(num_antigens - 1), sera = 1 + seq_len(num_sera - 1))
acmap_subset <- subsetMap(acmap, antigens = seq_len(num_antigens - 1), sera = 1 + seq_len(num_sera - 1))

testthat::test_that("Original map unaffected",{
  testthat::expect_equal(numAntigens(chart), num_antigens)
  testthat::expect_equal(numAntigens(acmap), num_antigens)
  testthat::expect_equal(numSera(chart), num_sera)
  testthat::expect_equal(numSera(acmap), num_sera)
})

# Clean up
rm(list = ls()[!ls() %in% environment_objects])


