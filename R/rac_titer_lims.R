
#' Get titer limits
#'
#' Function for getting upper and lower limits of measured titers on the log scale.
#'
#' @param min_titer_possible The maximum possible titer to assume
#' @param max_titer_possible The minimum possible titer to assume
#' @param titers A numeric/character vector or matrix of titer measurements.
#'
#' @return Returns a list of length two with values max_titers and min_titers, giving the
#' numeric vectors of the upper and lower bounds of the titers on the log scale.
#'
#' @details This function assumes that HI measurements were performed in 2-fold dilution
#' steps and converts them to the log scale using the formula:
#' \deqn{a + b}
#' Hence an HI titer of 20, which would convert to 1 via the transformation above, would be
#' assumed to have upper and lower limits of 1.5 and 0.5 respectively.
#'
#' In the case of non-detectable titers, such as <10, the lower bound of the measured value
#' is taken from the parameter \code{min_titer_possible}, defaulting to the value found from
#' a call to \code{get_lndscp_fit_defaults()}. For a greater than value, i.e. >1280, the
#' upper bound of the value is taken from the parameter \code{max_titer_possible}. You can
#' set different defaults by passing them as named arguments to the list, as shown in the
#' examples.
#'
#' @examples
#' # Calculate the titer limits of a set of HI titers
#' titer_lims <- get_titer_lims(titers = c("20", "320", "<10", ">1280"))
#'
#' # Calculate the titer limits assuming non-default upper and lower bounds for non-detectable
#' # and greater-than titers.
#' titer_lims <- get_titer_lims(titers = c("20", "320", "<10", ">1280"),
#'                              fit_opts = list(min_titer_possible = -Inf,
#'                                              max_titer_possible = 14))
#' @noRd
#' @export
calc_titer_lims <- function(titers,
                            min_titer_possible = -Inf,
                            max_titer_possible = Inf){

  # Throw an error if titers is not a matrix or vector
  if(!is.matrix(titers) & !is.vector(titers)){
    stop("Titers must be in the form of a vector or matrix")
  }

  # Convert titers to a vector if necessary
  titer_dims <- dim(titers)
  if(is.matrix(titers)){
    titers <- as.vector(titers)
  }

  # Find less than and greater than titers and convert them to a numeric form
  lessthan_titers <- grepl(x = titers, pattern = "<")
  morethan_titers <- grepl(x = titers, pattern = ">")
  na_titers       <- grepl(x = titers, pattern = "\\*")

  numeric_titers <- titers
  numeric_titers[na_titers] <- NA
  numeric_titers <- as.numeric(gsub("(<|>)","",numeric_titers))

  # Convert titers to the log scale
  log_titers <- log2(numeric_titers/10)
  log_titers[lessthan_titers] <- log_titers[lessthan_titers] - 1
  log_titers[morethan_titers] <- log_titers[morethan_titers] + 1
  max_titers <- log_titers + 0.5
  min_titers <- log_titers - 0.5
  min_titers[lessthan_titers] <- min_titer_possible
  max_titers[morethan_titers] <- max_titer_possible

  if(!is.null(titer_dims)){
    max_titers <- matrix(data = max_titers,
                         nrow = titer_dims[1],
                         ncol = titer_dims[2])
    min_titers <- matrix(data = min_titers,
                         nrow = titer_dims[1],
                         ncol = titer_dims[2])
  }

  list(max_titers = max_titers,
       min_titers = min_titers)

}
