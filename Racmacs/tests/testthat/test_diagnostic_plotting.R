
library(testthat)
context("Diagnostic plotting")

run.maptests(
  bothclasses = TRUE,
  loadlocally = FALSE,
  {

    map <- read.map(system.file("extdata/h3map2004.ace", package = "Racmacs"))
    plot_map_table_distance(map)

    plotly_map_table_distance(map)

  }
)

