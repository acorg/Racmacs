
library(Racmacs)
library(testthat)
library(parallel)
rm(list = ls())
source('~/Dropbox/labbook/packages/Racmacs/R/map_optimization_by_stress.R')
set.seed(100)



# map <- read.acmap(test_path("../testdata/testmap_h3subset.ace"))
map <- read.acmap("inst/extdata/h3map2004.ace")

# benchmark <- Racmacs:::benchmark_relaxation(
#   tabledist_matrix = tableDistances(map)$distances,
#   titertype_matrix = titerTypesInt(
#     titerTable(map)
#   ),
#   ag_coords = agCoords(map) + rnorm(numAntigens(map)*mapDimensions(map)),
#   sr_coords = srCoords(map) + rnorm(numSera(map)*mapDimensions(map))
# )
# diff(benchmark)
# stop()

# opt <- ac_relaxMap(
#   # tabledist_matrix = tableDists(
#   #   logtiterTable(map),
#   #   ac_getTableColbases(titerTable(map))
#   # ),
#   tabledist_matrix = tableDistances(map)$distances,
#   titertype_matrix = titerTypesInt(
#     titerTable(map)
#   ),
#   ag_coords = agCoords(map) + rnorm(numAntigens(map)*mapDimensions(map)),
#   sr_coords = srCoords(map) + rnorm(numSera(map)*mapDimensions(map)),
#   check_gradient_fn = TRUE
# )
#
#
# agCoords(map) <- opt$ag_coords
# srCoords(map) <- opt$sr_coords
# plot(map)
# print(mapStress(map))
# print(opt$stress)
# map2 <- relaxMap(map)
# print(mapStress(map2))


# Randomise coords
optimizations <- optimizeMapBySumSquaredStressIntern(
  map,
  colbases = colBases(map),
  num_dims = 2,
  num_optimizations = 10000,
  maxit = 5000,
  dim_annealing = FALSE
)

# print(allMapStresses(map))
print(sapply(optimizations, function(x){ x$stress }))
print(min(sapply(optimizations, function(x){ x$stress })))
plot(optimizations[[which.min(sapply(optimizations, function(x){ x$stress }))]]$ag_coords, col = agFill(map))

stop()

map3 <- map
agCoords(map3) <- optimizations[[which.min(sapply(optimizations, function(x){ x$stress }))]]$ag_coords
srCoords(map3) <- optimizations[[which.min(sapply(optimizations, function(x){ x$stress }))]]$sr_coords
print(mapStress(map3))

t1 <- Sys.time()
map2 <- optimizeMap(
  map,
  number_of_dimensions = 2,
  number_of_optimizations = 100,
  fixed_column_bases = colBases(map),
  sort_optimizations = FALSE,
  move_trapped_points = "none",
  minimum_column_basis = "none",
  discard_previous_optimizations = TRUE,
  realign_optimizations = FALSE
)
t2 <- Sys.time()

print(min(allMapStresses(map2)))
print(t2 - t1)
