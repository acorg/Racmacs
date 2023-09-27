
## Some utility functions for outputting errors, warnings and messages

# Remove new lines from a multiline string
singleline <- function(x) {
  x <- gsub("\n", "", x)
  x <- gsub(" +", " ", x)
  x
}

# Output an error that refers to a list of strains
strain_list_error <- function(error, strains) {

  stop(
    paste0(
      error, "\n\n'",
      paste(strains, collapse = "'\n'"),
      "'\n"
    ),
    call. = FALSE
  )

}

# Output a warning that refers to a list of strains
strain_list_warning <- function(warning, strains) {

  warning(
    paste0(
      warning, "\n\n'",
      paste(strains, collapse = "'\n'"),
      "'\n"
    ),
    call. = FALSE
  )

}

# Small function to output a message or not depending on a 'verbose' argument
vmessage <- function(verbose, ...) {
  if (verbose) message(...)
}


#' Deprecated functions
#'
#' These functions still work but have been deprecated in favour of another function. Arguments will be passed onto the new function with a warning.
#'
#' @param ... Arguments to pass to the new function
#'
#' @returns Values from the new function
#'
#' @name deprecated_functions
#'
NULL

# Indicate a function is deprecated
deprecated_fn <- function(fn) {
  fn_name <- as.character(match.call())[2]
  function(...) {
    warning(sprintf("This function has been deprecated in favor of %s()", fn_name))
    fn(...)
  }
}

#' @rdname deprecated_functions
#' @export
stressBlobs <- deprecated_fn(triangulationBlobs)
