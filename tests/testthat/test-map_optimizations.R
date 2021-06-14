
library(Racmacs)
library(testthat)
context("Test optimization methods")

# Create a toy HI table
titer_table <- rbind(
  c("<10", "40",  "*",  "1280", "10"),
  c("<10", "10", "80", "640", "10"),
  c("10", "10", "10", "10", "10"),
  c("10", "10", "10", "10", "10"),
  c("10", "10", "10", "10", "10")
)

num_antigens <- nrow(titer_table)
num_sera     <- ncol(titer_table)

# Create a new map
map <- make.acmap(
  titer_table = titer_table,
  number_of_optimizations = 5
)

ag_names   <- agNames(map)
sera_names <- srNames(map)

# Add some optimizations
minimum_column_bases <- c("640", "none")
dimensions           <- c(2, 3)

for (x in seq_along(minimum_column_bases)) {

  minimum_column_basis <- minimum_column_bases[x]

  ag_coords <- matrix(1, num_antigens, dimensions[x])
  sr_coords <- matrix(1, num_sera,     dimensions[x])

  map <- addOptimization(
    map                  = map,
    ag_coords            = ag_coords,
    sr_coords            = sr_coords,
    minimum_column_basis = minimum_column_basis
  )

}

# Setting crazy values of wrong type
test_that("Incorrect inputs", {
  expect_error(agBaseCoords(map) <- rep(1, 1000))
  expect_error(srBaseCoords(map) <- rep(1, 1000))
  expect_error(mapTransformation(map) <- rep(1, 1000))
  expect_error(mapTranslation(map) <- rep(1, 1000))
  expect_error(mapComment(map) <- rep(1, 1000))
  expect_error(mapStress(map) <- rep(1, 1000))
})

# Wrong length mincolbasis
test_that("Min column bases wrong length throws error", {
  expect_error(
    addOptimization(
      map       = map,
      ag_coords = ag_coords,
      sr_coords = sr_coords,
      minimum_column_basis = c("1280", "none")
    )
  )
})

# Colbases fixed without specifying what they are
test_that("Error when fixed col bases specified", {
  expect_error(
    addOptimization(
      map       = map,
      ag_coords = ag_coords,
      sr_coords = sr_coords,
      minimum_column_basis = "fixed"
    ),
    regexp = "Invalid titer 'fixed'"
  )
})

# Column bases wrong length
test_that("Error when column bases the wrong length", {
  expect_error(
    addOptimization(
      map       = map,
      ag_coords = ag_coords,
      sr_coords = sr_coords,
      minimum_column_basis = "fixed",
      fixed_column_bases = c(4, 3, 4, 5, 9, 8)
    ),
    regexp = "Fixed column base length does not match the number of sera"
  )
})
# Add an optimization correctly
testmap <- addOptimization(
  map       = map,
  ag_coords = ag_coords,
  sr_coords = sr_coords,
  fixed_column_bases = c(4, 3, 4, 5, 5)
)

optimization_num <- numOptimizations(testmap)

# Check column bases worked
test_that("Fixed column bases specified correctly upon adding optimization", {
  expect_equal(
    unname(colBases(testmap, optimization_num)),
    c(4, 3, 4, 5, 5)
  )
})
