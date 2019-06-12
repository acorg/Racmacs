
#' Printing racmap objects
#'
#' Print information about a racmap object.
#'
#' @param racmap The map object
#' @export
#'
#' @examples
#' # Print subset of information about a map
#' print(h3map2004)
#'
#' # Print all information about a map
#' print(h3map2004, all = TRUE)
#'
print.rac <- function(map, all = FALSE){

  # Convert to the racmap list format
  if(class(map)[1] == "racchart") map <- as.list(map)

  # Print as a list
  class(map) <- "list"

  # Remove some attributes if not everything is to be printed
  if(!all){

    # Print only a summary of optimizations
    if(!is.null(map$optimizations)){
      class(map$optimizations) <- "racoptimizations"
    }

    # Work out which attributes not to print
    null_attributes <- vapply(map, is.null, logical(1))
    map <- map[!null_attributes]

    # Do not print some attributes
    unprinted_attributes <- c(
      "ag_full_name",
      "ag_abbreviated_name",
      "sr_full_name",
      "sr_abbreviated_name",
      "sr_drawing_order",
      "ag_drawing_order",
      "ag_rotation",
      "sr_rotation",
      "ag_aspect",
      "sr_aspect",
      "transformation"
    )

    # Only print optimizations if there is more than one
    if(length(map$optimizations) <= 1) unprinted_attributes <- c(unprinted_attributes, c("optimization", "optimizations"))

    # Do not print some attributes if they are just defaults
    if(is.null(map$ag_reference) || sum(map$ag_reference) == 0)                   unprinted_attributes <- c(unprinted_attributes, "ag_reference")
    if(is.null(map$ag_shown) || sum(!map$ag_shown) == 0)                          unprinted_attributes <- c(unprinted_attributes, "ag_shown")
    if(is.null(map$sr_shown) || sum(!map$sr_shown) == 0)                          unprinted_attributes <- c(unprinted_attributes, "sr_shown")
    if(is.null(map$ag_shape) || sum(map$ag_shape != "CIRCLE") == 0)               unprinted_attributes <- c(unprinted_attributes, "ag_shape")
    if(is.null(map$sr_shape) || sum(map$sr_shape != "BOX") == 0)                  unprinted_attributes <- c(unprinted_attributes, "sr_shape")
    if(is.null(map$sr_shape) || sum(map$sr_shape != "BOX") == 0)                  unprinted_attributes <- c(unprinted_attributes, "sr_shape")
    if(is.null(map$sr_outline_width) || sum(map$sr_outline_width != 1) == 0)      unprinted_attributes <- c(unprinted_attributes, "sr_outline_width")
    if(is.null(map$ag_outline_width) || sum(map$ag_outline_width != 1) == 0)      unprinted_attributes <- c(unprinted_attributes, "ag_outline_width")
    if(is.null(map$sr_cols_outline) || sum(map$sr_cols_outline != "black") == 0)  unprinted_attributes <- c(unprinted_attributes, "sr_cols_outline")
    if(is.null(map$ag_cols_outline) || sum(map$ag_cols_outline != "black") == 0)  unprinted_attributes <- c(unprinted_attributes, "ag_cols_outline")

    # Remove the unprinted attributes
    map <- map[!names(map) %in% unprinted_attributes]

  }

  # Print the map
  print(map)

}


# Small method for summarising optimizations
print.racoptimizations <- function(optimizations){

  num_optimizations <- length(optimizations)
  if(num_optimizations == 1) cat("A list of 1 optimization\n", sep = "")
  else                     cat("A list of ", length(optimizations), " optimizations\n", sep = "")

}



#' View objects interactively
#'
#' Generic function for viewing objects interactively.
#'
#' @param x The object
#' @param ... Objects to pass to the method
#'
#' @export
#'
view <- function (x, ...) {
  UseMethod("view", x)
}

#' The default viewing function
#'
#' Visualises an object using plot.
#'
#' @param x The object.
#' @param ... Arguments to pass to \code{\link{plot}}.
#'
#' @export
#'
view.default <- function(x,
                         ...){

  plot(x)

}



#' Viewing racmap objects
#'
#' View a racmap object in the interactive viewer.
#'
#' @param racmap The racmap object
#' @param ... Arguments to be passed to \code{\link{view_map}}
#'
#' @export
#'
view.rac <- function(map,
                     ...){

  view_map(map, ...)

}



