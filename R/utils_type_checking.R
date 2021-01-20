
# Checker functions
check.acmap <- function(x){ if(!inherits(x, "acmap")) stop("Input must be an acmap object", call. = FALSE) }
check.string  <- function(x){ if(length(x) > 1 || !is.character(x)) stop("Input must be a single string", call. = FALSE) }
check.numeric <- function(x){ if(length(x) > 1 || !is.numeric(x))   stop("Input must be a single number", call. = FALSE) }
check.numericmatrix <- function(x){ if(!is.matrix(x) || !is.numeric(x)) stop("Input must be a numeric matrix", call. = FALSE) }
check.numericvector <- function(x){ if(!is.vector(x) || !is.numeric(x)) stop("Input must be a numeric vector", call. = FALSE) }
check.logical <- function(x){ if(length(x) > 1 || !is.logical(x)) stop("Input must be a logical vector of length one", call. = FALSE) }
check.logicalvector <- function(x){ if(!is.vector(x) || !is.logical(x)) stop("Input must be a logical vector", call. = FALSE) }
check.charactervector <- function(x){ if(!is.vector(x) || !is.character(x)) stop("Input must be a character vector", call. = FALSE) }
