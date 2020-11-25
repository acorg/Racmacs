
library(Racmacs)
library(testthat)
library(parallel)
rm(list = ls())
set.seed(100)



# map <- read.acmap(test_path("../testdata/testmap_h3subset.ace"))
map <- read.acmap("inst/extdata/h3map2004.ace")
map2 <- optimizeMap(
  map = map,
  number_of_dimensions = 2,
  number_of_optimizations = 100,
  minimum_column_basis = "none",
  dimensional_annealing = FALSE
)

map2$optimizations[[1]]
plot(map2, 1)

