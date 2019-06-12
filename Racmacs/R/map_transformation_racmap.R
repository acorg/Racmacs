
#  Apply a rotation to a map -------

#' @export
rotateMap.racmap <- function(map, degrees, axis = NULL, optimization_number = NULL){
  if(is.null(optimization_number)) optimization_number <- selectedOptimization(map)
  agCoords(map, optimization_number) <- rotate_coords_by_degrees(agCoords(map, optimization_number), degrees, axis)
  srCoords(map, optimization_number) <- rotate_coords_by_degrees(srCoords(map, optimization_number), degrees, axis)
  map
}

#' @export
reflectMap.racmap <- function(map, axis = "x", optimization_number = NULL){
  if(is.null(optimization_number)) optimization_number <- selectedOptimization(map)
  agCoords(map, optimization_number) <- reflect_coords_in_axis(agCoords(map, optimization_number), axis)
  srCoords(map, optimization_number) <- reflect_coords_in_axis(srCoords(map, optimization_number), axis)
  map
}
