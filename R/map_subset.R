
#' Get indices of matching antigens in a map
#'
#' @param antigens The antigens to get indices
#' @param map The acmap object
#' @param warnings Should warnings be output about antigens that were specified by name but not found in the map
#'
#' @return Returns the indices of matches antigens
#' @noRd
#'
get_ag_indices <- function(antigens = TRUE, map, warnings = TRUE){

  # Default to all points if null passed
  if(isTRUE(antigens)) return(seq_len(numAntigens(map)))

  # Default to no points if null passed
  if(is.null(antigens) || isFALSE(antigens) || length(antigens) == 0) return(c())

  # Deal with selection by indices
  if(is.numeric(antigens)){
    if((min(antigens) < 1 || max(antigens) > numAntigens(map))){
      stop("Antigen indices do not match the number of antigens", call. = FALSE)
    }
    return(antigens)
  }

  ag_names   <- agNames(map)
  ag_matches <- match(antigens, ag_names)
  if(warnings && sum(is.na(ag_matches)) != 0) {
    strain_list_warning("The following antigens were not found in the map and were ignored:", antigens[is.na(ag_matches)])
  }

  # Check that antigens were not found more than once
  num_matches <- vapply(antigens[!is.na(ag_matches)], function(ag) sum(ag %in% ag_names), numeric(1))
  multimatched_ags <- num_matches != 1
  if(sum(multimatched_ags) != 0){
    strain_list_error("The following antigens were found multiple times:", antigens[multimatched_ags])
  }

  ag_matches

}


#' Get indices of matching sera in a map
#'
#' @param sera The sera to get indices
#' @param map The acmap object
#' @param warnings Should warnings be output about sera that were specified by name but not found in the map
#'
#' @return Returns the indices of matches sera
#' @noRd
#'
get_sr_indices <- function(sera = TRUE, map, warnings = TRUE){

  # Default to all sera if null passed
  if(isTRUE(sera)) return(seq_len(numSera(map)))

  # Default to no points if null passed
  if(is.null(sera) || isFALSE(sera) || length(sera) == 0) return(c())

  # Deal with selection by indices
  if(is.numeric(sera)){
    if((min(sera) < 1 || max(sera) > numSera(map))){
      stop("Sera indices do not match the number of sera", call. = FALSE)
    }
    return(sera)
  }

  sr_names   <- srNames(map)
  sr_matches <- match(sera, sr_names)
  if(warnings && sum(is.na(sr_matches)) > 0) {
    strain_list_warning("The following sera were not found in the map and were ignored:", sera[is.na(sr_matches)])
  }

  # Check that sera were not found more than once
  num_matches <- vapply(sera[!is.na(sr_matches)], function(sr) sum(sr %in% sr_names), numeric(1))
  multimatched_sr <- num_matches != 1
  if(sum(multimatched_sr) != 0){
    strain_list_error("The following sera were found multiple times:", sera[multimatched_sr])
  }

  sr_matches

}


#' Subset an antigenic map
#'
#' Subset an antigenic map to contain only specified antigens and sera
#'
#' @param map The antigenic map object
#' @param antigens Antigens to keep
#' @param sera Sera to keep
#'
#' @return Returns a new antigenic map containing only match antigens and sera
#' @export
#' @family {functions for working with map data}
#'
#' @example examples/example_map_subset.R
#'
subsetMap <- function(map,
                      antigens = TRUE,
                      sera     = TRUE){

  # Match by antigen and sera name if character vectors are specified
  antigens <- na.omit(get_ag_indices(antigens, map))
  sera     <- na.omit(get_sr_indices(sera, map))

  # Clone the map
  map <- cloneMap(map)

  # Subset the map
  map <- removeAntigens(map, which(!seq_len(numAntigens(map)) %in% antigens))
  map <- removeSera(map, which(!seq_len(numSera(map)) %in% sera))

  # Return the subsetted map
  map

}


#' @export
orderAntigens <- function(map, order) UseMethod("orderAntigens", map)

#' @export
orderSera <- function(map, order) UseMethod("orderSera", map)


#' @export
removeAntigens <- function(map, antigens) UseMethod("removeAntigens", map)

#' @export
removeSera <- function(map, sera) UseMethod("removeSera", map)


#' @export
subsetAntigens <- function(map, antigens) UseMethod("subsetAntigens", map)

#' @export
subsetSera <- function(map, sera) UseMethod("subsetSera", map)


