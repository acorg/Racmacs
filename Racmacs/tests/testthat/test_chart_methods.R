
library(Racmacs)

# Load the map and the chart
racchart <- read.acmap.cpp(filename = testthat::test_path("../testdata/testmap.ace"))
racmap   <- read.acmap(filename = testthat::test_path("../testdata/testmap.ace"))

testthat::context("Test reading and editing of chart details")
testthat::test_that("Edit map strain details", {


  # Chart name -------
  testthat::expect_equal(
    name(racmap),
    name(racchart)
  )

  name(racmap)   <- "new name"
  name(racchart) <- "new name"
  testthat::expect_equal(name(racmap),   "new name")
  # testthat::expect_equal(name(racchart), "new name")


  # HI table -------
  testthat::expect_equal(
    titerTable(racmap),
    titerTable(racchart)
  )

  new_table <- matrix(40, numAntigens(racmap), numSera(racmap))
  titerTable(racmap)   <- new_table
  titerTable(racchart) <- new_table
  testthat::expect_equal(
    titerTable(racmap),
    titerTable(racchart)
  )


})




