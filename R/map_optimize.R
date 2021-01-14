
#' Optimize an acmap
#'
#' Take an acmap object with a table of titer data and perform optimization runs
#' to try and find the best arrangement of antigens and sera to represent their
#' antigenic similarity. Optimizations generated from each run with different random
#' starting conditions will be added to the acmap object.
#'
#' @param map The acmap data object
#' @param number_of_dimensions The number of dimensions for the new map
#' @param number_of_optimizations The number of optimization runs to perform
#' @param minimum_column_basis The minimum column basis to use (see details)
#' @param move_trapped_points Should trapped points be searched for and removed, one of 'none', 'best' or 'all' (see details)
#' @param discard_previous_optimizations Should previous optimizations associated with this map be discarded?
#' @param sort_optimizations Should optimizations be sorted by stress afterwards?
#' @param realign_optimizations Should optimizations be realigned to align as closely as possible with each other?
#' @param fixed_column_bases A vector of fixed values to use as column bases directly, rather than calculating them from the titer table.
#' @param dimensional_annealing Should dimensional annealing be applied?
#' @param stepsize Step size to use when searching for trapped points (lower will be a finer search)
#' @param verbose Should progress be reported?
#' @param vverbose Should very detailed progress be reported?
#' @param parallel_optimization Should optimization runs be performed in parallel
#'
#' @details This is the core function to run map optimizations. In essence, for each optimization run, points are randomly distributed in
#' 5-dimensional space, the L-BFGS gradient-based optimization algorithm is applied to move points into an optimal position and then
#' principal component analysis is used to reduce the number of dimensions and the process repeated until the desired number of dimensions is
#' reached. Depending on the map, this may not be a trivial optimization process and results will depend upon the starting conditions.
#'
#' \subsection{Trapped points}{
#' Each optimization run can be checked for trapped points which involves taking each point in turn and testing it in different alternative
#' locations in the map. If a more optimal position is found, the point is moved and the process repeated.
#'
#' Although effective this is computationally quite expensive and so the default setting is to apply this only the 'best' (lowest stress) map.
#' This step can alternatively be skipped by setting 'none' or applied to all optimization runs by specifying 'all'.
#' }
#'
#' \subsection{Minimum column basis}{
#' }
#'
#' @return Returns the acmap object updated with new optimizations.
#'
#' @seealso See \code{\link{relaxMap}} for optimizing a given optimization starting from its current coordinates.
#'
#' @family {map optimization functions}
#' @export
#'
optimizeMap <- function(
  map,
  number_of_dimensions,
  number_of_optimizations,
  minimum_column_basis = "none",
  fixed_column_bases = rep(NA, numSera(map)),
  sort_optimizations = TRUE,
  verbose  = TRUE,
  options = list()
  ){

  # Warn about overwriting previous optimizations
  if(numOptimizations(map) > 0) vmessage(verbose, "Discarding previous optimization runs.")
  map <- removeOptimizations(map)

  # Get optimizer options
  options <- do.call(RacOptimizer.options, options)

  # Perform the optimization runs
  tstart <- Sys.time()

  map <- ac_optimize_map(
    map = map,
    num_dims = number_of_dimensions,
    num_optimizations = number_of_optimizations,
    min_col_basis = minimum_column_basis,
    fixed_col_bases = fixed_column_bases,
    options = options
  )

  tend <- Sys.time()
  tlength <- round(tend - tstart, 2)
  message("Took ", format(unclass(tlength)), " ", attr(tlength, "units"), "\n")

  # Return the optimised map
  map

}


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


#' Set acmap optimization options
#'
#' This function facilitates setting options for the acmap optimizer process by returning a list of option settings.
#'
#' @param point.opacity Default opacity for unselected points
#' @param viewer.controls Should viewer controls be shown or hidden by default?
#'
#' @return Returns a named list of optimizer options
#' @export
#'
RacOptimizer.options <- function(
  dim_annealing = FALSE,
  method = "L-BFGS",
  maxit = 1000,
  num_cores = parallel::detectCores(),
  report_progress = NULL,
  progress_bar_length = options()$width
) {

  # Check input
  check.logical(dim_annealing)
  check.string(method)
  check.numeric(maxit)
  check.numeric(num_cores)
  check.numeric(progress_bar_length)
  if(!is.null(report_progress)) check.logical(report_progress)

  # This is a hack to attempt to see if messages are currently suppressed
  if(is.null(report_progress)){
    report_progress <- length(capture.output(message("a"), type = "message")) > 0
  }

  list(
    dim_annealing = dim_annealing,
    method = method,
    maxit = maxit,
    num_cores = num_cores,
    report_progress = report_progress,
    progress_bar_length = progress_bar_length
  )

}


#' Relax a map
#'
#' Optimize antigen and serum positions starting from their current coordinates
#' in the selected or specified optimization.
#'
#' @param map The acmap object
#' @param optimization_number The optimization to relax (defaults to the currently selected optimization)
#'
#' @return Returns an acmap object with the newly relaxed point coordinates.
#'
#' @seealso See \code{\link{optimizeMap}} for performing new optimization runs from random starting coordinates.
#'
#' @family {map optimization functions}
#' @export
#'
relaxMap <- function(
  map,
  optimization_number = 1,
  options = list()
  ) {

  # Get options
  options <- do.call(RacOptimizer.options, options)

  # Run relaxation
  map$optimizations[[optimization_number]] <- ac_relaxOptimization(
    map$optimizations[[optimization_number]],
    titers = titerTable(map),
    options = options
  )

  # Return the map
  map

}


#' Relax a map one step in the optimiser
#'
#' @param map The acmap data object
#' @param optimization_number The map optimization number (defaults to the currently selected optimization)
#'
#' @return Returns an updated map object
#'
#' @family {map optimization functions}
#' @export
#'
relaxMapOneStep <- function(
  map,
  optimization_number = 1,
  options = list()
) {

  # Get options
  options <- do.call(RacOptimizer.options, options)
  options$maxit <- 1

  # Update optimization
  map$optimizations[[optimization_number]] <- ac_relaxOptimization(
    map$optimizations[[optimization_number]],
    titers = titerTable(map),
    options = options
  )
  map

}

#' Randomize map coordinates
#'
#' Moves map coordinates back into random starting conditions, as performed
#' before each optimization run.
#'
#' @param map The acmap data object
#' @param optimization_number The map optimization number (defaults to the currently selected optimization)
#'
#' @return Returns an updated map object
#'
#' @family {map optimization functions}
#' @export
#'
randomizeCoords <- function(
  map,
  optimization_number = 1,
  table_dist_factor = 2
  ) {

  table_dists <- tableDistances(map, optimization_number = optimization_number)
  max_table_dist <- max(table_dists, na.rm = TRUE)

  agBaseCoords(map) <- Racmacs:::random_coords(
    nrow = numAntigens(map),
    ndim = mapDimensions(map, optimization_number = optimization_number),
    min  = -(max_table_dist*table_dist_factor)/2,
    max  = (max_table_dist*table_dist_factor)/2
  )

  srBaseCoords(map) <- Racmacs:::random_coords(
    nrow = numSera(map),
    ndim = mapDimensions(map, optimization_number = optimization_number),
    min  = -(max_table_dist*table_dist_factor)/2,
    max  = (max_table_dist*table_dist_factor)/2
  )

  map

}


#' Check if a map has been fully relaxed
#'
#' @param map The acmap data object
#' @param optimization_number The map optimization number (defaults to the currently selected optimization)
#'
#' @return Returns TRUE or FALSE
#' @export
#' @family {map diagnostic functions}
#'
mapRelaxed <- function(
  map,
  optimization_number = 1
  ){

  # Check stress
  stress         <- mapStress(map, optimization_number)

  # Relax map
  relaxed_map    <- relaxMapOneStep(map, optimization_number)
  relaxed_stress <- mapStress(relaxed_map, optimization_number)

  # Compare stress
  isTRUE(all.equal(relaxed_stress, stress))

}



#' Check for hemisphering or trapped points
#'
#' @param map The acmap data object
#' @param optimization_number The map optimization number (defaults to the currently selected optimization)
#'
#' @return Returns a data frame with information on any points that were found
#'   to be hemisphering or trapped.
#' @export
#' @family {map diagnostic functions}
#'
checkHemisphering <- function(map, stepsize = 0.1, optimization_number = NULL){
  UseMethod("checkHemisphering")
}


#' Move trapped points
#'
#' Iteratively searches for and moves points that are found to be trapped in a
#' optimization, stopping when no more trapped points are found.
#'
#' @param map The acmap data object
#' @param optimization_number The map optimization number (defaults to the currently selected optimization)
#'
#' @return Returns the acmap object with updated coordinates
#' @family {map optimization functions}
#' @export
#'
moveTrappedPoints <- function(
  map,
  optimization_number = 1,
  stress_lim   = 1,
  grid_spacing = 0.25,
  max_iterations = 10,
  options = list()
  ){

  # Move trapped points in the optimization
  map$optimizations[[optimization_number]] <- ac_move_trapped_points(
    optimization = map$optimizations[[optimization_number]],
    tabledists = tableDistances(map, optimization_number),
    titertypes = titerTypesInt(titerTable(map)),
    grid_spacing = grid_spacing,
    options = do.call(RacOptimizer.options, options),
    max_iterations = max_iterations
  )

  # Realign optimizations
  map <- realignOptimizations(map)

  # Return the map
  map

}


#' Add data on hemisphering diagnostics to a map
#'
#' @param map The acmap data object
#' @param optimization_number The map optimization number (defaults to the currently selected optimization)
#'
#' @return Returns the map data with additional diagnostic information on hemisphering points included.
#'
#' @noRd
#' @export
#'
add_hemispheringData <- function(map, data = NULL, optimization_number = NULL){

  # Process optimization
  optimization_number <- convertOptimizationNum(optimization_number, map)

  # Calculate blob data
  if(is.null(data)){
    data <- checkHemisphering(map = map,
                              optimization = optimization_number)
  }

  # Keep a record
  if(length(map$diagnostics) < optimization_number) {
    map$diagnostics[[optimization_number]] <- list()
  }
  map$diagnostics[[optimization_number]]$hemisphering <- data

  # Return the update map
  map

}


