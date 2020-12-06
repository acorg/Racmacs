
#' Perform dimension testing on a map object
#'
#' Take a map object and perform cross-validation, seeing how well titers are
#' predicted when they are excluded from the map.
#'
#' @param map The acmap data object
#' @param dimensions_to_test A numeric vector of dimensions to be tested
#' @param test_proportion The proportion of data to be used as the test set for each test run
#' @param minimum_column_basis The minimum column basis to use
#' @param column_bases_from_master Should column bases be calculated based on
#'   the full data set? If false, they will be recalculated based on the
#'   training set used for each run.
#' @param number_of_optimizations The number of optimizations to perform when creating each map for the dimension test
#' @param replicates_per_proportion The number of random replicates to do per missing proportion tested
#' @param storage_directory Optionally the path to a directory where all the maps made in the dimension test will be saved
#'
#' @return Returns a table of results, including the dimensions tested and the standard deviation of predicted vs residual error.
#' @export
#'
#' @family {map diagnostic functions}
#'
dimensionTestMap <- function(
  map,
  dimensions_to_test        = 1:5,
  test_proportion           = 0.1,
  minimum_column_basis      = "none",
  column_bases_from_master  = TRUE,
  number_of_optimizations   = 1000,
  replicates_per_proportion = 100,
  method = "L-BFGS-B",
  maxit = 1000,
  dim_annealing = FALSE
  ){

  # Get results
  results <- plapply(seq_len(replicates_per_proportion), function(x){
    ac_dimension_test_map(
      titer_table                  = titerTable(map),
      dimensions_to_test           = dimensions_to_test,
      test_proportion              = test_proportion,
      minimum_column_basis         = minimum_column_basis,
      column_bases_from_full_table = column_bases_from_master,
      num_optimizations            = number_of_optimizations,
      method                       = method,
      maxit                        = maxit,
      dim_annealing                = dim_annealing
    )
  })

  # Correct indices of test results to base 1
  results <- lapply(results, function(result){
    result$test_indices <- result$test_indices + 1
    result
  })

  # Add titer info and return the result
  output <- list(
    titers = titerTable(map),
    results = results
  )
  class(output) <- c("ac_dimtest", class(output))
  output

}

#' @export
summary.ac_dimtest <- function(
  dimtest
){

  # Get actual log titers
  measured_logtiters <- log_titers(dimtest$titers)
  titer_types        <- titer_types_int(dimtest$titers)
  results            <- dimtest$results
  dims_tested        <- as.vector(results[[1]]$dim)
  num_test_runs      <- length(results)
  num_tested         <- length(results[[1]]$test_indices)

  # Get a matrix of log titers for each run
  logtiters_per_run <- matrix(NA, num_test_runs, num_tested)
  for(run in seq_len(num_test_runs)){
    logtiters_per_run[run,] <- measured_logtiters[results[[run]]$test_indices]
  }

  # Get a matrix of titer types for each run
  titertypes_per_run <- matrix(NA, num_test_runs, num_tested)
  for(run in seq_len(num_test_runs)){
    titertypes_per_run[run,] <- titer_types[results[[run]]$test_indices]
  }

  # Get summary statistics for each dimension
  mean_rmse_detectable    <- rep(NA, length(dims_tested))
  var_rmse_detectable     <- rep(NA, length(dims_tested))
  mean_rmse_nondetectable <- rep(NA, length(dims_tested))
  var_rmse_nondetectable  <- rep(NA, length(dims_tested))

  for(x in seq_along(dims_tested)){

    # Get a matrix of predicted log titers for each run
    predictions_per_run <- matrix(NA, num_test_runs, num_tested)
    for(run in seq_len(num_test_runs)){
      predictions_per_run[run,] <- results[[run]]$predictions[[x]]
    }

    # Work out the summary
    predictions_detectable_per_run <- predictions_per_run
    predictions_detectable_per_run[titertypes_per_run == 2] <- NA

    predictions_nondetectable_per_run <- predictions_per_run
    predictions_nondetectable_per_run[titertypes_per_run != 2] <- NA

    predictions_detectable_rmses <- apply(predictions_detectable_per_run, 1, function(x){
      sqrt(mean(x^2, na.rm = T))
    })
    predictions_nondetectable_rmses <- apply(predictions_nondetectable_per_run, 1, function(x){
      sqrt(mean(x^2, na.rm = T))
    })

    # Store the results
    mean_rmse_detectable[x]    <- mean(predictions_detectable_rmses, na.rm = T)
    var_rmse_detectable[x]     <- var(predictions_detectable_rmses, na.rm = T)
    mean_rmse_nondetectable[x] <- mean(predictions_nondetectable_rmses, na.rm = T)
    var_rmse_nondetectable[x]  <- var(predictions_nondetectable_rmses, na.rm = T)


  }

  data.frame(
    dimensions = dims_tested,
    mean_rmse_detectable = mean_rmse_detectable,
    var_rmse_detectable = var_rmse_detectable,
    mean_rmse_nondetectable = mean_rmse_nondetectable,
    var_rmse_nondetectable = var_rmse_nondetectable
  )

}







