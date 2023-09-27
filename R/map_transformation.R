
#' Apply the current map transformation
#'
#' Applies the map transformation associated with a selected optimization run to
#' a set of coordinates.
#'
#' @param coords Coordinates to transform
#' @param map The acmap object
#' @param optimization_number The optimization number
#'
#' @returns An acmap object with transformation applied
#'
#' @family functions relating to map transformation
#' @export
#'
applyMapTransform <- function(
  coords,
  map,
  optimization_number = 1
) {

  # Check input
  check.numericmatrix(coords)
  check.acmap(map)
  check.optnum(map, optimization_number)

  # Transform the coordinates
  ac_apply_optimization_transform(
    map$optimizations[[optimization_number]],
    coords
  )

}


#' Translate a map
#'
#' Translates map coordinates
#'
#' @param map The acmap object
#' @param translation Translation to apply (as vector or n x 1 matrix)
#' @param optimization_number The optimization number (or NULL to apply to all
#'   optimizations)
#'
#' @returns An acmap object with transformation applied
#'
#' @family functions relating to map transformation
#' @export
#'
translateMap <- function(
  map,
  translation,
  optimization_number = NULL
  ) {

  # Check input
  if (is.vector(translation)) translation <- matrix(translation, ncol = 1)

  # Determine which optimizations to rotate
  if (is.null(optimization_number)) {
    optimization_number <- seq_len(numOptimizations(map))
  }

  # Rotate the optimizations
  map$optimizations[optimization_number] <- lapply(
    map$optimizations[optimization_number],
    ac_translate_optimization,
    translation = translation
  )

  map

}


#' Reflect a map
#'
#' Reflects map coordinates
#'
#' @param map The acmap object
#' @param axis Axis of reflection
#' @param optimization_number The optimization number (or NULL to apply to all
#'   optimizations)
#'
#' @returns An acmap object with reflection applied
#'
#' @family functions relating to map transformation
#' @export
#'
reflectMap <- function(
  map,
  axis = "x",
  optimization_number = NULL
  ) {

  # Set the axis num
  if (is.null(axis)) {
    axis_num <- 3
  } else if (axis %in% c("x", "y", "z")) {
    axis_num <- match(axis, c("x", "y", "z"))
  } else {
    stop("Reflection is only supported in x, y or z dimensions")
  }

  # Determine which optimizations to rotate
  if (is.null(optimization_number)) {
    optimization_number <- seq_len(numOptimizations(map))
  }

  # Rotate the optimizations
  map$optimizations[optimization_number] <- lapply(
    map$optimizations[optimization_number],
    ac_reflect_optimization,
    axis_num = axis_num - 1
  )

  map

}


#' Rotate a map
#'
#' Apply a rotation to an antigenic map
#'
#' @param map The acmap object
#' @param degrees Degrees of rotation
#' @param axis Axis of rotation (if 3D), specified as "x", "y", or "z"
#' @param optimization_number The optimization number (or NULL to apply to all
#'   optimizations)
#'
#' @returns An acmap object with rotation applied
#'
#' @family functions relating to map transformation
#' @export
#'
rotateMap <- function(
  map,
  degrees,
  axis = NULL,
  optimization_number = NULL
  ) {

  # Set the axis num
  if (is.null(axis)) {
    axis_num <- 3
  } else if (axis %in% c("x", "y", "z")) {
    axis_num <- match(axis, c("x", "y", "z"))
  } else {
    stop("Rotation is only supported in x, y or z dimensions")
  }

  # Determine which optimizations to rotate
  if (is.null(optimization_number)) {
    optimization_number <- seq_len(numOptimizations(map))
  }

  # Rotate the optimizations
  map$optimizations[optimization_number] <- lapply(
    map$optimizations[optimization_number],
    ac_rotate_optimization,
    degrees = degrees,
    axis_num = axis_num - 1
  )

  map

}
