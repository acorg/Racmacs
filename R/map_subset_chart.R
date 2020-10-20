
#' @export
removeAntigens.racchart <- function(map, antigen_indices){

  # Convert antigen references to indices
  antigen_indices <- get_ag_indices(antigen_indices, map)

  # Simply return the map if no antigens to remove
  if(length(antigen_indices) == 0) return(map)

  # Apply the remove_antigens method
  map$chart$remove_antigens(antigen_indices)

  # Remove additional non-acmacs.r antigen attributes
  fn_list <- list_property_function_bindings("antigens")
  for(method in fn_list$method[!fn_list$acmacs.r & fn_list$subsettable]){
    getter <- get(method)
    setter <- get(paste0(method, "<-"))
    map <- setter(map, value = getter(map)[-antigen_indices], .check = FALSE)
  }

  # Return the map
  map

}

#' @export
removeSera.racchart <- function(map, sera_indices){

  # Convert sera references to indices
  sera_indices <- get_sr_indices(sera_indices, map)

  # Simply return the map if no antigens to remove
  if(length(sera_indices) == 0) return(map)

  # Apply the remove_sera method
  map$chart$remove_sera(sera_indices)

  # Remove additional non-acmacs.r serum attributes
  fn_list <- list_property_function_bindings("sera")
  for(method in fn_list$method[!fn_list$acmacs.r & fn_list$subsettable]){
    getter <- get(method)
    setter <- get(paste0(method, "<-"))
    map <- setter(map, value = getter(map)[-sera_indices], .check = FALSE)
  }

  # Return the map
  map

}

