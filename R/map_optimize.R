
#' Optimize an acmap
#'
#' Take an acmap object with a table of titer data and perform optimization runs
#' to try and find the best arrangement of antigens and sera to represent their
#' antigenic similarity. Optimizations generated from each run with different
#' random starting conditions will be added to the acmap object.
#'
#' @param map The acmap data object
#' @param number_of_dimensions The number of dimensions for the new map
#' @param number_of_optimizations The number of optimization runs to perform
#' @param minimum_column_basis The minimum column basis to use (see details)
#' @param fixed_column_bases A vector of fixed values to use as column bases
#'   directly, rather than calculating them from the titer table.
#' @param sort_optimizations Should optimizations be sorted by stress
#'   afterwards?
#' @param verbose Should progress messages be reported, see also
#'   `RacOptimizer.options()`
#' @param options List of named optimizer options, see `RacOptimizer.options()`
#'
#' @details This is the core function to run map optimizations. In essence, for
#'   each optimization run, points are randomly distributed in n-dimensional
#'   space, the L-BFGS gradient-based optimization algorithm is applied to move
#'   points into an optimal position. Depending on the map, this may not be a
#'   trivial optimization process and results will depend upon the starting
#'   conditions so multiple optimization runs may be required. For a full
#'   explanation see `vignette("intro-to-antigenic-cartography")`.
#'
#'   ## Minimum column basis and fixed column bases Fixed column bases is a
#'   vector of fixed column bases for each sera, where NA is specified (the
#'   default) column bases will be calculated according to the
#'   `minimum_column_basis` setting. Again for a full explanation of column
#'   bases and what they mean see `vignette("intro-to-antigenic-cartography")`.
#'
#' @return Returns the acmap object updated with new optimizations.
#'
#' @seealso See `relaxMap()` for optimizing a given optimization starting from
#'   its current coordinates.
#'
#' @family {map optimization functions}
#' @export
#'
optimizeMap <- function(
  map,
  number_of_dimensions,
  number_of_optimizations,
  minimum_column_basis = "none",
  fixed_column_bases = NULL,
  sort_optimizations = TRUE,
  verbose  = TRUE,
  options = list()
  ) {

  # Set arguments
  if (is.null(fixed_column_bases)) {
    fixed_column_bases <- rep(NA, numSera(map))
  }

  # Warn about overwriting previous optimizations
  if (numOptimizations(map) > 0) {
    vmessage(verbose, "Discarding previous optimization runs.")
  }
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

  # Check for disconnected or underconstrained points
  ag_num_measured <- rowSums(titertypesTable(map) == 1)
  sr_num_measured <- colSums(titertypesTable(map) == 1)

  ag_disconnected <- ag_num_measured < number_of_dimensions
  sr_disconnected <- sr_num_measured < number_of_dimensions

  ag_underconstrained <- ag_num_measured < number_of_dimensions + 1
  sr_underconstrained <- sr_num_measured < number_of_dimensions + 1

  if (sum(ag_disconnected) > 0) warn_disconnected("antigens", agNames(map)[ag_disconnected], number_of_dimensions)
  if (sum(sr_disconnected) > 0) warn_disconnected("sera", srNames(map)[sr_disconnected], number_of_dimensions)

  if (sum(ag_underconstrained) > 0) warn_underconstrained("antigens", agNames(map)[ag_underconstrained], number_of_dimensions)
  if (sum(sr_underconstrained) > 0) warn_underconstrained("sera", srNames(map)[sr_underconstrained], number_of_dimensions)

  # Set disconnected point coordinates to NaN
  agCoords(map)[ag_disconnected,] <- NaN
  srCoords(map)[sr_disconnected,] <- NaN

  # Output finishing messages
  tend <- Sys.time()
  tlength <- round(tend - tstart, 2)
  vmessage(
    verbose,
    "Took ",
    format(unclass(tlength)),
    " ",
    attr(tlength, "units"),
    "\n"
  )

  # Return the optimised map
  map

}


#' Make an antigenic map from scratch
#'
#' This is a wrapper function for first making a map with table data then,
#' running optimizations to make the map otherwise done with `acmap()`
#' followed by `optimizeMap()`.
#'
#' @param titer_table A table of titer data
#' @param ag_names A vector of antigen names
#' @param sr_names A vector of sera names
#' @param number_of_dimensions The number of dimensions in the map
#' @param number_of_optimizations The number of optimization runs to perform
#' @param minimum_column_basis The minimum column basis for the map
#' @param fixed_column_bases A vector of fixed values to use as column bases
#'   directly, rather than calculating them from the titer table.
#' @param sort_optimizations Should optimizations be sorted by stress
#'   afterwards?
#' @param verbose Should progress messages be reported, see also
#'   `RacOptimizer.options()`
#' @param options List of named optimizer options, see `RacOptimizer.options()`
#'
#' @return Returns an acmap object that has optimization run results.
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
  fixed_column_bases      = NULL,
  sort_optimizations      = TRUE,
  verbose                 = TRUE,
  options                 = list(),
  ...
  ) {

  # Check arguments
  ellipsis::check_dots_used()

  # Make the chart
  map <- acmap(
    titer_table = titer_table,
    ag_names = ag_names,
    sr_names = sr_names,
    ...
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
#' This function facilitates setting options for the acmap optimizer process by
#' returning a list of option settings.
#'
#' @param dim_annealing Should dimensional annealing be performed
#' @param method The optimization method to use
#' @param maxit The maximum number of iterations to use in the optimizer
#' @param num_cores The number of cores to run in parallel
#' @param report_progress Should progress be reported
#' @param progress_bar_length Progress bar length when progress is reported
#'
#' @details For more details, for example on "dimensional annealing" see
#'   `vignette("intro-to-antigenic-cartography")`. For details on optimizer
#'   settings like `maxit` see the underlying optimizer documentation at
#'   [ensmallen.org](http://ensmallen.org).
#'
#' @family {map optimization functions}
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
  if (!is.null(report_progress)) check.logical(report_progress)

  # This is a hack to attempt to see if messages are currently suppressed
  if (is.null(report_progress)) {
    report_progress <- length(
      utils::capture.output(message("a"), type = "message")
    ) > 0
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
#' @param optimization_number The optimization number to relax
#' @param fixed_antigens Antigens to set fixed positions for when relaxing
#' @param fixed_sera Sera to set fixed positions for when relaxing
#' @param options List of named optimizer options, see `RacOptimizer.options()`
#'
#' @return Returns an acmap object with the optimization relaxed.
#'
#' @seealso See `optimizeMap()` for performing new optimization runs from random
#'   starting coordinates.
#'
#' @family {map optimization functions}
#' @export
#'
relaxMap <- function(
  map,
  optimization_number = 1,
  fixed_antigens = FALSE,
  fixed_sera = FALSE,
  options = list()
  ) {

  # Get options
  if (sum(titerTable(map) != "*") == 0) stop("Table has no measurable titers")
  options <- do.call(RacOptimizer.options, options)

  # Convert point references to indices
  fixed_antigens <- get_ag_indices(fixed_antigens, map)
  fixed_sera     <- get_sr_indices(fixed_sera, map)

  # Run relaxation
  map$optimizations[[optimization_number]] <- ac_relaxOptimization(
    opt = map$optimizations[[optimization_number]],
    titers = titerTable(map),
    fixed_antigens = fixed_antigens - 1,
    fixed_sera = fixed_sera - 1,
    options = options
  )

  # Return the map
  map

}


#' Relax a map one step in the optimiser
#'
#' @param map The acmap data object
#' @param optimization_number The map optimization number
#' @param fixed_antigens Antigens to set fixed positions for when relaxing
#' @param fixed_sera Sera to set fixed positions for when relaxing
#' @param options List of named optimizer options, see `RacOptimizer.options()`
#'
#' @return Returns an updated map object
#'
#' @family {map optimization functions}
#' @export
#'
relaxMapOneStep <- function(
  map,
  optimization_number = 1,
  fixed_antigens = FALSE,
  fixed_sera = FALSE,
  options = list()
) {

  # Get options
  options <- do.call(RacOptimizer.options, options)
  options$maxit <- 1

  # Convert point references to indices
  fixed_antigens <- get_ag_indices(fixed_antigens, map)
  fixed_sera     <- get_sr_indices(fixed_sera, map)

  # Update optimization
  map$optimizations[[optimization_number]] <- ac_relaxOptimization(
    opt = map$optimizations[[optimization_number]],
    titers = titerTable(map),
    fixed_antigens = fixed_antigens - 1,
    fixed_sera = fixed_sera - 1,
    options = options
  )
  map

}

#' Randomize map coordinates
#'
#' Moves map coordinates back into random starting conditions, as performed
#' before each optimization run. The maximum table distance is calculated
#' then points are randomized in a box with side length equal to maximum
#' table distance multiplied by `table_dist_factor`
#'
#' @param map The acmap data object
#' @param optimization_number The map optimization number to randomize
#' @param table_dist_factor The expansion factor for the box size in which
#'   points are randomized.
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

  random_coords <- function(nrow, ndim, min, max) {
    matrix(
      data = stats::runif(nrow * ndim, min, max),
      nrow = nrow,
      ncol = ndim
    )
  }

  agBaseCoords(map, optimization_number) <- random_coords(
    nrow = numAntigens(map),
    ndim = mapDimensions(map, optimization_number = optimization_number),
    min  = -(max_table_dist * table_dist_factor) / 2,
    max  = (max_table_dist * table_dist_factor) / 2
  )

  srBaseCoords(map, optimization_number) <- random_coords(
    nrow = numSera(map),
    ndim = mapDimensions(map, optimization_number = optimization_number),
    min  = -(max_table_dist * table_dist_factor) / 2,
    max  = (max_table_dist * table_dist_factor) / 2
  )

  map

}


#' Check if a map has been fully relaxed
#'
#' Checks if the map optimization run can be relaxed further.
#'
#' @param map The acmap data object
#' @param optimization_number The map optimization number
#' @param options List of named optimizer options, see `RacOptimizer.options()`
#'
#' @return Returns TRUE or FALSE
#' @export
#' @family {map diagnostic functions}
#'
mapRelaxed <- function(
  map,
  optimization_number = 1,
  options = list()
  ) {

  # Check stress
  stress <- mapStress(map, optimization_number)

  # Relax map
  relaxed_map <- relaxMapOneStep(
    map,
    optimization_number,
    options = do.call(RacOptimizer.options, options)
  )
  relaxed_stress <- mapStress(relaxed_map, optimization_number)

  # Compare stress
  isTRUE(stress - relaxed_stress < 0.0001)

}


#' Check for hemisphering or trapped points
#'
#' @param map The acmap data object
#' @param optimization_number The map optimization number
#' @param stepsize Grid spacing in antigenic units of the search grid to use
#'   when searching for hemisphering positions
#'
#' @return Returns a data frame with information on any points that were found
#'   to be hemisphering or trapped.
#' @export
#' @family {map diagnostic functions}
#'
checkHemisphering <- function(
  map,
  optimization_number = 1,
  grid_spacing = 0.25,
  stress_lim = 0.1,
  options = list()
  ) {

  # Check map is relaxed
  if (!mapRelaxed(map, optimization_number, options)) {
    stop("Map optimization is not fully relaxed", call. = FALSE)
  }

  # Perform the hemi test
  map$optimizations[[optimization_number]] <- ac_hemi_test(
    optimization = map$optimizations[[optimization_number]],
    tabledists = tableDistances(map, optimization_number),
    titertypes = titertypesTable(map),
    grid_spacing = grid_spacing,
    stress_lim = stress_lim,
    options = do.call(RacOptimizer.options, options)
  )

  # Return the map
  map

}


#' Move trapped points
#'
#' Sometimes points in a map optimization run get trapped in local optima, this
#' function tries to combat this by doing a grid search for each point
#' individually moving points if a better optima is found. Note that this only
#' performs grid searches individually so won't find cases where a group of
#' points are trapped together in a local optima.
#'
#' The search is iterative, searching for and moving points that are found to be
#' trapped before relaxing the map and searching again, stopping either when no
#' more trapped points are found or `max_iterations` is reached.
#'
#' @param map The acmap data object
#' @param optimization_number The map optimization number to apply it to
#' @param grid_spacing Grid spacing in antigenic units of the search grid to use
#'   when searching for more optimal positions
#' @param max_iterations The maximum number of interations of searching for
#'   trapped points then relaxing the map to be performed
#' @param options List of named optimizer options, see `RacOptimizer.options()`
#'
#' @return Returns the acmap object with updated coordinates (if any trapped
#'   points found)
#' @family {map optimization functions}
#' @export
#'
moveTrappedPoints <- function(
  map,
  optimization_number = 1,
  grid_spacing = 0.25,
  max_iterations = 10,
  options = list()
  ) {

  # Move trapped points in the optimization
  map$optimizations[[optimization_number]] <- ac_move_trapped_points(
    optimization = map$optimizations[[optimization_number]],
    tabledists = tableDistances(map, optimization_number),
    titertypes = titertypesTable(map),
    grid_spacing = grid_spacing,
    options = do.call(RacOptimizer.options, options),
    max_iterations = max_iterations
  )

  # Realign optimizations
  map <- realignOptimizations(map)

  # Return the map
  map

}


# Functions for fetching hemisphering information
agHemisphering <- function(map, optimization_number = 1) {
  lapply(agDiagnostics(map, optimization_number), function(ag) ag$hemi)
}
srHemisphering <- function(map, optimization_number = 1) {
  lapply(srDiagnostics(map, optimization_number), function(sr) sr$hemi)
}
ptHemisphering <- function(map, optimization_number = 1) {
  c(agHemisphering(map, optimization_number), srHemisphering(map, optimization_number))
}
hasHemisphering <- function(map, optimization_number = 1) {
  sum(vapply(ptHemisphering(map, optimization_number), function(x) length(x) > 0, logical(1))) > 0
}


# Functions for warning that points are disconnected / underconstrained
warn_underconstrained <- function(type, strains, number_of_dimensions) {
  strain_list_warning(
    sprintf(
      singleline("The following %s have do not have enough titrations to position
                    in %s dimensions. Coordinates were still optimized but positions
                    will be unreliable"),
      type,
      number_of_dimensions
    ),
    strains
  )
}

warn_disconnected <- function(type, strains, number_of_dimensions) {
  strain_list_warning(
    sprintf(
      singleline("The following %s are too underconstrained to position in %s dimensions
                 and coordinates have been set to NaN:"),
      type,
      number_of_dimensions
    ),
    strains
  )
}
