
# Apply a reactivity adjustment to a titer
reactivity_adjust_titers <- function(titers, adjustment) {

  if (length(adjustment) != 1) stop("Adjustment must be length 1")

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
#' @export
adjustedTiterTable <- function(
  map,
  optimization_number = 1
  ) {

  adjusted_titer_table <- titerTable(map)
  ag_reactivity_adjusts <- agReactivityAdjustments(map, optimization_number)

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
#' @export
adjustedLogTiterTable <- function(
  map,
  optimization_number = 1
) {

  adjusted_titer_table <- logtiterTable(map)
  ag_reactivity_adjusts <- agReactivityAdjustments(map, optimization_number)
  adjusted_titer_table + matrix(
    ag_reactivity_adjusts,
    nrow = numAntigens(map),
    ncol = numSera(map),
    byrow = FALSE
  )

}



