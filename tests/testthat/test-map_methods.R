
library(Racmacs)
library(testthat)
context("Test reading and editing of chart details")

# Load the map and the chart
map <- read.acmap(filename = test_path("../testdata/testmap.ace"))

test_that("Edit map details", {

  # Initial default checks
  expect_equal(mapName(map), "")
  expect_equal(mapDescription(map), "")

  # Making the edits
  edited_map <- map
  mapName(edited_map) <- "NEW NAME"
  mapDescription(edited_map) <- "A map description"

  # Checking the edits
  expect_equal(mapName(edited_map), "NEW NAME")
  expect_equal(mapDescription(edited_map), "A map description")

  # Saving and loading a map
  tmp <- tempfile(fileext = ".ace")
  save.acmap(edited_map, tmp)
  loaded_map <- read.acmap(tmp)

  # Checking the loaded map
  expect_equal(mapName(loaded_map), "NEW NAME")
  expect_equal(mapDescription(loaded_map), "A map description")

})

test_that("Edit map strain details", {

  # HI table -------
  expect_equal(dim(titerTable(map)), c(10, 5))
  expect_equal(sum(titerTable(map) == "<10"), 3)
  expect_equal(sum(titerTable(map) == "40"), 9)

  new_table <- matrix("40", numAntigens(map), numSera(map))
  titerTable(map) <- new_table
  expect_equal(unname(titerTable(map)), new_table)


})

test_that("Edit map titer table", {

  map_edited <- map
  bad_table  <- matrix("10", 8, 4)
  good_table <- matrix("10", 10, 5)

  expect_error({
    titerTable(map_edited) <- bad_table
  })

  titerTable(map_edited) <- good_table
  expect_equal(
    unname(titerTable(map_edited)),
    good_table
  )

})

test_that("Antigen reactivity adjustments", {

  map_edited <- map
  bad_adjustments <- 1:9
  good_adjustments <- 1:10

  expect_error({
    agReactivityAdjustments(map_edited) <- bad_adjustments
  })

  agReactivityAdjustments(map_edited) <- good_adjustments
  expect_equal(
    agReactivityAdjustments(map_edited),
    good_adjustments
  )

  map_edited <- removeOptimizations(map_edited)
  agReactivityAdjustments(map_edited) <- good_adjustments + 1
  expect_equal(
    agReactivityAdjustments(map_edited),
    good_adjustments + 1
  )

  tmp <- tempfile(fileext = ".ace")
  save.acmap(map_edited, tmp)
  map_loaded <- read.acmap(tmp)
  expect_equal(
    agReactivityAdjustments(map_loaded),
    good_adjustments + 1
  )

})

