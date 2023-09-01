
# Apply a reactivity adjustment to a titer
reactivity_adjust_titers <- function(titers, adjustment) {

  # Check and adjust adjustment length
  if (length(adjustment) != 1 && length(adjustment) != length(titers)) {
    stop("Adjustment must be length 1 or same as titers")
  }
  adjustment <- rep_len(adjustment, length(titers))

  # Apply the adjustment
  titertypes <- titer_types_int(titers)
  numtiters <- numeric_titers(titers)
  numtiters <- 2^(log2(numtiters) + adjustment)
  make_titers(numtiters, titertypes)

}


#' Get the reactivity adjusted titer table
#'
#' Return the titer table plus any antigen reactivity adjustments.
#'
#' @param map An acmap object
#' @param optimization_number The optimization number from which
#'   to take any antigen reactivity adjustments
#'
#' @returns A character matrix of titers.
#'
#' @family map attribute functions
#' @seealso [htmlAdjustedTiterTable()]
#' @export
adjustedTiterTable <- function(
  map,
  optimization_number = 1
  ) {

  adjusted_titer_table <- titerTable(map)
  ag_reactivity_adjusts <- agReactivityAdjustments(map)

  for (n in seq_len(numAntigens(map))) {
    adjusted_titer_table[n, ] <- reactivity_adjust_titers(
      adjusted_titer_table[n, ],
      ag_reactivity_adjusts[n]
    )
  }

  adjusted_titer_table

}


#' Get the reactivity adjusted log titer table
#'
#' Return the log titer table plus any antigen reactivity adjustments.
#'
#' @param map An acmap object
#' @param optimization_number The optimization number from which
#'   to take any antigen reactivity adjustments
#'
#' @returns A numeric matrix of adjusted log titers.
#'
#' @family map attribute functions
#' @export
adjustedLogTiterTable <- function(
  map,
  optimization_number = 1
) {

  adjusted_titer_table <- logtiterTable(map)
  ag_reactivity_adjusts <- agReactivityAdjustments(map)
  adjusted_titer_table + matrix(
    ag_reactivity_adjusts,
    nrow = numAntigens(map),
    ncol = numSera(map),
    byrow = FALSE
  )

}



