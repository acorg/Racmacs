
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
#' @param titer_weights An optional matrix of weights to assign each titer when optimizing
#' @param sort_optimizations Should optimizations be sorted by stress
#'   afterwards?
#' @param check_convergence Should a basic check for convergence of lowest stress
#'   optimization runs onto a similar solution be performed.
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
#'   ## Minimum column basis and fixed column bases
#'
#'   Fixed column bases is a vector of fixed column bases for each sera, where
#'   NA is specified (the default) column bases will be calculated according to
#'   the `minimum_column_basis` setting. Again for a full explanation of column
#'   bases and what they mean see `vignette("intro-to-antigenic-cartography")`.
#'
#' @returns Returns the acmap object updated with new optimizations.
#'
#' @seealso See `relaxMap()` for optimizing a given optimization starting from
#'   its current coordinates.
#'
#' @family map optimization functions
#' @export
#'
optimizeMap <- function(
  map,
  number_of_dimensions,
  number_of_optimizations,
  minimum_column_basis = "none",
  fixed_column_bases = NULL,
  titer_weights = NULL,
  sort_optimizations = TRUE,
  check_convergence = TRUE,
  verbose  = TRUE,
  options = list()
  ) {

  # Set default arguments
  if (is.null(fixed_column_bases)) fixed_column_bases <- rep(NA, numSera(map))
  if (is.null(titer_weights)) titer_weights <- matrix(1, numAntigens(map), numSera(map))

  # Warn about overwriting previous optimizations
  if (numOptimizations(map) > 0) {
    vmessage(verbose, "Discarding previous optimization runs.")
  }
  map <- removeOptimizations(map)

  # Get optimizer options
  options <- do.call(RacOptimizer.options, options)
  if (!verbose) options$report_progress <- FALSE

  # Perform the optimization runs
  tstart <- Sys.time()

  # Check for disconnected or underconstrained points
  ag_num_measured <- rowSums(titertypesTable(map) == 1)
  sr_num_measured <- colSums(titertypesTable(map) == 1)

  ag_disconnected <- ag_num_measured < number_of_dimensions
  sr_disconnected <- sr_num_measured < number_of_dimensions

  ag_underconstrained <- ag_num_measured == number_of_dimensions
  sr_underconstrained <- sr_num_measured == number_of_dimensions

  if (sum(ag_disconnected) > 0) warn_disconnected("ANTIGENS", agNames(map)[ag_disconnected], number_of_dimensions)
  if (sum(sr_disconnected) > 0) warn_disconnected("SERA", srNames(map)[sr_disconnected], number_of_dimensions)

  if (sum(ag_underconstrained) > 0) warn_underconstrained("ANTIGENS", agNames(map)[ag_underconstrained], number_of_dimensions)
  if (sum(sr_underconstrained) > 0) warn_underconstrained("SERA", srNames(map)[sr_underconstrained], number_of_dimensions)

  # Check for unconnected sets of points
  if (!options$ignore_disconnected && mapDisconnected(map)) {
    stop(singleline(
    "Map contains disconnected points (points that are not connected through
     any path of detectable titers so cannot be coordinated relative to each other).
     To optimize anyway, rerun with 'options = list(ignore_disconnected = TRUE)'."
    ), call. = F)
  }

  map <- ac_optimize_map(
    map = map,
    num_dims = number_of_dimensions,
    num_optimizations = number_of_optimizations,
    min_col_basis = minimum_column_basis,
    fixed_col_bases = fixed_column_bases,
    ag_reactivity_adjustments = agReactivityAdjustments(map),
    titer_weights = titer_weights,
    options = options
  )

  # Set disconnected point coordinates to NaN
  for (n in seq_len(numOptimizations(map))) {
    opt_stress <- optStress(map, n)
    agBaseCoords(map, n)[ag_disconnected,] <- NaN
    srBaseCoords(map, n)[sr_disconnected,] <- NaN
    optStress(map, n) <- opt_stress
  }

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

  # Check procrustes of the top 2 runs to see if there is much difference between them
  if (check_convergence && numOptimizations(map) > 1) {

    pcmap <- map
    agNames(pcmap) <- paste("AG", seq_len(numAntigens(pcmap)))
    srNames(pcmap) <- paste("SR", seq_len(numSera(pcmap)))

    procrustes_data <- procrustesData(pcmap, pcmap, comparison_optimization_number = 2)
    procrustes_dists <- c(procrustes_data$ag_dists, procrustes_data$sr_dists)

    if (max(procrustes_dists, na.rm = T) > 0.5) {
      warning(sprintf(
        singleline("There is some variation (%s AU for one point) in the top runs,
                   this may be an indication that more optimization runs could help
                   achieve a better optimum. If this still fails to help see
                   ?unstableMaps for further possible causes.")
      , round(max(procrustes_dists, na.rm = T), 2)))
    }

  }

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
#' @param check_convergence Should a basic check for convergence of lowest stress
#'   optimization runs onto a similar solution be performed.
#' @param verbose Should progress messages be reported, see also
#'   `RacOptimizer.options()`
#' @param options List of named optimizer options, see `RacOptimizer.options()`
#' @param ... Further arguments to pass to `acmap()`
#'
#' @returns Returns an acmap object that has optimization run results.
#'
#' @family map optimization functions
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
  check_convergence       = TRUE,
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
    check_convergence = check_convergence,
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
#' @param num_basis Number of memory points to be stored (default 10).
#' @param armijo_constant Controls the accuracy of the line search routine for determining the Armijo condition.
#' @param wolfe Parameter for detecting the Wolfe condition.
#' @param min_gradient_norm Minimum gradient norm required to continue the optimization.
#' @param factr Minimum relative function value decrease to continue the optimization.
#' @param max_line_search_trials The maximum number of trials for the line search (before giving up).
#' @param min_step The minimum step of the line search.
#' @param max_step The maximum step of the line search.
#' @param num_cores The number of cores to run in parallel when running optimizations
#' @param report_progress Should progress be reported
#' @param ignore_disconnected Should the check for disconnected points be skipped
#' @param progress_bar_length Progress bar length when progress is reported
#'
#' @details For more details, for example on "dimensional annealing" see
#'   `vignette("intro-to-antigenic-cartography")`. For details on optimizer
#'   settings like `maxit` see the underlying optimizer documentation at
#'   [ensmallen.org](https://ensmallen.org/).
#'
#' @family map optimization functions
#'
#' @returns Returns a named list of optimizer options
#' @export
#'
RacOptimizer.options <- function(
  dim_annealing = FALSE,
  method = "L-BFGS",
  maxit = 1000,
  num_basis = 10,
  armijo_constant = 1e-4,
  wolfe = 0.9,
  min_gradient_norm = 1e-6,
  factr = 1e-15,
  max_line_search_trials = 50,
  min_step = 1e-20,
  max_step = 1e20,
  num_cores = getOption("RacOptimizer.num_cores"),
  report_progress = NULL,
  ignore_disconnected = FALSE,
  progress_bar_length = options()$width
) {

  # Check input
  check.logical(dim_annealing)
  check.logical(ignore_disconnected)
  check.string(method)
  check.numeric(maxit)
  check.numeric(progress_bar_length)
  if (!is.null(report_progress)) check.logical(report_progress)
  if (!is.null(num_cores)) check.integer(num_cores)

  # Set default number of cores to 2
  if (is.null(num_cores)) {
    rlang::warn(
      message = "Number of parallel cores to use for optimization was not specified, so using default of 2. You can set the number of cores to use explicitly by passing it as an argument to the optimizer function, or globally by setting the option 'RacOptimizer.num_cores', e.g. by adding the line `options(RacOptimizer.num_cores = parallel::detectCores())` to the top of your script.",
      .frequency = "regularly",
      .frequency_id = "RacOptimizer_num_cores_check"
    )
    num_cores <- 2
  }

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
    num_basis = num_basis,
    armijo_constant = armijo_constant,
    wolfe = wolfe,
    min_gradient_norm = min_gradient_norm,
    factr = factr,
    max_line_search_trials = max_line_search_trials,
    min_step = min_step,
    max_step = max_step,
    num_cores = num_cores,
    ignore_disconnected = ignore_disconnected,
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
#' @param titer_weights An optional matrix of weights to assign each titer when optimizing
#' @param options List of named optimizer options, see `RacOptimizer.options()`
#'
#' @returns Returns an acmap object with the optimization relaxed.
#'
#' @seealso See `optimizeMap()` for performing new optimization runs from random
#'   starting coordinates.
#'
#' @family map optimization functions
#' @export
#'
relaxMap <- function(
  map,
  optimization_number = 1,
  fixed_antigens = FALSE,
  fixed_sera = FALSE,
  titer_weights = NULL,
  options = list()
  ) {

  # Get options
  if (sum(!titerTable(map) %in% c("*", ".")) == 0) stop("Table has no measurable titers")
  options <- do.call(RacOptimizer.options, options)

  # Set default arguments
  if (is.null(titer_weights)) titer_weights <- matrix(1, numAntigens(map), numSera(map))

  # Convert point references to indices
  fixed_antigens <- get_ag_indices(fixed_antigens, map)
  fixed_sera     <- get_sr_indices(fixed_sera, map)

  # Run relaxation
  map$optimizations[[optimization_number]] <- ac_relaxOptimization(
    opt = map$optimizations[[optimization_number]],
    titers = titerTable(map),
    fixed_antigens = fixed_antigens - 1,
    fixed_sera = fixed_sera - 1,
    options = options,
    titer_weights = titer_weights,
    dilution_stepsize = dilutionStepsize(map)
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
#' @returns Returns an updated map object
#'
#' @family map optimization functions
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
    options = options,
    titer_weights = matrix(1, numAntigens(map), numSera(map)),
    dilution_stepsize = dilutionStepsize(map)
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
#' @returns Returns an updated map object
#'
#' @family map optimization functions
#' @export
#'
randomizeCoords <- function(
  map,
  optimization_number = 1,
  table_dist_factor = 2
  ) {

  table_dists <- numeric_min_tabledists(
    tabledists = tableDistances(map, optimization_number = optimization_number),
    dilution_stepsize = dilutionStepsize(map)
  )
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
#' @returns Returns TRUE or FALSE
#' @export
#' @family map diagnostic functions
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
#' @param grid_spacing When doing a grid search of more optimal point positions
#'   the grid spacing to use
#' @param stress_lim The stess difference to use when classifying a point as
#'   "hemisphering" or not
#' @param options A named list of options to pass to `RacOptimizer.options()`
#'
#' @returns Returns a data frame with information on any points that were found
#'   to be hemisphering or trapped.
#' @export
#' @family map diagnostic functions
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
    titertable = titerTable(map),
    grid_spacing = grid_spacing,
    stress_lim = stress_lim,
    options = do.call(RacOptimizer.options, options),
    dilution_stepsize = dilutionStepsize(map)
  )

  # Message if any hemisphering points were found
  pt_diagnostics <- vapply(
    c(agHemisphering(map, optimization_number), srHemisphering(map, optimization_number)),
    function(pt) {
      diagnosis <- unique(vapply(pt, function(x) x$diagnosis, character(1)))
      if (length(diagnosis) == 0) diagnosis <- ""
      diagnosis
    },
    character(1)
  )

  # Setup diagnosis table
  if (sum(pt_diagnostics != "") > 0) {
    diagnosis_table <- data.frame(
      name = c(agNames(map), srNames(map)),
      diagnosis = pt_diagnostics
    )
    diagnosis_table <- diagnosis_table[diagnosis_table$diagnosis != "", , drop = F]
    warning(
      sprintf(
        "Hemisphering or trapped points found:\n\n%s\n",
        paste(utils::capture.output(diagnosis_table), collapse = "\n")
      )
    )
  } else {
    message("No hemisphering or trapped points found")
  }

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
#' @returns Returns the acmap object with updated coordinates (if any trapped
#'   points found)
#' @family map optimization functions
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
    titertable = titerTable(map),
    grid_spacing = grid_spacing,
    options = do.call(RacOptimizer.options, options),
    max_iterations = max_iterations,
    dilution_stepsize = dilutionStepsize(map)
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

# Calculate map connectivity
mapConnectivityGraph <- function(map) {

  ags <- seq_len(numAntigens(map))
  srs <- seq_len(numSera(map))

  titertypes <- titertypesTable(map)
  edges <- as.matrix(expand.grid(ags, srs))
  edge_titertypes <- apply(edges, 1, function(x) titertypes[x[1], x[2]])
  edges[,2] <- edges[,2] + numAntigens(map)

  edges <- edges[edge_titertypes == 1, , drop = F]
  igraph::graph_from_edgelist(edges, directed = FALSE)

}

mapConnectivityDistances <- function(map) {

  graph <- mapConnectivityGraph(map)
  igraph::distances(graph)

}

mapDisconnected <- function(map) {

  max(mapConnectivityDistances(map)) == Inf

}

#' @rdname mapCohesion
#' @export
agCohesion <- function(map) {

  graph <- mapConnectivityGraph(map)
  ag_cohesion <- matrix(NA, numAntigens(map), numAntigens(map))
  for (ag1 in seq_len(numAntigens(map))) {
    for (ag2 in seq_len(numAntigens(map))) {
      if (ag1 != ag2) {
        ag_cohesion[ag1, ag2] <- igraph::vertex_connectivity(graph, ag1, ag2)
      }
    }
  }
  ag_cohesion

}

#' @rdname mapCohesion
#' @export
srCohesion <- function(map) {

  graph <- mapConnectivityGraph(map)
  sr_cohesion <- matrix(NA, numSera(map), numSera(map))
  nags <- numAntigens(map)
  for (sr1 in seq_len(numSera(map))) {
    for (sr2 in seq_len(numSera(map))) {
      if (sr1 != sr2) {
        sr_cohesion[sr1, sr2] <- igraph::vertex_connectivity(graph, sr1 + nags, sr2 + nags)
      }
    }
  }
  sr_cohesion

}


#' Check map cohesion
#'
#' Checks the vertex connectivity of points in a map (the minimum number of
#' points needed to remove from the map to eliminate all paths from one point to
#' another point). This is for checking for example if after merging maps you
#' only have a small number of points in common between separate groups of
#' points, leading to a situation where groups of points cannot be robustly
#' positioned relative to each other. If the vertex connectivity is smaller than
#' the number of map dimensions + 1 then this will certainly be occurring and
#' will lead to an unstable map solution. `mapCohesion()` returns the minimum
#' vertex connectivity found between any given points, while `agCohesion()` and
#' `srCohesion()` return the vertex connectivity between each pair of antigens
#' and sera as a table helping to diagnose which antigens and sera are forming
#' separate groups. Note that for these purposes only detectable titers count
#' as connections and non-detectable titers are ignored.
#'
#' @param map An acmap object
#'
#' @returns A scalar real value.
#'
#' @export
#' @family map diagnostic functions
#'
mapCohesion <- function(map) {

  graph <- mapConnectivityGraph(map)
  igraph::vertex_connectivity(graph)

}


#' Notes on unstable maps
#'
#' Tips for exploring maps that are difficult to find a consistent optimal solution for.
#'
#' Maps may be difficult to optimize or unstable for a variety of reasons, a common
#' one with larger maps being simply that it is difficult to find a global optima
#' and so many different local optima are found each time.
#'
#' One approach that can sometimes
#' help is to consider running the optimizer with `options = list(dim_annealing = TRUE)`
#' (see see `vignette("intro-to-antigenic-cartography")` for an explanation of the
#' dimensional annealing approach). However be wary that in our experience, while applying
#' dimensional annealing can sometimes significantly speed up finding a better minima, it
#' can also sometimes be more prone to getting stuck in worse local optima.
#'
#' If there are many missing or non-detectable titers it is also
#' possible that points in map are too poorly connected to find a robust
#' solution, to check this see `mapCohesion()`.
#'
#' @name unstableMaps
#' @family map diagnostic functions
#'
NULL


