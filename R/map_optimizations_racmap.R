
optimization.add.racmap <- function(
  map,
  number_of_dimensions,
  minimum_column_basis
){

  map$optimizations <- c(
    map$optimizations,
    list(list())
  )

  optimization_num <- numOptimizations(map)
  agBaseCoords(map, optimization_num, .check = FALSE) <- matrix(NA, numAntigens(map), number_of_dimensions)
  srBaseCoords(map, optimization_num, .check = FALSE) <- matrix(NA, numSera(map), number_of_dimensions)
  minColBasis(map, optimization_num, .check = FALSE) <- minimum_column_basis
  map

}

