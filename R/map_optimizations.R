
# Function to convert a optimization number
convertOptimizationNum <- function(optimization_number, map){
  if(numOptimizations(map) == 0) stop("Map has no optimizations")
  if(length(optimization_number) == 0){ optimization_number <- selectedOptimization(map) }
  if(optimization_number > numOptimizations(map) || optimization_number < 1){
    stop("The map object only has ", numOptimizations(map), " optimizations, but you specified optimization number ", optimization_number)
  }
  optimization_number
}

# Stress ---------------

#' Recalculate the stress associated with an acmap optimization
#'
#' Recalculates the stress associated with the currently selected or user-specifed optimization.
#'
#' @param map The acmap data object
#' @param optimization_number The optimization data to access (defaults to the currently selected optimization)
#'
#' @return Returns the map stress
#'
#' @family {map diagnostic functions}{functions relating to map stress calculation}
#' @seealso See \link{pointStress} for getting the stress of individual points.
#' @export
recalculateStress <- function(map, optimization_number = NULL){
  ac_calcStress(
    ag_coords   = agBaseCoords(map, optimization_number),
    sr_coords   = srBaseCoords(map, optimization_number),
    titer_table = titerTableFlat(map),
    colbases    = colBases(map, optimization_number)
  )
}

#' @export
updateStress <- function(map, optimization_number = NULL){
  mapStress(
    map,
    optimization_number,
    .check = FALSE
  ) <- recalculateStress(
    map,
    optimization_number
  )
  map
}

#' Get individual point stress
#'
#' Functions to get stress associated with individual points in a map.
#'
#' @param map The acmap data object
#' @param optimization_number The optimization data to access (defaults to the currently selected optimization)
#' @param antigens Which antigens to check stress for, specified by index or name (defaults to all antigens).
#' @param sera Which sera to check stress for, specified by index or name (defaults to all sera).
#'
#' @seealso See \code{\link{mapStress}} for getting the total map stress directly.
#' @family {map diagnostic functions}{functions relating to map stress calculation}
#' @name pointStress
#'

#' @rdname pointStress
#' @export
agStress <- function(
  map,
  antigens            = TRUE,
  optimization_number = NULL,
  warnings            = TRUE){

  optimization_number <- convertOptimizationNum(optimization_number, map)

  # Convert to indices
  antigens <- get_ag_indices(antigens, map, warnings = TRUE)

  # Calculate the stress
  ag_coords   <- agBaseCoords(map, optimization_number, .name = FALSE)
  sr_coords   <- srBaseCoords(map, optimization_number, .name = FALSE)
  titer_table <- titerTable(map, .name = FALSE)
  colbases    <- colBases(map, optimization_number, .name = FALSE)

  vapply(antigens, function(antigen){
    ac_calcStress(ag_coords   = ag_coords[antigen,,drop=FALSE],
                  sr_coords   = sr_coords,
                  titer_table = titer_table[antigen,,drop=FALSE],
                  colbases    = colbases)
  }, numeric(1))

}

#' @rdname pointStress
#' @export
srStress <- function(
  map,
  sera                = TRUE,
  optimization_number = NULL,
  warnings            = TRUE
){

  # Convert to indices
  sera <- get_sr_indices(sera, map, warnings = TRUE)

  # Calculate the stress
  ag_coords   <- agBaseCoords(map, optimization_number, .name = FALSE)
  sr_coords   <- srBaseCoords(map, optimization_number, .name = FALSE)
  titer_table <- titerTable(map, .name = FALSE)
  colbases    <- colBases(map, optimization_number, .name = FALSE)

  vapply(sera, function(serum){
    ac_calcStress(ag_coords   = ag_coords,
                  sr_coords   = sr_coords[serum,,drop=FALSE],
                  titer_table = titer_table[,serum,drop=FALSE],
                  colbases    = colbases[serum])
  }, numeric(1))

}

#' @rdname pointStress
#' @export
srStressPerTiter <- function(
  map,
  sera                = TRUE,
  optimization_number = NULL,
  exclude_nd          = TRUE
){

  # Convert to indices
  sera <- get_sr_indices(sera, map, warnings = TRUE)

  # Get map residuals omitting anything that's not a measurable value
  map_residuals <- mapResiduals(
    map                 = map,
    optimization_number = optimization_number,
    exclude_nd          = exclude_nd
  )

  # Calculate the serum likelihood
  vapply(sera, function(serum){

    sr_residuals <- map_residuals[,serum]
    sr_residuals <- sr_residuals[!is.na(sr_residuals)]
    sqrt((sum(sr_residuals^2) / length(sr_residuals)))

  }, numeric(1))

}


#' @rdname pointStress
#' @export
agStressPerTiter <- function(
  map,
  antigens            = TRUE,
  optimization_number = NULL,
  exclude_nd          = TRUE
){

  # Convert to indices
  antigens <- get_ag_indices(antigens, map, warnings = TRUE)

  # Get map residuals omitting anything that's not a measurable value
  map_residuals <- mapResiduals(
    map                 = map,
    optimization_number = optimization_number,
    exclude_nd          = exclude_nd
  )

  # Calculate the serum likelihood
  vapply(antigens, function(antigen){

    ag_residuals <- map_residuals[antigen,]
    ag_residuals <- ag_residuals[!is.na(ag_residuals)]
    sqrt((sum(ag_residuals^2) / length(ag_residuals)))

  }, numeric(1))

}


#' Add a new optimization to an acmap object
#'
#' Function to add a new optimization to an acmap object, with specified values.
#'
#' @param map The acmap data object
#' @param ag_coords Antigen coordinates for the new optimization (random if not specified)
#' @param sr_coords Sera coordinates for the new optimization (random if not specified)
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
#' @seealso See \code{\link{getOptimization}} for getting information about a single optimization.
#'
#' @export
#'
listOptimizations <- function(map){

  map$optimizations

}


#' Get optimization details from an acmap object
#'
#' Gets the details associated with the currently selected or specifed acmap optimization
#' as a list.
#'
#' @param map The acmap data object
#' @param optimization_number The optimization data to access (defaults to the currently selected optimization)
#'
#' @return Returns a list with information about the optimization
#'
#' @seealso See \code{\link{listOptimizations}} for getting information about all
#'   optimizations.
#'
#' @export
#'
getOptimization <- function(map, optimization_number = 1){

  map$optimizations[[optimization_number]]

}









