
library(testthat)
library(ggplot2)
source("R/map_plot_gg.R")
context("Plotting a map")

run.maptests(
  bothclasses = FALSE,
  loadlocally = FALSE,
  {

    read.map <- read.acmap

  # test_that("Plotting a bare bones", {
  #
  #   map <- make.map(
  #     ag_coords = matrix(1:10, 5),
  #     sr_coords = matrix(1:8,  4),
  #     minimum_column_basis = "none"
  #   )
  #
  #   x <- plot(map)
  #   testthat::expect_null(x)
  #
  # })

  # test_that("ggplotting a map", {
  #
  #   map <- read.map(test_path("../testdata/testmap.ace"))
  #   map <- setLegend(
  #     map,
  #     legend = c("group 1", "group 2"),
  #     fill   = c("red", "blue")
  #   )
  #   plot(ggplot(map))
  #
  # })

})



