
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
  map2,
  passage_matching = "ignore",
  warnings = TRUE
){

  # Stop if passage matching is not ignored
  if(passage_matching != "ignore"){
    stop("Passage matching is not yet supported.")
  }

  get_ag_indices(agNames(map1), map2, warnings)

}


#' @rdname matchStrains
#' @export
match_mapSera <- function(
  map1,
  map2,
  passage_matching = "ignore",
  warnings = TRUE
){

  # Stop if passage matching is not ignored
  if(passage_matching != "ignore"){
    stop("Passage matching is not yet supported.")
  }

  get_sr_indices(srNames(map1), map2, warnings)

}




