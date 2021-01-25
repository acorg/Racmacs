
# Some utility functions to check inputs are of the right type, for many of the
# underlying C++ functions, they will stop with an error and the bomb in an
# Rstudio session if the wrong types are supplied so these checks are especially
# important in those cases
check.acmap <- function(x) {
  if (!inherits(x, "acmap")) {
    stop("Input must be an acmap object", call. = FALSE)
  }
}

check.string  <- function(x) {
  if (length(x) > 1 || !is.character(x)) {
    stop("Input must be a single string", call. = FALSE)
  }
}

check.numeric <- function(x) {
  if (length(x) > 1 || !is.numeric(x)) {
    stop("Input must be a single number", call. = FALSE)
  }
}

check.numericmatrix <- function(x) {
  if (!is.matrix(x) || !is.numeric(x)) {
    stop("Input must be a numeric matrix", call. = FALSE)
  }
}

check.numericvector <- function(x) {
  if (!is.vector(x) || !is.numeric(x)) {
    stop("Input must be a numeric vector", call. = FALSE)
  }
}

check.logical <- function(x) {
  if (length(x) > 1 || !is.logical(x)) {
    stop("Input must be a logical vector of length one", call. = FALSE)
  }
}

check.logicalvector <- function(x) {
  if (!is.vector(x) || !is.logical(x)) {
    stop("Input must be a logical vector", call. = FALSE)
  }
}

check.charactervector <- function(x) {
  if (!is.vector(x) || !is.character(x)) {
    stop("Input must be a character vector", call. = FALSE)
  }
}

check.charactermatrix <- function(x) {
  if (!is.matrix(x) || !is.character(x)) {
    stop("Input must be a numeric matrix", call. = FALSE)
  }
}

# Check the optimization number is valid
check.optnum <- function(map, optimization_number) {
  if (numOptimizations(map) == 0) {
    stop("Map has no optimization runs yet", call. = FALSE)
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
