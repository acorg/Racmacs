


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
#'
#' @return Returns a table of results, including the dimensions tested and the standard deviation of predicted vs residual error.
#' @export
#'
#' @family functions to test an acmap
#'
dimensionTestMap <- function(map,
                             dimensions_to_test       = 1:5,
                             test_proportion          = 0.1,
                             minimum_column_basis     = "none",
                             column_bases_from_master = TRUE){

  acmacs.r::acmacs.map_resolution_test(map$chart,
                                       number_of_dimensions     = dimensions_to_test,
                                       proportions_to_dont_care = test_proportion,
                                       minimum_column_basis     = minimum_column_basis,
                                       column_bases_from_master = column_bases_from_master,
                                       relax_from_full_table    = FALSE)

}



