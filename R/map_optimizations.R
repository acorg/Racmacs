
#' Add a new optimization to an acmap object
#'
#' Function to add a new optimization to an acmap object, with specified values.
#'
#' @param map The acmap data object
#' @param ag_coords Antigen coordinates for the new optimization (0 if not specified)
#' @param sr_coords Sera coordinates for the new optimization (0 if not specified)
#' @param number_of_dimensions The number of dimensions of the new optimization
#' @param minimum_column_basis The minimum column basis to use for the new optimization
#' @param ... Further optimization parameters
#'
#' @return Returns the acmap data object with new optimization added (but not selected).
#'
#' @export
#'
addOptimization <- function(
  map,
  ag_coords = NULL,
  sr_coords = NULL,
  number_of_dimensions = NULL,
  minimum_column_basis = "none",
  fixed_column_bases = NULL
){

  # Check input
  if(is.null(number_of_dimensions) && (is.null(ag_coords) || is.null(sr_coords))){
    stop("You must specify either a number of dimensions or both antigen and sera coordinates")
  }

  # Infer the number of dimensions
  if(is.null(number_of_dimensions)){
    number_of_dimensions <- ncol(ag_coords)
  }

  # Create the new optimization
  opt <- ac_newOptimization(
    dimensions = number_of_dimensions,
    num_antigens = numAntigens(map),
    num_sera = numSera(map)
  )

  # Set the coordinates if provided
  if(!is.null(ag_coords)) opt <- ac_set_ag_coords(opt, ag_coords)
  if(!is.null(sr_coords)) opt <- ac_set_sr_coords(opt, sr_coords)

  # Set column bases
  if(!is.null(fixed_column_bases)){ opt <- ac_opt_set_fixedcolbases(opt, fixed_column_bases) }
  opt <- ac_opt_set_mincolbasis(opt, minimum_column_basis)

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
#' Gets the details associated with the all the optimizations of an acmap object as a list.
#'
#' @param map The acmap data object
#'
#' @return Returns a list of lists with information about the optimizations
#'
#' @seealso See `getOptimization()` for getting information about a single optimization.
#'
#' @export
#'
listOptimizations <- function(map){

  check.acmap(map)
  map$optimizations

}


#' Get optimization details from an acmap object
#'
#' Gets the details associated with the currently selected or specifed acmap optimization
#' as a list.
#'
#' @param map The acmap data object
#' @param optimization_number The optimization data to access
#'
#' @return Returns a list with information about the optimization
#'
#' @seealso See `listOptimizations()` for getting information about all
#'   optimizations.
#'
#' @export
#'
getOptimization <- function(map, optimization_number = 1){

  check.acmap(map)
  map$optimizations[[optimization_number]]

}


