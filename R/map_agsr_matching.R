
#' Find matching antigens or sera between 2 maps
#'
#' @param map1 The names to match to.
#' @param map2 The set of names from which to find matches.
#'
#' @return Returns the indices of matching strains in map 2, or NA in the position of strains not found.
#' @name matchStrains
NULL


#' @rdname matchStrains
#' @export
match_mapAntigens <- function(
  map1,
  map2
){

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
){

  # Convert indices
  indices <- ac_match_map_sr(map1, map2)
  indices[indices < 0] <- NA
  as.vector(indices + 1)

}




