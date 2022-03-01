
library(Racmacs)
library(testthat)

# Load the map and the chart
context("Test map transformations")

# Setup an expect close function
expect_close <- function(a, b) expect_equal(unname(round(a, 2)), unname(round(b, 2)))

# Fetch test charts
map <- read.acmap(test_path("../testdata/testmap.ace"))

# Add a 3D optimization
map <- addOptimization(
  map,
  ag_coords = matrix(runif(numAntigens(map) * 3) * 10, ncol = 3),
  sr_coords = matrix(runif(numSera(map) * 3) * 10, ncol = 3),
  minimum_column_basis = "none"
)

# Record starting coordinates
start_ag_coords <- agCoords(map)
start_sr_coords <- srCoords(map)
start_ag_coords3D <- agCoords(map, 3)
start_sr_coords3D <- srCoords(map, 3)

# Rotate the maps
map <- rotateMap(map, 32, optimization_number = 1)
map <- rotateMap(map, -49, axis = "y", optimization_number = 3)

expected_ag_coords <- rotate_coords_by_degrees(start_ag_coords, 32)
expected_sr_coords <- rotate_coords_by_degrees(start_sr_coords, 32)
expected_ag_coords3D <- rotate_coords_by_degrees(start_ag_coords3D, -49, axis = "y")
expected_sr_coords3D <- rotate_coords_by_degrees(start_sr_coords3D, -49, axis = "y")

test_that("Rotation clockwise", {
  expect_close(agCoords(map), expected_ag_coords)
  expect_close(srCoords(map), expected_sr_coords)
  expect_close(agCoords(map, 3), expected_ag_coords3D)
  expect_close(srCoords(map, 3), expected_sr_coords3D)
})

# Translate the maps
map <- translateMap(map, c(12, 18), optimization_number = 1)
map <- translateMap(map, c(12, 18, 4), optimization_number = 3)

expected_ag_coords <- translate_coords(expected_ag_coords, c(12, 18))
expected_sr_coords <- translate_coords(expected_sr_coords, c(12, 18))
expected_ag_coords3D <- translate_coords(expected_ag_coords3D, c(12, 18, 4))
expected_sr_coords3D <- translate_coords(expected_sr_coords3D, c(12, 18, 4))

test_that("Translation", {
  expect_close(agCoords(map), expected_ag_coords)
  expect_close(srCoords(map), expected_sr_coords)
  expect_close(agCoords(map, 3), expected_ag_coords3D)
  expect_close(srCoords(map, 3), expected_sr_coords3D)
})

# Rotate the maps again
map <- rotateMap(map, 756, optimization_number = 1)
map <- rotateMap(map, 12, axis = "z", optimization_number = 3)

expected_ag_coords <- rotate_coords_by_degrees(expected_ag_coords, 756)
expected_sr_coords <- rotate_coords_by_degrees(expected_sr_coords, 756)
expected_ag_coords3D <- rotate_coords_by_degrees(expected_ag_coords3D, 12, axis = "z")
expected_sr_coords3D <- rotate_coords_by_degrees(expected_sr_coords3D, 12, axis = "z")

test_that("Rotation after translation", {
  expect_close(agCoords(map), expected_ag_coords)
  expect_close(srCoords(map), expected_sr_coords)
  expect_close(agCoords(map, 3), expected_ag_coords3D)
  expect_close(srCoords(map, 3), expected_sr_coords3D)
})

# Applying the map transformation
test_that("Applying the map transformation to coordinates", {
  expect_close(applyMapTransform(start_ag_coords, map), agCoords(map))
  expect_close(applyMapTransform(start_sr_coords, map), srCoords(map))
  expect_close(applyMapTransform(start_ag_coords3D, map, 3), agCoords(map, 3))
  expect_close(applyMapTransform(start_sr_coords3D, map, 3), srCoords(map, 3))
})


# Resetting coordinates after rotation
agCoords(map)[2, ] <- c(12, 20)
srCoords(map)[3, ] <- c(6, 2)
agCoords(map, optimization_number = 3)[1, ] <- c(2, 9, 7)
srCoords(map, optimization_number = 3)[5, ] <- c(1, 2, 1)

expected_ag_coords[2, ] <- c(12, 20)
expected_sr_coords[3, ] <- c(6, 2)
expected_ag_coords3D[1, ] <- c(2, 9, 7)
expected_sr_coords3D[5, ] <- c(1, 2, 1)

test_that("Setting coordinates after rotation", {
  expect_close(agCoords(map), expected_ag_coords)
  expect_close(srCoords(map), expected_sr_coords)
  expect_close(agCoords(map, 3), expected_ag_coords3D)
  expect_close(srCoords(map, 3), expected_sr_coords3D)
})

# Flip the maps in x axis
map <- reflectMap(map, "x", optimization_number = 1)
map <- reflectMap(map, "x", optimization_number = 3)

expected_ag_coords <- expected_ag_coords %*% matrix(c(1, 0, 0, -1), 2, 2)
expected_sr_coords <- expected_sr_coords %*% matrix(c(1, 0, 0, -1), 2, 2)
expected_sr_coords3D <- expected_sr_coords3D %*% matrix(c(1, 0, 0, 0, -1, 0, 0, 0, -1), 3, 3)
expected_ag_coords3D <- expected_ag_coords3D %*% matrix(c(1, 0, 0, 0, -1, 0, 0, 0, -1), 3, 3)

test_that("Reflecting in x axis", {
  expect_close(agCoords(map), expected_ag_coords)
  expect_close(srCoords(map), expected_sr_coords)
  expect_close(agCoords(map, optimization_number = 3), expected_ag_coords3D)
  expect_close(srCoords(map, optimization_number = 3), expected_sr_coords3D)
})


# Resetting coordinates after reflection
agCoords(map)[2, ] <- c(12, 20)
srCoords(map)[3, ] <- c(6, 2)
agCoords(map, optimization_number = 3)[1, ] <- c(2, 9, 7)
srCoords(map, optimization_number = 3)[5, ] <- c(1, 2, 1)

expected_ag_coords[2, ] <- c(12, 20)
expected_sr_coords[3, ] <- c(6, 2)
expected_ag_coords3D[1, ] <- c(2, 9, 7)
expected_sr_coords3D[5, ] <- c(1, 2, 1)

test_that("Resetting coordinates after reflection", {
  expect_close(agCoords(map), expected_ag_coords)
  expect_close(srCoords(map), expected_sr_coords)
  expect_close(agCoords(map, 3), expected_ag_coords3D)
  expect_close(srCoords(map, 3), expected_sr_coords3D)
})


# Reflecting in y axis
map <- reflectMap(map, "y", optimization_number = 1)
map <- reflectMap(map, "y", optimization_number = 3)

expected_ag_coords <- expected_ag_coords %*% matrix(c(-1, 0, 0, 1), 2, 2)
expected_sr_coords <- expected_sr_coords %*% matrix(c(-1, 0, 0, 1), 2, 2)
expected_ag_coords3D <- expected_ag_coords3D %*% matrix(c(-1, 0, 0, 0, 1, 0, 0, 0, -1), 3, 3)
expected_sr_coords3D <- expected_sr_coords3D %*% matrix(c(-1, 0, 0, 0, 1, 0, 0, 0, -1), 3, 3)

test_that("Reflecting in y axis", {
  expect_close(agCoords(map), expected_ag_coords)
  expect_close(srCoords(map), expected_sr_coords)
  expect_close(agCoords(map, 3), expected_ag_coords3D)
  expect_close(srCoords(map, 3), expected_sr_coords3D)
})


# Reflecting in z axis
map <- reflectMap(map, "z", optimization_number = 3)

expected_ag_coords3D <- expected_ag_coords3D %*% matrix(c(-1, 0, 0, 0, -1, 0, 0, 0, 1), 3, 3)
expected_sr_coords3D <- expected_sr_coords3D %*% matrix(c(-1, 0, 0, 0, -1, 0, 0, 0, 1), 3, 3)

test_that("Reflecting in z axis", {
  expect_close(agCoords(map, 3), expected_ag_coords3D)
  expect_close(srCoords(map, 3), expected_sr_coords3D)
})
