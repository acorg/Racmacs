## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ---- out.height=500, out.width=500-------------------------------------------
library(Racmacs)

# Read in the map from the test data files
map <- read.acmap("../tests/testdata/testmap_h3subset.ace")

# Scale down the point size a little
agSize(map) <- 2
srSize(map) <- 2

# View the map
view(map)

## ---- fig.height=5, fig.width=6-----------------------------------------------
# Simply call the function plot_map_table_distance()
plotly_map_table_distance(map)

## ---- out.height=500, out.width=500, message=FALSE----------------------------
# First of all run a series of bootstrap repeats on the map
map <- bootstrapMap(
  map                      = map,
  bootstrap_repeats        = 100,
  optimizations_per_repeat = 10,
  ag_noise_sd              = 0.7,
  titer_noise_sd           = 0.7
)

# Data on these bootstrap repeats is accessible with additional functions once it has been run on the map
boostrap_ag_coords_list <- mapBootstrap_agCoords(map)
boostrap_sr_coords_list <- mapBootstrap_srCoords(map)

## ---- out.height=500, out.width=500-------------------------------------------
view(map, selected_ags = 4)

