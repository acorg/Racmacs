
library(Racmacs)
library(testthat)
context("Test local map creation")

# Set test table
testtable <- matrix(2 ^ (1:6) * 10, 6, 4)

# Backwards compatibility
test_that("table argument still works", {

  # Making a map from a table
  expect_warning({
    map <- acmap(
      table = testtable
    )
  }, "Argument 'table' is deprecated, please use 'titer_table' instead")

  expect_equal(numAntigens(map), 6)
  expect_equal(numSera(map), 4)

})

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

# Incorrect titers
test_that("Invalid titers", {

  expect_equal(
    numAntigens(acmap(
      titer_table = matrix(c("*", "<20", "10", ">80"), 2, 2)
    )),
    2
  )

  check_titer_error <- function(titers) {
    expect_error(
      acmap(titer_table = matrix(titers, 2, 2))
    )
  }

  check_titer_error(c("na", "<20", "10", ">80"))
  check_titer_error(c("1'230", "<20", "10", ">80"))
  check_titer_error(c("<>23", "<20", "10", ">80"))
  check_titer_error(c("<=10", "<20", "10", ">80"))
  check_titer_error(c("<10", "<20", "10", ">=80"))

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
  map <- make.acmap(
    titer_table             = testtable,
    number_of_dimensions    = 3,
    number_of_optimizations = 2,
    minimum_column_basis    = "none",
    check_convergence       = FALSE
  )
  expect_equal(numAntigens(map), 6)
  expect_equal(numSera(map), 4)
})

test_that("Making a map and optimizing using table arg", {
  expect_warning({
    map <- make.acmap(
      table                   = testtable,
      number_of_dimensions    = 3,
      number_of_optimizations = 2,
      minimum_column_basis    = "none"
    )
  }, "Argument 'table' is deprecated, please use 'titer_table' instead")
  expect_equal(numAntigens(map), 6)
  expect_equal(numSera(map), 4)
})


