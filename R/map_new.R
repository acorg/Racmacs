
#' Generate a new acmap object
#'
#' This function generates a new acmap object, the base object for storing map
#' data in the Racmacs package.
#'
#' @param ag_names Antigen names
#' @param sr_names Sera names
#' @param titer_table Table of titer data
#'
#' @return Returns the new acmap object
#'
#' @md
#' @details
#' The fundamental unit of the Racmacs package is the `acmap` object, short for
#' Antigenic Cartography MAP. This object contains all the information about an
#' antigenic map. You can read in a new acmap object from a file with the
#' function \code{\link{read.acmap}} and create a new acmap object within an R session
#' using the `acmap` function.
#'
#' @example examples/example_make_map_from_scratch.R
#'
#' @export
#'
#' @family {functions for working with map data}
#' @seealso See \code{\link{optimizeMap}} for generating new optimizations
#'   estimating antigen similarity from the acmap titer data.
#'
acmap <- function(
  ag_names = NULL,
  sr_names = NULL,
  titer_table = NULL
){

  # Infer the number of antigens and sera
  num_antigens <- NULL
  num_sera     <- NULL
  if(!is.null(ag_names)) num_antigens <- length(ag_names)
  if(!is.null(sr_names)) num_sera     <- length(ag_names)
  if(!is.null(titer_table)){
    num_antigens <- nrow(titer_table)
    num_sera     <- ncol(titer_table)
  }

  # Generate a new racmap object
  map <- acmap.new(
    num_antigens = num_points$num_antigens,
    num_sera     = num_points$num_sera
  )

  # Populate the map
  if(!is.null(ag_names))    agNames(map)    <- ag_names
  if(!is.null(sr_names))    srNames(map)    <- sr_names
  if(!is.null(titer_table)) titerTable(map) <- titer_table

  # Return the new map
  map

}


# Generate a new, empty racmap object
acmap.new <- function(
  num_antigens,
  num_sera
  ){

  # Setup racmap object which is fundementally a list
  map <- list()
  class(map) <- c("racmap", "rac", "list")

  # Setup antigen and serum records
  map$antigens <- lapply(seq_len(num_antigens), function(x){
    list(name = paste("ANTIGEN", x))
  })
  map$sera <- lapply(seq_len(num_sera), function(x){
    list(name = paste("SERA", x))
  })

  # Setup the titer table
  titerTable(map) <- matrix("*", num_antigens, num_sera)

  map

}


