
#' @export
relaxMap.racmap <- function(map,
                            optimization_number = NULL){

  if(is.null(optimization_number)) optimization_number <- selectedOptimization(map)

  # Create a new dummy chart
  acchart <- acmap.cpp(
    table                = titerTable(map),
    ag_coords            = agBaseCoords(map, optimization_number, .name = FALSE),
    sr_coords            = srBaseCoords(map, optimization_number, .name = FALSE),
    minimum_column_basis = minColBasis(map, optimization_number),
    column_bases         = colBases(map, optimization_number, .name = FALSE)
  )

  # Relax the optimization
  acchart <- relaxMap(acchart)

  # Update the coordinates
  agBaseCoords(map, optimization_number) <- agBaseCoords(acchart, .name = FALSE)
  srBaseCoords(map, optimization_number) <- srBaseCoords(acchart, .name = FALSE)

  # Return the new chart
  map

}


#' @export
relaxMapOneStep.racmap <- function(map,
                                   optimization_number = NULL){

  if(is.null(optimization_number)) optimization_number <- selectedOptimization(map)

  # Create a new dummy chart
  acchart <- acmap.cpp(
    table                = titerTable(map),
    ag_coords            = agBaseCoords(map, optimization_number, .name = FALSE),
    sr_coords            = srBaseCoords(map, optimization_number, .name = FALSE),
    minimum_column_basis = minColBasis(map, optimization_number),
    column_bases         = colBases(map, optimization_number, .name = FALSE)
  )

  # Relax the optimization
  acchart <- relaxMapOneStep(acchart)

  # Update the coordinates
  agBaseCoords(map, optimization_number) <- agBaseCoords(acchart, .name = FALSE)
  srBaseCoords(map, optimization_number) <- srBaseCoords(acchart, .name = FALSE)

  # Return the new chart
  map

}



#' @export
checkHemisphering.racmap <- function(map, stepsize = 0.1, optimization_number = NULL){
  checkHemisphering(
    map                 = as.cpp(map),
    stepsize            = stepsize,
    optimization_number = optimization_number
  )
}


#' @export
moveTrappedPoints.racmap <- function(map, stepsize = 0.1, optimization_number = NULL, vverbose = FALSE){

  vmessage(vverbose, "Converting to cpp...", appendLF = F)
  mapclone <- keepSingleOptimization(map, optimization_number)
  chart <- as.cpp(mapclone)
  vmessage(vverbose, "done.")

  vmessage(vverbose, "Moving trapped points...", appendLF = F)
  chart <- moveTrappedPoints(chart, stepsize = stepsize)
  vmessage(vverbose, "done.")

  vmessage(vverbose, "Setting coordinates...", appendLF = F)
  agBaseCoords(map, optimization_number) <- agBaseCoords(chart)
  srBaseCoords(map, optimization_number) <- srBaseCoords(chart)
  vmessage(vverbose, "done.")

  vmessage(vverbose, "Relaxing map...", appendLF = F)
  map <- relaxMap(map, optimization_number)
  vmessage(vverbose, "done.")

  map

}


