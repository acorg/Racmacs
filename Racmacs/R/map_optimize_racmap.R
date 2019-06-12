

#' @export
runOptimization.racmap <- function(map,
                                   number_of_dimensions,
                                   number_of_optimizations,
                                   minimum_column_basis){

  # Get the HI table
  titer_table = titerTable(map)

  # Create a new dummy chart
  racchart <- acmap.cpp(table = titer_table)

  # Optimise the chart
  racchart <- runOptimization(map                     = racchart,
                              number_of_dimensions    = number_of_dimensions,
                              number_of_optimizations = number_of_optimizations,
                              minimum_column_basis    = minimum_column_basis)

  # Add optimizations to the racmap
  map$optimizations <- c(map$optimizations, as.list(racchart)$optimizations)

  # Return the new chart
  map

}


#' @export
relaxMap.racmap <- function(map,
                            optimization_number = NULL){

  if(is.null(optimization_number)) optimization_number <- selectedOptimization(map)

  # Create a new dummy chart
  acchart <- acmap.cpp(table = titerTable(map),
                       ag_coords = agCoords(map, optimization_number),
                       sr_coords = srCoords(map, optimization_number),
                       minimum_column_basis = minColBasis(map, optimization_number),
                       colbases = colBases(map, optimization_number))

  # Relax the optimization
  acchart <- relaxMap(acchart)

  # Update the coordinates
  agCoords(map, optimization_number) <- agCoords(acchart)
  srCoords(map, optimization_number) <- srCoords(acchart)

  # Return the new chart
  map

}


#' @export
checkHemisphering.racmap <- function(map, optimization_number = NULL){

  chart <- as.cpp(map, warnings = FALSE)
  checkHemisphering(chart, optimization_number)

}


#' @export
moveTrappedPoints.racmap <- function(map, optimization_number = NULL){

  chart <- as.cpp(map, warnings = FALSE)
  chart <- moveTrappedPoints(chart, optimization_number)
  agCoords(map, optimization_number) <- agCoords(chart, optimization_number)
  map <- relaxMap(map, optimization_number)
  map

}


