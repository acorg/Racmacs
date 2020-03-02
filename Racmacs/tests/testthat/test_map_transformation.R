
library(Racmacs)
library(testthat)

# Get a record of the start environment
environment_objects <- ls()

# Load the map and the chart
context("Test map transformations")

# Setup an expect close function
expect_close <- function(a, b) expect_equal(round(a, 2), round(b, 2))

# Repeat for chart type and racmap type
for(type in c("racmap", "racchart")){

  # Fetch test charts
  if(type == "racmap")   map <- read.acmap(test_path("../testdata/testmap.ace"))
  if(type == "racchart") map <- read.acmap.cpp(test_path("../testdata/testmap.ace"))

  # Add a 3D optimization
  map <- addOptimization(map,
                         ag_coords = matrix(runif(numAntigens(map)*3)*10, ncol = 3),
                         sr_coords = matrix(runif(numSera(map)*3)*10, ncol = 3),
                         minimum_column_basis = "none")

  # Record starting coordinates
  start_ag_coords <- agCoords(map)
  start_sr_coords <- srCoords(map)
  start_ag_coords3D <- agCoords(map, 3)
  start_sr_coords3D <- srCoords(map, 3)

  # Rotate the maps
  map <- rotateMap(map, 32)
  map <- rotateMap(map, -49, axis = "y", optimization_number = 3)

  expected_ag_coords <- rotate_coords_by_degrees(start_ag_coords, 32)
  expected_sr_coords <- rotate_coords_by_degrees(start_sr_coords, 32)
  expected_ag_coords3D <- rotate_coords_by_degrees(start_ag_coords3D, -49, axis = "y")
  expected_sr_coords3D <- rotate_coords_by_degrees(start_sr_coords3D, -49, axis = "y")

  test_that(paste("Rotation clockwise", type), {
    expect_close(agCoords(map), expected_ag_coords)
    expect_close(srCoords(map), expected_sr_coords)
    expect_close(agCoords(map, 3), expected_ag_coords3D)
    expect_close(srCoords(map, 3), expected_sr_coords3D)
    expect_error(rotateMap(map, 32, optimization_number = 3))
  })

  # Translate the maps
  map <- translateMap(map, c(12, 18))
  map <- translateMap(map, c(12, 18, 4), optimization_number = 3)

  expected_ag_coords <- translate_coords(expected_ag_coords, c(12, 18))
  expected_sr_coords <- translate_coords(expected_sr_coords, c(12, 18))
  expected_ag_coords3D <- translate_coords(expected_ag_coords3D, c(12, 18, 4))
  expected_sr_coords3D <- translate_coords(expected_sr_coords3D, c(12, 18, 4))

  test_that(paste("Translation", type), {
    expect_close(agCoords(map), expected_ag_coords)
    expect_close(srCoords(map), expected_sr_coords)
    expect_close(agCoords(map, 3), expected_ag_coords3D)
    expect_close(srCoords(map, 3), expected_sr_coords3D)
  })


  # Rotate the maps again
  map <- rotateMap(map, 756)
  map <- rotateMap(map, 12, axis = "z", optimization_number = 3)

  expected_ag_coords <- rotate_coords_by_degrees(expected_ag_coords, 756)
  expected_sr_coords <- rotate_coords_by_degrees(expected_sr_coords, 756)
  expected_ag_coords3D <- rotate_coords_by_degrees(expected_ag_coords3D, 12, axis = "z")
  expected_sr_coords3D <- rotate_coords_by_degrees(expected_sr_coords3D, 12, axis = "z")

  test_that(paste("Rotation after translation", type), {
    expect_close(agCoords(map), expected_ag_coords)
    expect_close(srCoords(map), expected_sr_coords)
    expect_close(agCoords(map, 3), expected_ag_coords3D)
    expect_close(srCoords(map, 3), expected_sr_coords3D)
  })


  # Resetting coordinates after rotation
  agCoords(map)[2,] <- c(12,20)
  srCoords(map)[3,] <- c(6,2)
  agCoords(map, optimization_number = 3)[1,] <- c(2,9,7)
  srCoords(map, optimization_number = 3)[5,] <- c(1,2,1)

  expected_ag_coords[2,] <- c(12,20)
  expected_sr_coords[3,] <- c(6,2)
  expected_ag_coords3D[1,] <- c(2,9,7)
  expected_sr_coords3D[5,] <- c(1,2,1)

  test_that(paste("Setting coordinates after rotation", type), {
    expect_close(agCoords(map), expected_ag_coords)
    expect_close(srCoords(map), expected_sr_coords)
    expect_close(agCoords(map, 3), expected_ag_coords3D)
    expect_close(srCoords(map, 3), expected_sr_coords3D)
  })


  # Flip the maps in x axis
  map <- reflectMap(map, "x")
  map <- reflectMap(map, "x", optimization_number = 3)

  expected_ag_coords <- expected_ag_coords %*% matrix(c(1,0,0,-1), 2, 2)
  expected_sr_coords <- expected_sr_coords %*% matrix(c(1,0,0,-1), 2, 2)
  expected_ag_coords3D <- expected_ag_coords3D %*% matrix(c(1,0,0,0,-1,0,0,0,-1), 3, 3)
  expected_sr_coords3D <- expected_sr_coords3D %*% matrix(c(1,0,0,0,-1,0,0,0,-1), 3, 3)

  test_that(paste("Reflecting in x axis", type), {
    expect_close(agCoords(map), expected_ag_coords)
    expect_close(srCoords(map), expected_sr_coords)
    expect_close(agCoords(map, optimization_number = 3), expected_ag_coords3D)
    expect_close(srCoords(map, optimization_number = 3), expected_sr_coords3D)
  })


  # Resetting coordinates after reflection
  agCoords(map)[2,] <- c(12,20)
  srCoords(map)[3,] <- c(6,2)
  agCoords(map, optimization_number = 3)[1,] <- c(2,9,7)
  srCoords(map, optimization_number = 3)[5,] <- c(1,2,1)

  expected_ag_coords[2,] <- c(12,20)
  expected_sr_coords[3,] <- c(6,2)
  expected_ag_coords3D[1,] <- c(2,9,7)
  expected_sr_coords3D[5,] <- c(1,2,1)

  test_that(paste("Resetting coordinates after reflection", type), {
    expect_close(agCoords(map), expected_ag_coords)
    expect_close(srCoords(map), expected_sr_coords)
    expect_close(agCoords(map, 3), expected_ag_coords3D)
    expect_close(srCoords(map, 3), expected_sr_coords3D)
  })


  # Reflecting in y axis
  map <- reflectMap(map, "y")
  map <- reflectMap(map, "y", optimization_number = 3)

  expected_ag_coords <- expected_ag_coords %*% matrix(c(-1,0,0,1), 2, 2)
  expected_sr_coords <- expected_sr_coords %*% matrix(c(-1,0,0,1), 2, 2)
  expected_ag_coords3D <- expected_ag_coords3D %*% matrix(c(-1,0,0,0,1,0,0,0,-1), 3, 3)
  expected_sr_coords3D <- expected_sr_coords3D %*% matrix(c(-1,0,0,0,1,0,0,0,-1), 3, 3)

  test_that(paste("Reflecting in y axis", type), {
    expect_close(agCoords(map), expected_ag_coords)
    expect_close(srCoords(map), expected_sr_coords)
    expect_close(agCoords(map, 3), expected_ag_coords3D)
    expect_close(srCoords(map, 3), expected_sr_coords3D)
  })


  # Reflecting in z axis
  map <- reflectMap(map, "z", optimization_number = 3)

  expected_ag_coords3D <- expected_ag_coords3D %*% matrix(c(-1,0,0,0,-1,0,0,0,1), 3, 3)
  expected_sr_coords3D <- expected_sr_coords3D %*% matrix(c(-1,0,0,0,-1,0,0,0,1), 3, 3)

  test_that(paste("Reflecting in z axis", type), {
    expect_close(agCoords(map, 3), expected_ag_coords3D)
    expect_close(srCoords(map, 3), expected_sr_coords3D)
  })

}
