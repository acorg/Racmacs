## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, include = FALSE---------------------------------------------------
library(Racmacs)

## ---- eval=FALSE--------------------------------------------------------------
#  merged_map <- mergeMaps(
#    map1,
#    map2,
#    map3,
#    method                  = "incremental-merge",
#    minimum_column_basis    = "none",
#    number_of_optimizations = 500,
#    number_of_dimensions    = 2
#  )

