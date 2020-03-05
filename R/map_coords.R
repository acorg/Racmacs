
# Get the antigen coordinates
#' @export
agCoords <- function(map, optimization_number = NULL, .name = TRUE){

  applyMapTransform(
    coords              = agBaseCoords(map, optimization_number, .name = .name),
    map                 = map,
    optimization_number = optimization_number
  )

}

# Get the sera coordinates
#' @export
srCoords <- function(map, optimization_number = NULL, .name = TRUE){

  applyMapTransform(
    coords              = srBaseCoords(map, optimization_number, .name = .name),
    map                 = map,
    optimization_number = optimization_number
  )

}


clearTransformation <- function(map, optimization_number = NULL){

  mapTransformation(map, optimization_number) <- diag(nrow = mapDimensions(map, optimization_number))
  mapTranslation(map, optimization_number)    <- rep(0, mapDimensions(map, optimization_number))
  map

}


# Set the antigen coordinates
#' @export
`agCoords<-` <- function(map, optimization_number = NULL, value){

  agBaseCoords(map, optimization_number) <- value
  srBaseCoords(map, optimization_number) <- srCoords(map, optimization_number)
  clearTransformation(map, optimization_number)

}


# Set the sera coordinates
#' @export
`srCoords<-` <- function(map, optimization_number = NULL, value){

  agBaseCoords(map, optimization_number) <- agCoords(map, optimization_number)
  srBaseCoords(map, optimization_number) <- value
  clearTransformation(map, optimization_number)

}

