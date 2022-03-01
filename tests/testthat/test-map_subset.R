
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
test_map_subset <- function(map, ag_subset, sr_subset) {

  map_subset <- subsetMap(map, ag_subset, sr_subset)
  ag_subset <- get_ag_indices(ag_subset, map)
  sr_subset <- get_sr_indices(sr_subset, map)

  # Original map unaffected
  expect_equal(numAntigens(map), num_antigens)
  expect_equal(numSera(map), num_sera)

  # Antigen and sera subset
  expect_equal(agNames(map_subset), agNames(map)[ag_subset])
  expect_equal(srNames(map_subset), srNames(map)[sr_subset])

  # Reactivity adjustments
  expect_equal(agReactivityAdjustments(map_subset), agReactivityAdjustments(map)[ag_subset])

  # Titer table
  expect_equal(titerTable(map_subset), titerTable(map)[ag_subset, sr_subset])

  # Optimizations
  for (x in seq_len(numOptimizations(map))) {
    expect_equal(agCoords(map_subset, x), agCoords(map, x)[ag_subset, , drop = F])
    expect_equal(srCoords(map_subset, x), srCoords(map, x)[sr_subset, , drop = F])
  }

  # Plotspec
  expect_equal(agFill(map_subset), agFill(map)[ag_subset])
  expect_equal(srFill(map_subset), srFill(map)[sr_subset])

  expect_equal(
    ptDrawingOrder(map_subset),
    rank(ptDrawingOrder(map)[c(ag_subset, sr_subset + numAntigens(map))], ties.method = "first")
  )

}

test_that("Error on incorrect subsetting", {

  expect_error(subsetMap(map, antigens = 0))
  expect_error(subsetMap(map, sera = 0))

  expect_error(subsetMap(map, antigens = num_antigens + 1))
  expect_error(subsetMap(map, sera = num_sera + 1))

})

test_that("Subset of map is correct", {

  test_map_subset(map, seq_len(num_antigens - 1), seq_len(num_sera - 1))
  test_map_subset(map, seq_len(num_antigens - 1) + 1, seq_len(num_sera - 1) + 1)
  test_map_subset(map, c(1, 1, 2, 3), c(2, 2, 2))
  test_map_subset(map, c(2, 1, 2, 3), c(3, 2, 1))

})
