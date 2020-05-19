
library(testthat)
library(Racmacs)
context("Diagnostic plotting")

run.maptests(
  bothclasses = TRUE,
  loadlocally = FALSE,
  {

    map <- read.map(system.file("extdata/h3map2004.ace", package = "Racmacs"))
    # plot_map_table_distance(map)
    # plotly_map_table_distance(map)

    # plot_ag_titers(
    #   map     = map,
    #   antigen = "HK/434/96"
    # )
    #
    # plotly_ag_titers(
    #   map     = map,
    #   antigen = "HK/434/96"
    # )

    # plot_sr_titers(
    #   map   = map,
    #   serum = "BE/32V/92"
    # )
    #
    # plotly_sr_titers(
    #   map   = map,
    #   serum = "BE/32V/92"
    # )
    #
    # plot_agStressPerTiter(map)
    # plotly_agStressPerTiter(map)
    #
    # plot_srStressPerTiter(map)
    # plotly_srStressPerTiter(map)

  }
)

