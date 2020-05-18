
library(Racmacs)
library(testthat)
context("Test reading and editing of chart details")

run.maptests(
  loadlocally = FALSE,
  {

    # Load the map and the chart
    racchart <- read.acmap.cpp(filename = test_path("../testdata/testmap.ace"))
    racmap   <- read.acmap(filename = test_path("../testdata/testmap.ace"))

    test_that("Edit map strain details", {


      # Chart name -------
      expect_equal(
        name(racmap),
        name(racchart)
      )

      name(racmap)   <- "NEW NAME"
      name(racchart) <- "NEW NAME"
      expect_equal(name(racmap),   "NEW NAME")
      expect_equal(name(racchart), "NEW NAME")


      # HI table -------
      expect_equal(
        titerTable(racmap),
        titerTable(racchart)
      )

      new_table <- matrix(40, numAntigens(racmap), numSera(racmap))
      titerTable(racmap)   <- new_table
      titerTable(racchart) <- new_table
      expect_equal(
        unname(titerTable(racmap)),
        unname(titerTable(racchart))
      )


    })

  }
)





