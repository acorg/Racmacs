
#' @export
removeAntigens.racchart <- function(map, antigen_indices){

  map$chart$remove_antigens(antigen_indices)
  map

}

#' @export
removeSera.racchart <- function(map, sera_indices){

  map$chart$remove_sera(sera_indices)
  map

}

