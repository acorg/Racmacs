
library(Racmacs)
library(testthat)
context("Test local map creation")

run.maptests(
  bothclasses = TRUE,
  loadlocally = FALSE,
  {

    # Bare bones creation
    test_that("Bare bones creation", {

      # Making a map from a table
      testtable <- matrix(2^(1:6)*10, 3, 2)
      actablemap <- make.map(
        table = testtable
      )
      mode(testtable) <- "character"
      expect_equal(
        unname(titerTable(actablemap)),
        testtable
      )


      ag_names <- paste("Antigen", 1:5)
      sr_names <- paste("Serum", 1:5)

      ag_coords <- matrix(1:10,5,2)
      sr_coords <- matrix(11:20,5,2)

      ag_coords3d <- cbind(ag_coords, 2)
      sr_coords3d <- cbind(sr_coords, 2)

      expect_warning({
        map <- make.map(ag_coords = ag_coords,
                        sr_coords = sr_coords)
      })

      expect_warning({
        map3d <- make.map(ag_coords = ag_coords3d,
                          sr_coords = sr_coords3d)
      })

      expect_equal(unname(agCoords(map)), ag_coords)
      expect_equal(unname(srCoords(map)), sr_coords)
      expect_equal(unname(agCoords(map3d)), ag_coords3d)
      expect_equal(unname(srCoords(map3d)), sr_coords3d)
      expect_equal(numOptimizations(map), 1)

    })

    # Incorrect arguments
    test_that("Disallowed arguments", {

      expect_error(make.newmap(ag_coords = matrix(1:10)))
      expect_error(make.newmap(foo = "bar", bar = "foo"))

    })


    # Checking input types
    test_that("Argument format conversion", {

      # Matrices should be allowed and converted to data frames
      expect_warning({
        map <- make.map(ag_coords = expand.grid(1:10, 1:10),
                        sr_coords = expand.grid(1:10, 1:10))
      })

    })

    # Multioptimization creation
    test_that("Multioptimization creation", {

      expect_warning({
        acmap <- make.map(optimizations = list(
          list(ag_coords = matrix(1:10,5,2),
               sr_coords = matrix(11:20,5,2)),
          list(ag_coords = matrix(10:1,5,2),
               sr_coords = matrix(20:11,5,2))
        ))
      })

    })

    # Cloning
    map  <- read.map(filename = test_path("../testdata/testmap.ace"))
    map2 <- cloneMap(map)
    map2 <- keepSingleOptimization(map2, 2)

    test_that("Cloning racchart", {
      expect_equal(numOptimizations(map),  3)
      expect_equal(numOptimizations(map2), 1)
    })


    # Using make.map
    test_that("Making a map and optimizing", {
      make.newmap(
        table                   = testtable,
        number_of_dimensions    = 3,
        number_of_optimizations = 2,
        minimum_column_basis    = "none",
        move_trapped_points     = "none"
      )
    })

  }
)


