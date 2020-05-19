
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


#' @rdname pointStress
#' @export
srLikelihood <- function(
  map,
  sera = TRUE,
  total_error_sd,
  optimization_number = NULL,
  warnings            = TRUE
){

  # Check input
  if(missing(total_error_sd)) stop("You must estimate the expected standard deviation of measurement error noise")

  # Convert to indices
  sera <- get_sr_indices(sera, map, warnings = TRUE)

  # Get map residuals omitting anything that's not a measurable value
  map_residuals <- mapResiduals(
    map                 = map,
    optimization_number = optimization_number,
    exclude_nd          = TRUE
  )

  # Calculate the serum likelihood
  vapply(sera, function(serum){

    sr_residuals <- map_residuals[,serum]
    sr_residuals <- sr_residuals[!is.na(sr_residuals)]

    num_detectable   <- length(sr_residuals)
    nss_sr_residuals <- sum((sr_residuals / total_error_sd)^2)

    # Find the likelihood of the error sum
    p_residuals <- pchisq(q = nss_sr_residuals, df = num_detectable)
    if(p_residuals > 0.5) p_residuals <- 1 - p_residuals
    p_residuals*2

  }, numeric(1))

}

#' @rdname pointStress
#' @export
agLikelihood <- function(
  map,
  antigens = TRUE,
  total_error_sd,
  optimization_number = NULL,
  warnings            = TRUE
){

  # Convert to indices
  antigens <- get_ag_indices(antigens, map, warnings = TRUE)

  # Get map residuals omitting anything that's not a measurable value
  map_residuals <- mapResiduals(
    map                 = map,
    optimization_number = optimization_number,
    exclude_nd          = TRUE
  )

  # Calculate the serum likelihood
  vapply(antigens, function(antigen){

    ag_residuals <- map_residuals[antigen,]
    ag_residuals <- ag_residuals[!is.na(ag_residuals)]

    num_detectable   <- length(ag_residuals)
    nss_ag_residuals <- sum((ag_residuals / total_error_sd)^2)

    # Find the likelihood of the error sum
    p_residuals <- pchisq(q = nss_ag_residuals, df = num_detectable)
    if(p_residuals > 0.5) p_residuals <- 1 - p_residuals
    p_residuals*2

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
  number_of_dimensions,
  minimum_column_basis = NULL,
  warnings             = TRUE,
  ...
){

  # Set arguments
  arguments <- list(...)
  if("ag_base_coords" %in% names(arguments) && !is.null(ag_coords)) stop("You can supply only one of 'ag_base_coords' and 'ag_coords'")
  if("sr_base_coords" %in% names(arguments) && !is.null(sr_coords)) stop("You can supply only one of 'sr_base_coords' and 'sr_coords'")
  if(!"ag_base_coords" %in% names(arguments)) arguments$ag_base_coords <- ag_coords
  if(!"sr_base_coords" %in% names(arguments)) arguments$sr_base_coords <- sr_coords

  # Check for unrecognised arguments
  unmatched_args <- names(arguments)[!names(arguments) %in% list_property_function_bindings("optimization")$property]
  if(length(unmatched_args) > 0){
    stop(sprintf("Unrecognised arguments, '%s'", paste(unmatched_args, collapse = "', '")))
  }

  # Decide number of dimensions
  if(!is.null(arguments$ag_base_coords)) {
    number_of_dimensions <- ncol(arguments$ag_base_coords)
  } else if(!is.null(arguments$sr_base_coords)) {
    number_of_dimensions <- ncol(arguments$sr_base_coords)
  } else number_of_dimensions <- 2

  ## Decide antigen and sera coordinates
  if(is.null(arguments$ag_base_coords)) arguments$ag_base_coords <- matrix(nrow = numAntigens(map), ncol = number_of_dimensions)
  if(is.null(arguments$sr_base_coords)) arguments$sr_base_coords <- matrix(nrow = numSera(map), ncol = number_of_dimensions)

  ## Check that column bases match up if provided separately when minimum_column_basis is specified
  if(!is.null(minimum_column_basis) && minimum_column_basis != "fixed" && "column_bases" %in% names(arguments)){
    expected_colbases <- unname(ac_getTableColbases(titer_table             = titerTable(map),
                                                    minimum_column_basis = minimum_column_basis))
    if(!isTRUE(all.equal(expected_colbases, unname(arguments[["column_bases"]])))){
      stop("Column bases provided do not match up with minimum_column_basis specification of '", minimum_column_basis, "'")
    }
    ### Remove the column bases argument if they are
    arguments$column_bases <- NULL
  }

  ## Check that column bases are provided separately when minimum_column_basis = "fixed"
  if(!is.null(minimum_column_basis) && minimum_column_basis == "fixed"){
    if(!"column_bases" %in% names(arguments)){
      ### Stop if they are not provided
      stop("Column bases must be provided via the 'column_bases' argument when minimum_column_basis='fixed'")
    } else {
      ### Set the minimum column basis to "none" if they are
      minimum_column_basis <- "none"
    }
  }

  # Set a default minimum column basis of none
  if(is.null(minimum_column_basis)){
    # warning("No minimum column basis specified so was set to 'none'")
    minimum_column_basis <- "none"
  }

  # Check minimum column basis is the right length
  if(length(minimum_column_basis) != 1){
    stop("minumum_column_basis must be provided as a vector of length 1")
  }

  # Add a new empty optimization
  map <- optimization.add(
    map                  = map,
    number_of_dimensions = number_of_dimensions,
    minimum_column_basis = as.character(minimum_column_basis)
  )

  # Select the new optimization run
  if(is.null(selectedOptimization(map))) selectedOptimization(map) <- 1

  # Apply the methods to set the variables
  optimization_functions <- list_property_function_bindings("optimization")
  optimization_number <- numOptimizations(map)
  for(i in seq_along(arguments)){
    setter <- get(paste0(optimization_functions$method[optimization_functions$property == names(arguments)[i]], "<-"))
    map    <- setter(map, optimization_number, value = arguments[[i]])
  }

  # Return the map
  map

}

optimization.add <- function(map, ...) UseMethod("optimization.add", map)


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

  UseMethod("listOptimizations", map)

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
getOptimization <- function(map, optimization_number = NULL){

  optimization_function_list <- list_property_function_bindings("optimization")
  values <- list()
  for(i in seq_len(nrow(optimization_function_list))){
    getter <- get(optimization_function_list$method[i])
    values[[optimization_function_list$property[i]]] <- getter(map, optimization_number)
  }
  values

}









