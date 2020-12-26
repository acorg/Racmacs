
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
#'
#' @family {map optimization functions}
#' @export
#'
make.acmap <- function(
  titer_table             = NULL,
  ag_names                = NULL,
  sr_names                = NULL,
  number_of_dimensions    = 2,
  number_of_optimizations = 100,
  minimum_column_basis    = "none",
  fixed_column_bases      = rep(NA, ncol(titer_table)),
  sort_optimizations      = TRUE,
  verbose                 = TRUE,
  options                 = list()
  ){

  # Make the chart
  map <- acmap(
    titer_table = titer_table,
    ag_names = ag_names,
    sr_names = sr_names
  )

  # Run the optimizations
  optimizeMap(
    map = map,
    number_of_dimensions = number_of_dimensions,
    number_of_optimizations = number_of_optimizations,
    minimum_column_basis = minimum_column_basis,
    fixed_column_bases = fixed_column_bases,
    sort_optimizations = sort_optimizations,
    verbose = verbose,
    options = options
  )

}



