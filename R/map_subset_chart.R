
#' @export
removeAntigens.racchart <- function(map, antigen_indices){

  antigen_indices <- get_ag_indices(antigen_indices, map)
  if(length(antigen_indices) == 0) return(map)
  map$chart$remove_antigens(antigen_indices)
  map

}

#' @export
removeSera.racchart <- function(map, sera_indices){

  sera_indices <- get_sr_indices(sera_indices, map)
  if(length(sera_indices) == 0) return(map)
  map$chart$remove_sera(sera_indices)
  map

}

