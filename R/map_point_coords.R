
#' Getting and setting point coordinates
#'
#' Getting and setting of antigen and serum coordinates in a map optimization
#' run (by default the currently selected one).
#'
#' @param map The acmap object
#' @param optimization_number The optimization number from which to get / set
#'   the coordinates
#' @param value A matrix of new coordinates to set
#'
#' @details These functions get and set point coordinates in a map. By default
#'   these coordinates refer to the currently selected optimization run, unless
#'   otherwise specified through the `optimization_number` argument.
#'
#'   99\% of the time `agCoords()` and `srCoords()` are the functions you'll
#'   want to use but you should note that the outputs are actually the map base
#'   coordinates after the transformation and translation associated with the
#'   optimization run has been applied (see `mapTransformation()` and
#'   `mapTranslation()` for more details). When you set the antigen or serum
#'   coordinates through these functions, the transformed coordinates are
#'   "baked" in and the map transformation and translation are reset.
#'   Consequently if you want to apply a transformation to all coordinates
#'   generally, you are better off modifying the map translation and
#'   transformation directly, as is done by functions like `rotateMap()` and
#'   `translateMap()`.
#'
#' @returns Returns a matrix of point coordinates.
#'
#' @seealso
#' `agBaseCoords()`
#' `srBaseCoords()`
#' `mapTransformation()`
#' `mapTranslation()`
#'
#' @family map optimization attribute functions
#' @name ptCoords

# Get the antigen coordinates
#' @rdname ptCoords
#' @export
agCoords <- function(map, optimization_number = 1) {
  check.acmap(map)
  optimization <- map$optimizations[[optimization_number]]
  if (is.null(optimization)) stop("optimization run not found")
  coords <- ac_get_ag_coords(optimization)
  rownames(coords) <- agNames(map)
  coords
}

# Get the serum coordinates
#' @rdname ptCoords
#' @export
srCoords <- function(map, optimization_number = 1) {
  check.acmap(map)
  optimization <- map$optimizations[[optimization_number]]
  if (is.null(optimization)) stop("optimization run not found")
  coords <- ac_get_sr_coords(optimization)
  rownames(coords) <- srNames(map)
  coords
}

# Get the antigen and serum coordinates
#' @rdname ptCoords
#' @export
ptCoords <- function(map, optimization_number = 1) {
  rbind(
    agCoords(map, optimization_number),
    srCoords(map, optimization_number)
  )
}

# Set the antigen and serum coordinates
#' @rdname ptCoords
#' @export
`ptCoords<-` <- function(map, optimization_number = 1, value) {
  check.numericmatrix(value)
  if (nrow(value) != numPoints(map)) stop("Replacement coordinates do not match the number of points in the map", call. = FALSE)
  agCoords(map, optimization_number) <- value[seq_len(numAntigens(map)), , drop = FALSE]
  srCoords(map, optimization_number) <- value[-seq_len(numAntigens(map)), , drop = FALSE]
  map
}

# Set the antigen coordinates
#' @rdname ptCoords
#' @export
`agCoords<-` <- function(map, optimization_number = 1, value) {
  check.acmap(map)
  check.numericmatrix(value)
  optimization <- map$optimizations[[optimization_number]]
  if (is.null(optimization)) stop("optimization run not found")
  map$optimizations[[optimization_number]] <- ac_set_ag_coords(
    optimization,
    value
  )
  optStress(map, optimization_number) <- mapStress(map, optimization_number)
  map
}


# Set the sera coordinates
#' @rdname ptCoords
#' @export
`srCoords<-` <- function(map, optimization_number = 1, value) {
  check.acmap(map)
  check.numericmatrix(value)
  optimization <- map$optimizations[[optimization_number]]
  if (is.null(optimization)) stop("optimization run not found")
  map$optimizations[[optimization_number]] <- ac_set_sr_coords(
    optimization,
    value
  )
  optStress(map, optimization_number) <- mapStress(map, optimization_number)
  map
}
