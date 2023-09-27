
#' Find matching antigens or sera between 2 maps
#'
#' @param map1 The map to match names from.
#' @param map2 The map to match names to.
#'
#' @returns Returns the indices of matching strains in map 2, or NA in the
#'   position of strains not found.
#'
#' @family functions to compare maps
#' @name matchStrains
NULL


#' @rdname matchStrains
#' @export
match_mapAntigens <- function(
  map1,
  map2
) {

  # Convert indices
  indices <- ac_match_map_ags(map1, map2)
  indices[indices < 0] <- NA
  as.vector(indices + 1)

}


#' @rdname matchStrains
#' @export
match_mapSera <- function(
  map1,
  map2
) {

  # Convert indices
  indices <- ac_match_map_sr(map1, map2)
  indices[indices < 0] <- NA
  as.vector(indices + 1)

}
