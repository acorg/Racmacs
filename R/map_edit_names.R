
#' Edit antigen names in a mapData object
#'
#' @param map The map data object to be updated
#' @param old_names Old names to be replaced
#' @param new_names Replacement for old names
#' @param warnings Should a warning be issued if old names were not found in the map.
#'
#' @return Returns an updated map data object
#' @export
#' @noRd
#'
edit_agNames <- function(map,
                         old_names,
                         new_names,
                         warnings = TRUE){

  # Check the length of the old and new names are the same
  if(length(old_names) != length(new_names)){
    stop("The lengths of old names and new names must match")
  }

  # Match the names
  ag_indices <- get_ag_indices(old_names, map, warnings)

  # Replace the names
  agNames(map)[ag_indices[!is.na(ag_indices)]] <- new_names[!is.na(ag_indices)]

  # Return the updated map data
  map

}


#' Edit sera names in a mapData object
#'
#' @param map The map data object to be updated
#' @param old_names Old names to be replaced
#' @param new_names Replacement for old names
#' @param warnings Should a warning be issued if old names were not found in the map.
#'
#' @return Returns an updated map data object
#' @export
#' @noRd
#'
edit_srNames <- function(map,
                         old_names,
                         new_names,
                         warnings = TRUE){

  # Check the length of the old and new names are the same
  if(length(old_names) != length(new_names)){
    stop("The lengths of old names and new names must match")
  }

  # Match the names
  sr_indices <- get_sr_indices(old_names, map, warnings)

  # Replace the names
  srNames(map)[sr_indices[!is.na(sr_indices)]] <- new_names[!is.na(sr_indices)]

  # Return the updated map data
  map

}


#' Update the ferret serum names to match antigens
#'
#' @param map The map data object
#' @param dictionary_file The path to the dictionary file you want to use (should be .csv).
#' If not supplied then the default dictionary that comes with Racmacs will be used.
#'
#' @return Returns the updated map data object
#' @noRd
#' @export
#'
update_ferret_seraNames <- function(
  map,
  dictionary_file = NULL
){

  # Read from default dictionary if not supplied
  if(is.null(dictionary_file)){
    dictionary_file <- system.file("extdata/ferret_ag_dictionary.csv", package="Racmacs")
  }

  # Read in csv file
  dictionary <- read.csv(file   = dictionary_file,
                         header = FALSE,
                         stringsAsFactors = FALSE)

  # Update the map file
  edit_srNames(map       = map,
               old_names = dictionary[,1],
               new_names = dictionary[,2],
               warnings  = FALSE)

}





