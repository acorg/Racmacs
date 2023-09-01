
#' Add a new optimization to an acmap object
#'
#' Function to add a new optimization to an acmap object, with specified values.
#'
#' @param map The acmap data object
#' @param ag_coords Antigen coordinates for the new optimization (0 if not
#'   specified)
#' @param sr_coords Sera coordinates for the new optimization (0 if not
#'   specified)
#' @param number_of_dimensions The number of dimensions of the new optimization
#' @param minimum_column_basis The minimum column basis to use for the new
#'   optimization
#' @param fixed_column_bases A vector of fixed column bases with NA for sera
#'   where the minimum column basis should be applied
#' @param ag_reactivity_adjustments A vector of antigen reactivity adjustments to
#'   apply to each antigen. Corresponding antigen titers will be adjusted by these
#'   amounts when calculating column bases and table distances.
#'
#' @family functions for working with map data
#'
#' @returns Returns the acmap data object with new optimization added (but not
#'   selected).
#'
#' @export
#'
addOptimization <- function(
  map,
  ag_coords = NULL,
  sr_coords = NULL,
  number_of_dimensions = NULL,
  minimum_column_basis = "none",
  fixed_column_bases = NULL,
  ag_reactivity_adjustments = NULL
) {

  # Check input
  check.string(minimum_column_basis)
  if (is.null(number_of_dimensions)
      && (is.null(ag_coords) || is.null(sr_coords))) {
    stop(strwrap(
      "You must specify either a number of dimensions
      or both antigen and sera coordinates"
    ))
  }

  # Infer the number of dimensions
  if (is.null(number_of_dimensions)) {
    number_of_dimensions <- ncol(ag_coords)
  }

  # Create the new optimization
  opt <- ac_newOptimization(
    dimensions = number_of_dimensions,
    num_antigens = numAntigens(map),
    num_sera = numSera(map)
  )

  # Set the coordinates if provided
  if (!is.null(ag_coords)) opt <- ac_set_ag_coords(opt, ag_coords)
  if (!is.null(sr_coords)) opt <- ac_set_sr_coords(opt, sr_coords)

  # Set column bases
  if (!is.null(fixed_column_bases)) {
    opt <- ac_opt_set_fixedcolbases(opt, fixed_column_bases)
  }
  opt <- ac_opt_set_mincolbasis(opt, minimum_column_basis)

  # Set antigen reactivity adjustments
  if (!is.null(ag_reactivity_adjustments)) {
    opt <- ac_opt_set_agreactivityadjustments(opt, ag_reactivity_adjustments)
  }

  # Append the optimization
  map$optimizations <- c(
    map$optimizations,
    list(opt)
  )

  # Return the map
  map

}


#' Get all optimization details from an acmap object
#'
#' Gets the details associated with the all the optimizations of an acmap object
#' as a list.
#'
#' @param map The acmap data object
#'
#' @returns Returns a list of lists with information about the optimizations
#'
#' @seealso See `getOptimization()` for getting information about a single
#'   optimization.
#'
#' @export
#'
listOptimizations <- function(map) {

  check.acmap(map)
  map$optimizations

}


#' Get optimization details from an acmap object
#'
#' Gets the details associated with the currently selected or specifed acmap
#' optimization as a list.
#'
#' @param map The acmap data object
#' @param optimization_number The optimization data to access
#'
#' @returns Returns a list with information about the optimization
#'
#' @seealso See `listOptimizations()` for getting information about all
#'   optimizations.
#'
#' @export
#'
getOptimization <- function(map, optimization_number = 1) {

  check.acmap(map)
  check.optnum(map, optimization_number)
  map$optimizations[[optimization_number]]

}
