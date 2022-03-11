
# Some utility functions to check inputs are of the right type, for many of the
# underlying C++ functions, they will stop with an error and the bomb in an
# Rstudio session if the wrong types are supplied so these checks are especially
# important in those cases
is.wholenumber <- function(x, tol = .Machine$double.eps^0.5) {
  sum(!abs(x - round(x)) < tol) == 0
}

check.acmap <- function(x) {
  if (!inherits(x, "acmap")) {
    stop("Input must be an acmap object", call. = FALSE)
  }
}

check.string  <- function(x) {
  if (length(x) > 1 || !is.character(x)) {
    stop("Input must be a single string", call. = FALSE)
  }
  x
}

check.numeric <- function(x) {
  if (length(x) > 1 || !is.numeric(x)) {
    stop("Input must be a single number", call. = FALSE)
  }
  x
}

check.integer <- function(x) {
  if (length(x) > 1 || !is.wholenumber(x)) {
    stop("Input must be a single integer", call. = FALSE)
  }
  x
}

check.numericmatrix <- function(x) {
  if (!is.matrix(x) || !is.numeric(x)) {
    stop("Input must be a numeric matrix", call. = FALSE)
  }
  x
}

check.numericvector <- function(x) {
  if (sum(!is.na(x)) == 0) mode(x) <- "numeric"
  if (!is.vector(x) || !is.numeric(x)) {
    stop("Input must be a numeric vector", call. = FALSE)
  }
  x
}

check.integerlist <- function(x) {
  if (!is.list(x)) {
    stop("Input must be a list of numeric vectors", call. = FALSE)
  }
  for (n in seq_along(x)) {
    if (length(x[[n]]) == 0) x[[n]] <- integer(0)
    if (!is.vector(x[[n]]) || !is.wholenumber(x[[n]])) {
      stop("Input must be a list of numeric vectors", call. = FALSE)
    }
    x[[n]] <- as.integer(x[[n]])
  }
  x
}

check.logical <- function(x) {
  if (length(x) > 1 || !is.logical(x)) {
    stop("Input must be a logical vector of length one", call. = FALSE)
  }
  x
}

check.logicalvector <- function(x) {
  if (!is.vector(x) || !is.logical(x)) {
    stop("Input must be a logical vector", call. = FALSE)
  }
  x
}

check.charactervector <- function(x) {
  if (!is.vector(x) || !is.character(x)) {
    stop("Input must be a character vector", call. = FALSE)
  }
  x
}

check.charactermatrix <- function(x) {
  if (!is.matrix(x) || !is.character(x)) {
    stop("Input must be a numeric matrix", call. = FALSE)
  }
  x
}

check.dimensions <- function(x, map) {
  if (nrow(x) != numAntigens(map) || ncol(x) != numSera(map)) {
    stop(
      sprintf(
        "Dimensions of input [%s,%s] does not match dimensions of the map in terms of number of antigens and sera [%s,%s]",
        nrow(x), ncol(x), numAntigens(map), numSera(map)
      ),
      call. = FALSE
    )
  }
}

check.validtiters <- function(titers) {

  x <- titers
  unmeasured <- x == "*" | x == "."
  lessthans  <- substr(x, 1, 1) == "<"
  morethans  <- substr(x, 1, 1) == ">"
  x[unmeasured] <- "10"
  x[lessthans | morethans] <- substr(
    x[lessthans | morethans],
    2, nchar(x[lessthans | morethans])
  )
  x <- suppressWarnings(as.numeric(x))
  invalid_titers <- is.na(x)

  if (sum(invalid_titers) > 0) {
    stop(
      sprintf(
        "Invalid titers: '%s'",
        paste(unique(titers[invalid_titers]), collapse = "', '")
      ),
      call. = FALSE
    )
  }

}

# Check the optimization number is valid
check.optnum <- function(map, optimization_number) {
  if (numOptimizations(map) == 0) {
    stop("Map has no optimization runs", call. = FALSE)
  }
  if (optimization_number > numOptimizations(map)) {
    stop(
      sprintf(
        "Map only has %s optimization runs, but number %s requested",
        numOptimizations(map), optimization_number
      ),
      call. = FALSE
    )
  }
}

# This function formats titers or a titer table, replacing NA values with "*"
format_titers <- function(titers) {
  titers[is.na(titers)] <- "*"
  titers
}

# Helper function to deprecate the 'table' argument
table_arg_deprecated <- function(titer_table, table, ...){

  if (!missing(table)) {
    if (is.null(titer_table)) {
      warning("Argument 'table' is deprecated, please use 'titer_table' instead")
      titer_table <- table
    } else {
      stop("Only one of the arguments 'table' and 'titer_table' should be used")
    }
  }
  titer_table

}

# Helper function for specifying that a "suggested" package is required to run a function
package_required <- function(pkg) {

  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(
      sprintf("Please install package '%s' in order to use this function.", pkg),
      call. = FALSE
    )
  }

}
