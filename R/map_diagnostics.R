
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
  results <- lapply(seq_len(replicates_per_proportion), function(x){
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
  lapply(results, function(result){
    result$test_indices <- result$test_indices + 1
    result
  })

}

