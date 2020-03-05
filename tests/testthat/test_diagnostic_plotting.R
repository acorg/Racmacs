
library(testthat)
library(Racmacs)
context("Diagnostic plotting")

run.maptests(
  bothclasses = TRUE,
  loadlocally = TRUE,
  {

    map <- read.map(system.file("extdata/h3map2004.ace", package = "Racmacs"))
    plot_map_table_distance(map)
    plotly_map_table_distance(map)

    plot_sr_titers(
      map   = map,
      serum = "BE/32V/92"
    )

    plotly_sr_titers(
      map   = map,
      serum = "BE/32V/92"
    )

    plot_srStressPerTiter(map)
    plotly_srStressPerTiter(map)

  }
)

