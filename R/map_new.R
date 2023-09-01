
#' Generate a new acmap object
#'
#' This function generates a new acmap object, the base object for storing map
#' data in the Racmacs package.
#'
#' @param ag_names Antigen names
#' @param sr_names Sera names
#' @param titer_table Table of titer data
#' @param ag_coords Antigenic coordinates for an optimization run record
#'   (optional)
#' @param sr_coords Sera coordinates for an optimization run record (optional)
#' @param check_duplicates Issue a warning if duplicate antigen or sera names
#'   are found
#' @param ... Further arguments passed to `addOptimization()`
#'
#' @returns Returns the new acmap object
#'
#' @details The fundamental unit of the Racmacs package is the `acmap` object,
#'   short for Antigenic Cartography MAP. This object contains all the
#'   information about an antigenic map. You can read in a new acmap object from
#'   a file with the function `read.acmap()` and create a new acmap object
#'   within an R session using the `acmap()` function.
#'
#' @family functions for working with map data
#' @seealso See `optimizeMap()` for generating new optimizations estimating
#'   antigen similarity from the acmap titer data.
#'
#' @export
#'
acmap <- function(
  ag_names = NULL,
  sr_names = NULL,
  titer_table = NULL,
  ag_coords = NULL,
  sr_coords = NULL,
  check_duplicates = TRUE,
  ...
) {

  # Check input
  ellipsis::check_dots_used()
  titer_table <- table_arg_deprecated(titer_table, ...)

  # Infer the number of antigens and sera
  num_antigens <- NULL
  num_sera     <- NULL
  if (!is.null(ag_names)) num_antigens <- length(ag_names)
  if (!is.null(sr_names)) num_sera     <- length(sr_names)
  if (!is.null(titer_table)) {
    num_antigens <- nrow(titer_table)
    num_sera     <- ncol(titer_table)
  }
  if (is.null(num_antigens)) num_antigens <- nrow(ag_coords)
  if (is.null(num_sera))     num_sera     <- nrow(sr_coords)
  if (is.null(num_antigens)) stop("Could not infer number of antigens")
  if (is.null(num_sera))     stop("Could not infer number of sera")

  # Generate a new racmap object
  map <- acmap.new(
    num_antigens = num_antigens,
    num_sera     = num_sera
  )

  # Populate the map
  if (!is.null(ag_names)) {
    agNames(map) <- ag_names
  } else if (!is.null(rownames(titer_table))) {
    agNames(map) <- rownames(titer_table)
  }

  if (!is.null(sr_names)) {
    srNames(map) <- sr_names
  } else if (!is.null(colnames(titer_table))) {
    srNames(map) <- colnames(titer_table)
  }

  if (!is.null(titer_table)) titerTable(map) <- titer_table

  if (!is.null(ag_coords) || !is.null(sr_coords)) {
    if (is.null(ag_coords) || is.null(sr_coords)) {
      stop("You must specify both antigen and serum coordinates")
    } else {
      map <- addOptimization(
        map,
        ag_coords = ag_coords,
        sr_coords = sr_coords,
        ...
      )
    }
  }

  # Check for duplicate names
  if (check_duplicates) {
    if (sum(duplicated(agNames(map))) > 0) warning("Map contains duplicate antigen names")
    if (sum(duplicated(srNames(map))) > 0) warning("Map contains duplicate sera names")
  }

  # Return the new map
  map

}

##
# Generate a new, empty racmap object
##
acmap.new <- function(
  num_antigens,
  num_sera
  ) {

  # Setup racmap object which is fundementally a list
  map <- list()
  class(map) <- c("acmap", "list")

  # Setup antigen and serum records
  map$antigens <- lapply(seq_len(num_antigens), function(x) {
    ac_new_antigen(paste("ANTIGEN", x))
  })

  map$sera <- lapply(seq_len(num_sera), function(x) {
    ac_new_serum(paste("SERUM", x))
  })

  # Setup the titer table
  titerTable(map) <- matrix("*", num_antigens, num_sera)

  map

}
