
library(Racmacs)

# Get a record of the start environment
environment_objects <- ls()

# Load the map and the chart
testthat::context("Test map transformations")

# Repeat for chart type and racmap type
for(type in c("racmap", "racchart")){

  # Fetch test charts
  if(type == "racmap")   map <- read.acmap(testthat::test_path("../testdata/testmap.ace"))
  if(type == "racchart") map <- read.acmap.cpp(testthat::test_path("../testdata/testmap.ace"))

  # Add a 3D optimization
  map <- addOptimization(map,
                         ag_coords = matrix(runif(numAntigens(map)*3)*10, ncol = 3),
                         sr_coords = matrix(runif(numSera(map)*3)*10, ncol = 3),
                         warnings = FALSE)

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

  testthat::test_that(paste("Rotation clockwise", type), {
    testthat::expect_equal(agCoords(map), expected_ag_coords)
    testthat::expect_equal(srCoords(map), expected_sr_coords)
    testthat::expect_equal(agCoords(map, 3), expected_ag_coords3D)
    testthat::expect_equal(srCoords(map, 3), expected_sr_coords3D)
    testthat::expect_error(rotateMap(map, 32, optimization_number = 3))
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

  testthat::test_that(paste("Setting coordinates after rotation", type), {
    testthat::expect_equal(agCoords(map), expected_ag_coords)
    testthat::expect_equal(srCoords(map), expected_sr_coords)
    testthat::expect_equal(agCoords(map, 3), expected_ag_coords3D)
    testthat::expect_equal(srCoords(map, 3), expected_sr_coords3D)
  })


  # Flip the maps in x axis
  map <- reflectMap(map, "x")
  map <- reflectMap(map, "x", optimization_number = 3)

  expected_ag_coords <- expected_ag_coords %*% matrix(c(1,0,0,-1), 2, 2)
  expected_sr_coords <- expected_sr_coords %*% matrix(c(1,0,0,-1), 2, 2)
  expected_ag_coords3D <- expected_ag_coords3D %*% matrix(c(1,0,0,0,-1,0,0,0,-1), 3, 3)
  expected_sr_coords3D <- expected_sr_coords3D %*% matrix(c(1,0,0,0,-1,0,0,0,-1), 3, 3)

  testthat::test_that(paste("Reflecting in x axis", type), {
    testthat::expect_equal(agCoords(map), expected_ag_coords)
    testthat::expect_equal(srCoords(map), expected_sr_coords)
    testthat::expect_equal(agCoords(map, optimization_number = 3), expected_ag_coords3D)
    testthat::expect_equal(srCoords(map, optimization_number = 3), expected_sr_coords3D)
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

  testthat::test_that(paste("Resetting coordinates after reflection", type), {
    testthat::expect_equal(agCoords(map), expected_ag_coords)
    testthat::expect_equal(srCoords(map), expected_sr_coords)
    testthat::expect_equal(agCoords(map, 3), expected_ag_coords3D)
    testthat::expect_equal(srCoords(map, 3), expected_sr_coords3D)
  })


  # Reflecting in y axis
  map <- reflectMap(map, "y")
  map <- reflectMap(map, "y", optimization_number = 3)

  expected_ag_coords <- expected_ag_coords %*% matrix(c(-1,0,0,1), 2, 2)
  expected_sr_coords <- expected_sr_coords %*% matrix(c(-1,0,0,1), 2, 2)
  expected_ag_coords3D <- expected_ag_coords3D %*% matrix(c(-1,0,0,0,1,0,0,0,-1), 3, 3)
  expected_sr_coords3D <- expected_sr_coords3D %*% matrix(c(-1,0,0,0,1,0,0,0,-1), 3, 3)

  testthat::test_that(paste("Reflecting in y axis", type), {
    testthat::expect_equal(agCoords(map), expected_ag_coords)
    testthat::expect_equal(srCoords(map), expected_sr_coords)
    testthat::expect_equal(agCoords(map, 3), expected_ag_coords3D)
    testthat::expect_equal(srCoords(map, 3), expected_sr_coords3D)
  })


  # Reflecting in z axis
  map <- reflectMap(map, "z", optimization_number = 3)

  expected_ag_coords3D <- expected_ag_coords3D %*% matrix(c(-1,0,0,0,-1,0,0,0,1), 3, 3)
  expected_sr_coords3D <- expected_sr_coords3D %*% matrix(c(-1,0,0,0,-1,0,0,0,1), 3, 3)

  testthat::test_that(paste("Reflecting in z axis", type), {
    testthat::expect_equal(agCoords(map, 3), expected_ag_coords3D)
    testthat::expect_equal(srCoords(map, 3), expected_sr_coords3D)
  })

}
