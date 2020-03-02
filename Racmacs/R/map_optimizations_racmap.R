
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
  mapDimensions(map, optimization_num, .check = FALSE) <- number_of_dimensions
  minColBasis(map, optimization_num) <- minimum_column_basis
  map

}

