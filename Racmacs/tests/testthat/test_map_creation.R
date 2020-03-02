
library(Racmacs)
library(testthat)
context("Test local map creation")
# setwd("~/Dropbox/labbook/packages/Racmacs/Racmacs/")
# invisible(lapply(rev(list.files("R", full.names = T)), function(x){ print(x); source(x) }))

# Bare bones creation
test_that("Bare bones creation", {

  # Making a map from a table
  testtable <- matrix(2^(1:6)*10, 3, 2)
  actablechart <- acmap.cpp(
    table = testtable
  )
  actableracmap <- acmap(
    table = testtable
  )
  mode(testtable) <- "character"

  expect_equal(
    unname(titerTable(actablechart)),
    testtable
  )

  expect_equal(
    unname(titerTable(actableracmap)),
    testtable
  )


  ag_names <- paste("Antigen", 1:5)
  sr_names <- paste("Serum", 1:5)

  ag_coords <- matrix(1:10,5,2)
  sr_coords <- matrix(11:20,5,2)

  ag_coords3d <- cbind(ag_coords, 2)
  sr_coords3d <- cbind(sr_coords, 2)

  expect_warning({
    chart <- acmap.cpp(ag_coords = ag_coords,
                       sr_coords = sr_coords)
  })

  expect_warning({
    acmap <- acmap(ag_coords = ag_coords,
                   sr_coords = sr_coords)
  })

  expect_warning({
    chart3d <- acmap.cpp(ag_coords = ag_coords3d,
                         sr_coords = sr_coords3d)
  })

  expect_warning({
    acmap3d <- acmap(ag_coords = ag_coords3d,
                     sr_coords = sr_coords3d)
  })

  expect_equal(unname(agCoords(chart)), ag_coords)
  expect_equal(unname(srCoords(chart)), sr_coords)
  expect_equal(unname(agCoords(chart3d)), ag_coords3d)
  expect_equal(unname(srCoords(chart3d)), sr_coords3d)
  expect_equal(numOptimizations(chart), 1)
  expect_equal(unname(agCoords(acmap)), ag_coords)
  expect_equal(unname(srCoords(acmap)), sr_coords)
  expect_equal(unname(agCoords(acmap3d)), ag_coords3d)
  expect_equal(unname(srCoords(acmap3d)), sr_coords3d)
  expect_equal(numOptimizations(acmap), 1)

})

# Incorrect arguments
test_that("Disallowed arguments", {

  expect_error(make.acmap.cpp(ag_coords = matrix(1:10)))
  expect_error(make.acmap.cpp(foo = "bar", bar = "foo"))
  expect_error(make.acmap(ag_coords = matrix(1:10)))
  expect_error(make.acmap(foo = "bar", bar = "foo"))

})


# Checking input types
test_that("Argument format conversion", {

  # Matrices should be allowed and converted to data frames
  expect_warning({
    chart <- acmap.cpp(ag_coords = expand.grid(1:10, 1:10),
                       sr_coords = expand.grid(1:10, 1:10))
  })

})

# Multioptimization creation
test_that("Multioptimization creation", {

  expect_warning({
    acmap <- acmap(optimizations = list(
      list(ag_coords = matrix(1:10,5,2),
           sr_coords = matrix(11:20,5,2)),
      list(ag_coords = matrix(10:1,5,2),
           sr_coords = matrix(20:11,5,2))
    ))
  })

  expect_warning({
    chart <- acmap.cpp(optimizations = list(
      list(ag_coords = matrix(1:10,5,2),
           sr_coords = matrix(11:20,5,2)),
      list(ag_coords = matrix(10:1,5,2),
           sr_coords = matrix(20:11,5,2))
    ))
  })

})

# Cloning
chart  <- read.acmap.cpp(filename = test_path("../testdata/testmap.ace"))
chart2 <- cloneMap(chart)
chart2 <- keepSingleOptimization(chart2, 2)

test_that("Cloning racchart", {
  expect_equal(numOptimizations(chart),  3)
  expect_equal(numOptimizations(chart2), 1)
})
