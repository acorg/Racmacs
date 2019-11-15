
#' Apply transformations to an antigenic map
#'
#' @param map The map object
#' @param value Value to be used (recycled as necessary)
#' @name mapTransformation
#'
#' @return Returns an updated racmap object
#'
NULL


#  Apply a rotation to a map -------

#' @rdname mapTransformation
#' @export
rotateMap <- function(map, degrees, axis = NULL, optimization_number = NULL) {
  if(mapDimensions(map, optimization_number) == 3 && is.null(axis)) stop("Rotation axis must be specified for 3D rotations as either 'x', 'y' or 'z'.")
  UseMethod('rotateMap')
}


#  Reflect a map -------

#' @rdname mapTransformation
#' @export
reflectMap <- function(map, axis = "x", optimization_number = NULL) UseMethod('reflectMap')


# Fix a map transformation
bakeTransformation <- function(map, optimization_number){
  UseMethod('bakeTransformation')
}
