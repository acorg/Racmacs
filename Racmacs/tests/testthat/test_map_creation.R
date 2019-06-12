
library(Racmacs)
testthat::context("Test local map creation")

# Bare bones creation
testthat::test_that("Bare bones creation", {

  ag_names <- paste("Antigen", 1:5)
  sr_names <- paste("Serum", 1:5)

  ag_coords <- matrix(1:10,5,2)
  sr_coords <- matrix(11:20,5,2)

  testthat::expect_warning({
    chart <- acmap.cpp(ag_coords = ag_coords,
                       sr_coords = sr_coords)
  })

  acmap <- acmap(ag_coords = ag_coords,
                 sr_coords = sr_coords)

  rownames(ag_coords) <- ag_names
  rownames(sr_coords) <- sr_names

  testthat::expect_equal(chart$ag_coords, ag_coords)
  testthat::expect_equal(chart$sr_coords, sr_coords)
  testthat::expect_equal(acmap$ag_coords, ag_coords)
  testthat::expect_equal(acmap$sr_coords, sr_coords)

})

# Incorrect arguments
testthat::test_that("Disallowed arguments", {

  testthat::expect_error(make.acmap.cpp(ag_coords = matrix(1:10)))
  testthat::expect_error(make.acmap.cpp(foo = "bar", bar = "foo"))
  testthat::expect_error(make.acmap(ag_coords = matrix(1:10)))
  testthat::expect_error(make.acmap(foo = "bar", bar = "foo"))

})

# Checking input types
testthat::test_that("Argument format conversion", {

  # Matrices should be allowed and converted to data frames
  testthat::expect_warning({
    chart <- acmap.cpp(ag_coords = expand.grid(1:10, 1:10),
                       sr_coords = expand.grid(1:10, 1:10))
  })

})

# Multioptimization creation
testthat::test_that("Multioptimization creation", {

  acmap <- acmap(optimizations = list(
    list(ag_coords = matrix(1:10,5,2),
         sr_coords = matrix(11:20,5,2)),
    list(ag_coords = matrix(10:1,5,2),
         sr_coords = matrix(20:11,5,2))
  ))

  testthat::expect_warning({
    chart <- acmap.cpp(optimizations = list(
      list(ag_coords = matrix(1:10,5,2),
           sr_coords = matrix(11:20,5,2)),
      list(ag_coords = matrix(10:1,5,2),
           sr_coords = matrix(20:11,5,2))
    ))
  })

})

# Cloning
chart  <- read.acmap.cpp(filename = testthat::test_path("../testdata/testmap.ace"))
chart2 <- cloneMap(chart)
chart2 <- keepSingleOptimization(chart2, 2)

testthat::test_that("Cloning racchart", {
  testthat::expect_equal(numOptimizations(chart),  3)
  testthat::expect_equal(numOptimizations(chart2), 1)
})
