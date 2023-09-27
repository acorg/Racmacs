
#' Perform dimension testing on a map object
#'
#' Take a map object and perform cross-validation, seeing how well titers are
#' predicted when they are excluded from the map.
#'
#' @param map The acmap data object
#' @param dimensions_to_test A numeric vector of dimensions to be tested
#' @param test_proportion The proportion of data to be used as the test set for
#'   each test run
#' @param minimum_column_basis The minimum column basis to use
#' @param fixed_column_bases A vector of fixed column bases with NA for sera
#'   where the minimum column basis should be applied
#' @param number_of_optimizations The number of optimizations to perform when
#'   creating each map for the dimension test
#' @param replicates_per_dimension The number of tests to perform per dimension
#'   tested
#' @param options Map optimizer options, see `RacOptimizer.options()`
#'
#' @details For each run, the ag-sr titers that were randomly excluded are
#'   predicted according to their relative positions in the map trained without
#'   them. An RMSE is then calculated by comparing predicted titers inferred
#'   from the map on the log scale to the actual log titers. This is done
#'   separately for detectable titers (e.g. 40) and non-detectable titers (e.g.
#'   <10). For non-detectable titers, if the predicted titer is the same or
#'   lower than the log-titer threshold, the error is set to 0.
#'
#' @returns Returns a data frame with the following columns. "dimensions" : the
#'   dimension tested, "mean_rmse_detectable" : mean prediction rmse for
#'   detectable titers across all runs. "var_rmse_detectable" the variance of
#'   the prediction rmse for detectable titers across all runs, useful for
#'   estimating confidence intervals. "mean_rmse_nondetectable" and
#'   "var_rmse_nondetectable" the equivalent for non-detectable titers
#'
#' @export
#'
#' @family map diagnostic functions
#'
dimensionTestMap <- function(
  map,
  dimensions_to_test       = 1:5,
  test_proportion          = 0.1,
  minimum_column_basis     = "none",
  fixed_column_bases       = rep(NA, numSera(map)),
  number_of_optimizations  = 1000,
  replicates_per_dimension = 100,
  options                  = list()
  ) {

  # Perform the dimension test
  result <- runDimensionTestMap(
    map = map,
    dimensions_to_test = dimensions_to_test,
    test_proportion = test_proportion,
    minimum_column_basis = minimum_column_basis,
    fixed_column_bases = fixed_column_bases,
    number_of_optimizations = number_of_optimizations,
    replicates_per_dimension = replicates_per_dimension,
    options = options
  )

  # Summarise the results
  summary_result <- dimtest_summary(result)
  summary_result$replicates <- replicates_per_dimension
  summary_result

}


# Run dimtest result
runDimensionTestMap <- function(
  map,
  dimensions_to_test        = 1:5,
  test_proportion           = 0.1,
  minimum_column_basis      = "none",
  fixed_column_bases        = rep(NA, numSera(map)),
  ag_reactivity_adjustments = rep(0, numAntigens(map)),
  number_of_optimizations   = 1000,
  replicates_per_dimension  = 100,
  options                   = list()
  ) {

  # Set optimizer options
  options <- do.call(RacOptimizer.options, options)

  # Set progress
  message(sprintf(
    "Performing dimension test, %s replicates per dimension",
    replicates_per_dimension
  ))
  progress <- ac_progress_bar(replicates_per_dimension)

  # Get results
  results <- lapply(seq_len(replicates_per_dimension), function(x) {
    result <- ac_dimension_test_map(
      titer_table               = titerTable(map),
      dimensions_to_test        = dimensions_to_test,
      test_proportion           = test_proportion,
      minimum_column_basis      = minimum_column_basis,
      fixed_column_bases        = fixed_column_bases,
      ag_reactivity_adjustments = ag_reactivity_adjustments,
      num_optimizations         = number_of_optimizations,
      options                   = options
    )
    ac_update_progress(progress, x)
    result
  })

  # Correct indices of test results to base 1
  results <- lapply(results, function(result) {
    result$test_indices <- result$test_indices + 1
    result
  })

  # Add titer info and return the result
  list(
    titers = titerTable(map),
    results = results,
    dilution_stepsize = dilutionStepsize(map)
  )

}


# Summarize dimension test results
dimtest_summary <- function(
  object,
  ...
) {

  # Get actual log titers
  measured_logtiters <- log_titers(object$titers, object$dilution_stepsize)
  titer_types        <- titer_types_int(object$titers)
  results            <- object$results
  dims_tested        <- as.vector(results[[1]]$dim)
  num_test_runs      <- length(results)
  num_tested         <- length(results[[1]]$test_indices)

  # Get a matrix of log titers for each run
  logtiters_per_run <- matrix(NA, num_test_runs, num_tested)
  for (run in seq_len(num_test_runs)) {
    logtiters_per_run[run, ] <- measured_logtiters[results[[run]]$test_indices]
  }

  # Get a matrix of titer types for each run
  titertypes_per_run <- matrix(NA, num_test_runs, num_tested)
  for (run in seq_len(num_test_runs)) {
    titertypes_per_run[run, ] <- titer_types[results[[run]]$test_indices]
  }

  # Get summary statistics for each dimension
  mean_rmse_detectable    <- rep(NA, length(dims_tested))
  var_rmse_detectable     <- rep(NA, length(dims_tested))
  mean_rmse_nondetectable <- rep(NA, length(dims_tested))
  var_rmse_nondetectable  <- rep(NA, length(dims_tested))

  for (x in seq_along(dims_tested)) {

    # Get a matrix of predicted log titers for each run
    predictions_per_run <- matrix(NA, num_test_runs, num_tested)
    for (run in seq_len(num_test_runs)) {
      predictions_per_run[run, ] <- results[[run]]$predictions[[x]]
    }

    # Work out the summary
    predictions_detectable_per_run <- predictions_per_run
    predictions_detectable_per_run[titertypes_per_run == 2] <- NA

    predictions_nondetectable_per_run <- predictions_per_run
    predictions_nondetectable_per_run[titertypes_per_run != 2] <- NA

    predictions_detectable_rmses <- apply(
      predictions_detectable_per_run - logtiters_per_run,
      1, function(x) {
        sqrt(mean(x^2, na.rm = T))
      }
    )
    predictions_nondetectable_rmses <- apply(
      predictions_nondetectable_per_run - logtiters_per_run,
      1,
      function(x) {
      sqrt(mean(x^2, na.rm = T))
      }
    )

    # Store the results
    mean_rmse_detectable[x]    <- mean(predictions_detectable_rmses, na.rm = T)
    var_rmse_detectable[x]     <- stats::var(predictions_detectable_rmses, na.rm = T)
    mean_rmse_nondetectable[x] <- mean(predictions_nondetectable_rmses, na.rm = T)
    var_rmse_nondetectable[x]  <- stats::var(predictions_nondetectable_rmses, na.rm = T)

  }

  data.frame(
    dimensions = dims_tested,
    mean_rmse_detectable = mean_rmse_detectable,
    var_rmse_detectable = var_rmse_detectable,
    mean_rmse_nondetectable = mean_rmse_nondetectable,
    var_rmse_nondetectable = var_rmse_nondetectable
  )

}
