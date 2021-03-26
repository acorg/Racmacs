
library(Racmacs)
library(testthat)
context("Test map methods")

# Load the map and the chart
map <- read.acmap(filename = test_path("../testdata/testmap.ace"))

# Test the print method
expect_output(print(map))
