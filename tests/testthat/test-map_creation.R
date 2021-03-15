
library(Racmacs)
library(testthat)
context("Test local map creation (test_map_creation.R)")

# Set test table
testtable <- matrix(2 ^ (1:6) * 10, 3, 2)

# Bare bones creation
test_that("Bare bones creation", {

  # Making a map from a table
  actablemap <- acmap(
    titer_table = testtable
  )
  mode(testtable) <- "character"
  expect_equal(
    unname(titerTable(actablemap)),
    testtable
  )


  ag_names <- paste("Antigen", 1:5)
  sr_names <- paste("Serum", 1:5)

  ag_coords <- matrix(1:10, 5, 2)
  sr_coords <- matrix(11:20, 5, 2)

  ag_coords3d <- cbind(ag_coords, 2)
  sr_coords3d <- cbind(sr_coords, 2)

  map <- acmap(
    ag_names = ag_names,
    sr_names = sr_names
  )

  expect_error(agCoords(map) <- ag_coords)
  expect_error(srCoords(map) <- sr_coords)

  map3d <- acmap(
    ag_names = ag_names,
    sr_names = sr_names
  )

  expect_error(agCoords(map) <- ag_coords3d, "optimization run not found")
  expect_error(srCoords(map) <- sr_coords3d, "optimization run not found")

  # expect_equal(unname(agCoords(map)), ag_coords)
  # expect_equal(unname(srCoords(map)), sr_coords)
  # expect_equal(unname(agCoords(map3d)), ag_coords3d)
  # expect_equal(unname(srCoords(map3d)), sr_coords3d)
  # expect_equal(numOptimizations(map), 1)

})

# Incorrect arguments
test_that("Disallowed arguments", {

  expect_error(make.acmap(ag_coords = matrix(1:10)))
  expect_error(make.acmap(foo = "bar", bar = "foo"))

})

# Cloning
map  <- read.acmap(filename = test_path("../testdata/testmap.ace"))
map2 <- keepSingleOptimization(map, 2)

test_that("Removing optimizations", {
  expect_equal(numOptimizations(map),  3)
  expect_equal(numOptimizations(map2), 1)
})

# Using acmap
test_that("Making a map and optimizing", {
  make.acmap(
    titer_table             = testtable,
    number_of_dimensions    = 3,
    number_of_optimizations = 2,
    minimum_column_basis    = "none"
  )
})