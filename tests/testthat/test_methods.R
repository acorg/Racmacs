
library(Racmacs)
library(testthat)
context("Test map methods")

run.maptests(
  loadlocally = FALSE,
  bothclasses = TRUE,
  {

    # Load the map and the chart
    map <- read.map(filename = test_path("../testdata/testmap.ace"))

    # Test the print method
    expect_output(print(map))

  }
)





