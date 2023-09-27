
#' Get indices of matching antigens in a map
#'
#' @param antigens The antigens to get indices
#' @param map The acmap object
#' @param warnings Should warnings be output about antigens that were specified
#'   by name but not found in the map
#'
#' @return Returns the indices of matches antigens
#' @noRd
#'
get_ag_indices <- function(
  antigens = TRUE,
  map,
  warnings = TRUE
  ) {

  # Default to all points if null passed
  if (isTRUE(antigens)) return(seq_len(numAntigens(map)))

  # Default to no points if null passed
  if (is.null(antigens)
      || isFALSE(antigens)
      || length(antigens) == 0) return(c())

  # Deal with logical specification
  if (is.logical(antigens)) {
    if (length(antigens) != numAntigens(map)) {
      stop("Antigen indices do not match the number of antigens", call. = FALSE)
    }
    return(which(antigens))
  }

  # Deal with selection by indices
  if (is.numeric(antigens)) {
    if ((min(antigens) < 1 || max(antigens) > numAntigens(map))) {
      stop("Antigen indices do not match the number of antigens", call. = FALSE)
    }
    return(antigens)
  }

  ag_names   <- agNames(map)
  ag_matches <- match(antigens, ag_names)
  if (warnings && sum(is.na(ag_matches)) != 0) {
    strain_list_warning(
      "The following antigens were not found in the map and were ignored:",
      antigens[is.na(ag_matches)]
    )
  }

  # Check that antigens were not found more than once
  num_matches <- vapply(
    antigens[!is.na(ag_matches)],
    function(ag) sum(ag %in% ag_names),
    numeric(1)
  )
  multimatched_ags <- num_matches != 1
  if (sum(multimatched_ags) != 0) {
    strain_list_error(
      "The following antigens were found multiple times:",
      antigens[multimatched_ags]
    )
  }

  ag_matches

}


#' Get indices of matching sera in a map
#'
#' @param sera The sera to get indices
#' @param map The acmap object
#' @param warnings Should warnings be output about sera that were specified by
#'   name but not found in the map
#'
#' @return Returns the indices of matches sera
#' @noRd
#'
get_sr_indices <- function(
  sera = TRUE,
  map,
  warnings = TRUE
  ) {

  # Default to all sera if null passed
  if (isTRUE(sera)) return(seq_len(numSera(map)))

  # Default to no points if null passed
  if (is.null(sera) || isFALSE(sera) || length(sera) == 0) return(c())

  # Deal with logical specification
  if (is.logical(sera)) {
    if (length(sera) != numSera(map)) {
      stop("Sera indices do not match the number of sera", call. = FALSE)
    }
    return(which(sera))
  }

  # Deal with selection by indices
  if (is.numeric(sera)) {
    if ((min(sera) < 1 || max(sera) > numSera(map))) {
      stop("Sera indices do not match the number of sera", call. = FALSE)
    }
    return(sera)
  }

  sr_names   <- srNames(map)
  sr_matches <- match(sera, sr_names)
  if (warnings && sum(is.na(sr_matches)) > 0) {
    strain_list_warning(
      "The following sera were not found in the map and were ignored:",
      sera[is.na(sr_matches)]
    )
  }

  # Check that sera were not found more than once
  num_matches <- vapply(
    sera[!is.na(sr_matches)],
    function(sr) sum(sr %in% sr_names),
    numeric(1)
  )
  multimatched_sr <- num_matches != 1
  if (sum(multimatched_sr) != 0) {
    strain_list_error(
      "The following sera were found multiple times:",
      sera[multimatched_sr]
    )
  }

  sr_matches

}


#' Subset an antigenic map
#'
#' Subset an antigenic map to contain only specified antigens and sera
#'
#' @param map The antigenic map object
#' @param antigens Antigens to keep, defaults to all.
#' @param sera Sera to keep, defaults to all.
#'
#' @return Returns a new antigenic map containing only match antigens and sera
#' @export
#' @family functions for working with map data
#'
subsetMap <- function(
  map,
  antigens = TRUE,
  sera     = TRUE
  ) {

  # Match by antigen and sera name if character vectors are specified
  antigens <- stats::na.omit(get_ag_indices(antigens, map))
  sera     <- stats::na.omit(get_sr_indices(sera, map))

  # Check you are still left with some antigens or sera
  if (length(antigens) == 0) stop("You cannot remove all antigens from a map", call. = FALSE)
  if (length(sera) == 0)     stop("You cannot remove all sera from a map", call. = FALSE)

  # Subset the map
  map <- ac_subset_map(
    map,
    antigens - 1,
    sera - 1
  )

  # Return the subsetted map
  map

}


subsetAntigens <- function(
  map,
  antigens = TRUE
  ) {

  # Match by antigen and sera name if character vectors are specified
  antigens <- stats::na.omit(get_ag_indices(antigens, map))

  # Subset the map
  map <- ac_subset_map(
    map,
    antigens - 1,
    seq_len(numSera(map)) - 1
  )

  # Return the subsetted map
  map

}


subsetSera <- function(
  map,
  sera = TRUE
) {

  # Match by antigen and sera name if character vectors are specified
  sera <- stats::na.omit(get_sr_indices(sera, map))

  # Subset the map
  map <- ac_subset_map(
    map,
    seq_len(numAntigens(map)) - 1,
    sera - 1
  )

  # Return the subsetted map
  map

}


#' Order antigens and sera
#'
#' Functions to change the order of antigens and sera in a map
#'
#' @param map The map data object
#' @param order The new order of points
#'
#' @returns An acmap object with points reordered
#'
#' @name orderPoints
#' @family functions for working with map data
#'

#' @export
#' @rdname orderPoints
orderAntigens <- function(map, order) {
  subsetAntigens(map, order)
}

#' @export
#' @rdname orderPoints
orderSera <- function(map, order) {
  subsetSera(map, order)
}


#' Remove antigens and sera
#'
#' Functions to remove antigens and sera from a map
#'
#' @param map The map data object
#' @param antigens Antigens to remove (specified by name or index)
#' @param sera Sera to remove (specified by name or index)
#'
#' @returns An acmap object with points removed
#'
#' @name removePoints
#' @family functions for working with map data
#'

#' @export
#' @rdname removePoints
removeAntigens <- function(map, antigens) {
  antigens <- get_ag_indices(antigens, map)
  subsetAntigens(map, which(!seq_len(numAntigens(map)) %in% antigens))
}

#' @export
#' @rdname removePoints
removeSera <- function(map, sera) {
  sera <- get_sr_indices(sera, map)
  subsetSera(map, which(!seq_len(numSera(map)) %in% sera))
}




#' Remove antigens and sera
#'
#' Functions to subset a list of maps to include only antigens, antigen groups, sera
#' or serum groups that are in common between them.
#'
#' @param maps A list of map data objects
#'
#' @name subsetCommonPoints
#' @family functions for working with map data
#'

# Function to subset a list of maps to common antigens
#' @rdname subsetCommonPoints
subsetCommonAgs <- function(maps) {

  map_ags <- lapply(maps, agNames)
  ag_names <- unique(unlist(map_ags))
  ag_names_in_maps <- do.call(cbind, lapply(map_ags, function(ags) ag_names %in% ags))
  common_ags <- ag_names[rowSums(!ag_names_in_maps) == 0]

  lapply(
    maps,
    subsetMap,
    antigens = common_ags
  )

}


#' @rdname subsetCommonPoints
subsetCommonSrGroups <- function(maps) {

  map_sr_groups <- lapply(maps, function(map) levels(srGroups(map)))
  sr_groups <- unique(unlist(map_sr_groups))
  sr_groups_in_maps <- do.call(cbind, lapply(map_sr_groups, function(srgs) sr_groups %in% srgs))
  common_sr_groups <- sr_groups[rowSums(!sr_groups_in_maps) == 0]

  lapply(
    maps,
    function(map) {
      map <- subsetMap(
        map,
        sera = as.character(srGroups(map)) %in% common_sr_groups
      )
      srGroups(map) <- factor(as.character(srGroups(map)), levels = common_sr_groups)
      map
    }
  )

}


