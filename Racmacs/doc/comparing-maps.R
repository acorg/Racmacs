## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(Racmacs)

## ----out.height=600, out.width=600--------------------------------------------
map <- read.acmap(system.file("extdata/h3map2004.ace", package = "Racmacs"))
view(map)

## ----out.height=600, out.width=600--------------------------------------------
pc_run12 <- procrustesMap(
  map                            = map,
  comparison_map                 = map,
  optimization_number            = 1,
  comparison_optimization_number = 2
)

view(pc_run12)

## ----out.height=600, out.width=600--------------------------------------------
pc_run13 <- procrustesMap(
  map                            = map,
  comparison_map                 = map,
  optimization_number            = 1,
  comparison_optimization_number = 3
)

view(pc_run13)

