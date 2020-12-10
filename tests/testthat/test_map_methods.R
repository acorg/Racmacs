
library(Racmacs)
library(testthat)
context("Test reading and editing of chart details")

# Load the map and the chart
map <- read.acmap(filename = test_path("../testdata/testmap.ace"))

test_that("Edit map strain details", {

  # Chart name -------
  expect_equal(
    mapName(map),
    NULL
  )

  mapName(map) <- "NEW NAME"
  expect_equal(mapName(map), "NEW NAME")


  # HI table -------
  expect_equal(dim(titerTable(map)), c(10, 5))
  expect_equal(sum(titerTable(map) == "<10"), 3)
  expect_equal(sum(titerTable(map) == "40"), 9)

  new_table <- matrix("40", numAntigens(map), numSera(map))
  titerTable(map) <- new_table
  expect_equal(unname(titerTable(map)), new_table)


})





