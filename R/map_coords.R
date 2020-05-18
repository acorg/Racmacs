
#' Getting and setting point coordinates
#'
#' Getting and setting of antigen and serum coordinates in a map optimization run (by default
#' the currently selected one).
#'
#' @param map The acmap object
#' @param optimization_number The optimization number from which to get / set the coordinates
#' @param .name Should the row names of the coordinates be named according to the antigen / serum names
#'
#' @details These functions get and set point coordinates in a map. By default these coordinates
#' refer to the currently selected optimization run, unless otherwise specified through the
#' `optimization_number` argument.
#'
#' 99\% of the time `agCoords()` and `serumCoords()` are the functions you'll want to use but
#' you should note that the outputs are actually the map base coordinates after the transformation and
#' translation associated with the optimization run has been applied (see `mapTransformation()` and
#' `mapTranslation()` for more details). When you set the antigen or serum coordinates through these
#' functions, the transformed coordinates are "baked" in and the map transformation and translation
#' are reset. Consequently if you want to apply a transformation to all coordinates generally, you are
#' better off modifying the map translation and transformation directly, as is done by functions like
#' `rotateMap()` and `translateMap()`.
#'
#' @seealso
#' \code{\link{agBaseCoords}}
#' \code{\link{srBaseCoords}}
#' \code{\link{mapTransformation}}
#' \code{\link{mapTranslation}}
#'
#' @family {map optimization attribute functions}
#' @name ptCoords

# Get the antigen coordinates
#' @rdname ptCoords
#' @export
agCoords <- function(map, optimization_number = NULL, .name = TRUE){

  applyMapTransform(
    coords              = agBaseCoords(map, optimization_number, .name = .name),
    map                 = map,
    optimization_number = optimization_number
  )

}

# Get the serum coordinates
#' @rdname ptCoords
#' @export
srCoords <- function(map, optimization_number = NULL, .name = TRUE){

  applyMapTransform(
    coords              = srBaseCoords(map, optimization_number, .name = .name),
    map                 = map,
    optimization_number = optimization_number
  )

}

# Set the antigen coordinates
#' @rdname ptCoords
#' @export
`agCoords<-` <- function(map, optimization_number = NULL, value){

  agBaseCoords(map, optimization_number) <- value
  srBaseCoords(map, optimization_number) <- srCoords(map, optimization_number)
  clearTransformation(map, optimization_number)

}


# Set the sera coordinates
#' @rdname ptCoords
#' @export
`srCoords<-` <- function(map, optimization_number = NULL, value){

  agBaseCoords(map, optimization_number) <- agCoords(map, optimization_number)
  srBaseCoords(map, optimization_number) <- value
  clearTransformation(map, optimization_number)

}


# Clear a map transformation
clearTransformation <- function(map, optimization_number = NULL){

  mapTransformation(map, optimization_number) <- diag(nrow = mapDimensions(map, optimization_number))
  mapTranslation(map, optimization_number)    <- rep(0, mapDimensions(map, optimization_number))
  map

}

