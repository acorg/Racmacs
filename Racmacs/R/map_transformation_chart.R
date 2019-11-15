
#  Apply a rotation to a map -------

#' @export
rotateMap.racchart <- function(map, degrees, axis = NULL, optimization_number = NULL){
  if(is.null(optimization_number)) optimization_number <- selectedOptimization(map)
  if(is.null(axis)){
    map$chart$projections[[optimization_number]]$rotate_degrees(degrees)
  } else {
    agCoords(map, optimization_number) <- rotate_coords_by_degrees(agCoords(map, optimization_number), degrees, axis)
    srCoords(map, optimization_number) <- rotate_coords_by_degrees(srCoords(map, optimization_number), degrees, axis)
  }
  map
}

#' @export
reflectMap.racchart <- function(map, axis = "x", optimization_number = NULL){
  if(is.null(optimization_number)) optimization_number <- selectedOptimization(map)
  if(mapDimensions(map, optimization_number) == 2){
    if(axis == "x")      map$chart$projections[[optimization_number]]$flip_north_south()
    else if(axis == "y") map$chart$projections[[optimization_number]]$flip_east_west()
    else if(axis == "z") stop("Reflection axis must be one of 'x' or 'y'.")
  } else {
    agCoords(map, optimization_number) <- reflect_coords_in_axis(agCoords(map, optimization_number), axis)
    srCoords(map, optimization_number) <- reflect_coords_in_axis(srCoords(map, optimization_number), axis)
  }
  map
}

#' @export
bakeTransformation.racchart <- function(map, optimization_number){

  optimization_number <- convertOptimizationNum(optimization_number, map)

  layout <- rbind(
    agCoords(map, optimization_number),
    srCoords(map, optimization_number)
  )

  mapTransformation(map, optimization_number) <- NULL
  mapTranslation(map, optimization_number)    <- NULL

  map$chart$projections[[optimization_number]]$set_layout(layout)
  map

}

