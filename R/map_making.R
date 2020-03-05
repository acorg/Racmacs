
#' Make an antigenic map from scratch
#'
#' @param number_of_dimensions The number of dimensions in the map
#' @param number_of_optimizations The number of optimization runs to perform
#' @param minimum_column_basis The minimum column basis for the map
#' @param move_trapped_points How should removal of trapped points be performed (see details)
#' @param ...
#'
#' @details
#' Hunting for and removal of trapped points can be performed for either none of
#' the optimization runs ("none"), all of the optimization runs ("all") or only
#' the best one found ("best").
#'
#' @return Returns an antigenic map object of the corresponding class.
#'
#' @example examples/example_make_map_from_scratch.R
#' @export
#'
make.acmap <- function(number_of_dimensions    = 2,
                       number_of_optimizations = 100,
                       minimum_column_basis    = "none",
                       move_trapped_points     = NULL,
                       ...){

  # Only allow arguments that don't refer to creating optimizations
  arguments <- list(...)
  property_function_bindings <- list_property_function_bindings()
  optimization_arguments <- property_function_bindings$property[property_function_bindings$object == "optimization"]
  if(sum(names(arguments) %in% optimization_arguments) > 0) {
    stop("Cannot set property '", paste(names(arguments)[names(arguments) %in% optimization_arguments], collapse = "', '"), "'.")
  }

  # Make the chart
  map <- acmap(...)

  # Run the optimizations
  optimizeMap(map                     = map,
              number_of_dimensions    = number_of_dimensions,
              number_of_optimizations = number_of_optimizations,
              minimum_column_basis    = minimum_column_basis,
              move_trapped_points     = move_trapped_points)

}

#' @export
make.acmap.cpp <- function(number_of_dimensions    = 2,
                           number_of_optimizations = 100,
                           minimum_column_basis    = "none",
                           move_trapped_points     = NULL,
                           ...){

  # Only allow arguments that don't refer to creating optimizations
  arguments <- list(...)
  property_function_bindings <- list_property_function_bindings()
  optimization_arguments <- property_function_bindings$property[property_function_bindings$object == "optimization"]
  if(sum(names(arguments) %in% optimization_arguments) > 0) {
    stop("Cannot set property '", paste(names(arguments)[names(arguments) %in% optimization_arguments], collapse = "', '"), "'.")
  }

  # Make the chart
  chart <- acmap.cpp(...)

  # Run the optimizations
  optimizeMap(map                     = chart,
              number_of_dimensions    = number_of_dimensions,
              number_of_optimizations = number_of_optimizations,
              minimum_column_basis    = minimum_column_basis,
              move_trapped_points     = move_trapped_points)

}



