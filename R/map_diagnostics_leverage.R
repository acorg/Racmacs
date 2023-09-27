
#' Calculate point leverage
#'
#' These functions attempt to estimate leverage of each antigen, sera or titer
#' by removing it from the data, relaxing the map, then calculating the rmsd of
#' the procrustes comparison between the original and newly relaxed map. Column
#' bases will be recalculated unless you have specifed them as fixed with
#' `fixedColBases()`.
#'
#' @param map An acmap object
#' @param antigens Antigens to include when calculating the rmsd of the
#'   procrustes (specified by name or index or TRUE/FALSE for all/none)
#' @param sera Sera to include when calculating the rmsd of the procrustes
#'   (specified by name or index or TRUE/FALSE for all/none)
#'
#' @returns Returns a numeric vector of the leverage calculated for each of the
#'   points.
#'
#' @family map diagnostic functions
#' @name ptLeverage
NULL

# For calculating antigen leverage
calc_agLeverage <- function(
  map,
  ag,
  antigens,
  sera
  ) {

  mapi <- removeAntigens(map, ag)
  mapi <- relaxMap(mapi)
  procrustesData(map, mapi)$total_rmsd

}

#' @export
#' @rdname ptLeverage
agLeverage <- function(
  map,
  antigens = TRUE,
  sera = TRUE
  ) {

  # Calculate the leverage
  vapply(
    X = seq_len(numAntigens(map)),
    FUN = calc_agLeverage,
    FUN.VALUE = numeric(1),
    map = map,
    antigens = antigens,
    sera = sera
  )

}

# For calculating sera leverage
calc_srLeverage <- function(
  map,
  sr,
  antigens,
  sera
  ) {

  mapi <- removeSera(map, sr)
  mapi <- relaxMap(mapi)
  procrustesData(map, mapi)$total_rmsd

}

#' @export
#' @rdname ptLeverage
srLeverage <- function(
  map,
  antigens = TRUE,
  sera = TRUE
  ) {

  vapply(
    X = seq_len(numSera(map)),
    FUN = calc_srLeverage,
    FUN.VALUE = numeric(1),
    map = map,
    antigens = antigens,
    sera = sera
  )

}


# For calculating titer leverage
calc_titerLeverage <- function(
  map,
  ag, sr,
  antigens,
  sera
) {

  mapi <- map
  titerTable(mapi)[ag, sr] <- "*"
  mapi <- relaxMap(mapi)
  procrustesData(map, mapi)$total_rmsd

}

#' @export
#' @rdname ptLeverage
titerLeverage <- function(
  map,
  antigens = TRUE,
  sera = TRUE
) {

  # Calculate the titer leverage
  vapply(
    seq_len(numSera(map)),
    function(sr) {
      vapply(
        seq_len(numAntigens(map)),
        function(ag) {
          calc_titerLeverage(
            map = map,
            ag = ag,
            sr = sr,
            antigens = antigens,
            sera = sera
          )
        },
        numeric(1)
      )
    },
    numeric(numAntigens(map))
  )

}
