
library(Racmacs)

run.maptests(
  loadlocally = FALSE,
  {

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

      name(racmap)   <- "NEW NAME"
      name(racchart) <- "NEW NAME"
      testthat::expect_equal(name(racmap),   "NEW NAME")
      testthat::expect_equal(name(racchart), "NEW NAME")


      # HI table -------
      testthat::expect_equal(
        titerTable(racmap),
        titerTable(racchart)
      )

      new_table <- matrix(40, numAntigens(racmap), numSera(racmap))
      titerTable(racmap)   <- new_table
      titerTable(racchart) <- new_table
      testthat::expect_equal(
        unname(titerTable(racmap)),
        unname(titerTable(racchart))
      )


    })

  }
)





