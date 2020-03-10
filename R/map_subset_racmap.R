
#' @export
removeAntigens.racmap <- function(map, antigen_indices){

  antigen_indices <- get_ag_indices(antigen_indices, map)
  if(length(antigen_indices) == 0) return(map)
  property_bindings <- list_property_function_bindings()
  property_bindings <- property_bindings[substr(property_bindings$property, 1, 3) == "ag_",,drop=F]

  # Update antigen properties
  for(x in which(property_bindings$object != "optimization")){

    property <- property_bindings$property[x]
    format   <- property_bindings$format[x]
    getter   <- get(property_bindings$method[x])
    setter   <- get(paste0(property_bindings$method[x], "<-"))

    value <- getter(map)
    if(format == "matrix") value_subset <- value[-antigen_indices,,drop=FALSE]
    if(format == "vector") value_subset <- value[-antigen_indices]
    map <- setter(map, value = value_subset, .check = FALSE)

  }

  # Update optimization properties
  for(optimnum in seq_len(numOptimizations(map))){
    for(x in which(property_bindings$object == "optimization")){

      property <- property_bindings$property[x]
      format   <- property_bindings$format[x]
      getter   <- get(property_bindings$method[x])
      setter   <- get(paste0(property_bindings$method[x], "<-"))

      value <- getter(map, optimization_number = optimnum, .name = FALSE)
      if(format == "matrix") value_subset <- value[-antigen_indices,,drop=FALSE]
      if(format == "vector") value_subset <- value[-antigen_indices]
      map <- setter(map, optimization_number = optimnum, value = value_subset, .check = FALSE)

    }
  }

  # Deal with HI table
  titerTableLayers(map) <- lapply(titerTableLayers(map), function(tablelayer){
    tablelayer[-antigen_indices,,drop=FALSE]
  })
  titerTable(map) <- titerTable(map, .name = FALSE)[-antigen_indices,,drop=FALSE]

  # Return the map
  map

}

#' @export
removeSera.racmap <- function(map, sera_indices){

  sera_indices <- get_sr_indices(sera_indices, map)
  if(length(sera_indices) == 0) return(map)

  property_bindings <- list_property_function_bindings()
  property_bindings <- property_bindings[substr(property_bindings$property, 1, 3) == "sr_",,drop=F]

  # Update antigen properties
  for(x in which(property_bindings$object != "optimization")){

    property <- property_bindings$property[x]
    format   <- property_bindings$format[x]
    getter   <- get(property_bindings$method[x])
    setter   <- get(paste0(property_bindings$method[x], "<-"))

    value <- getter(map)
    if(format == "matrix") value_subset <- value[-sera_indices,,drop=FALSE]
    if(format == "vector") value_subset <- value[-sera_indices]
    map <- setter(map, value = value_subset, .check = FALSE)

  }

  # Update optimization properties
  for(optimnum in seq_len(numOptimizations(map))){
    for(x in which(property_bindings$object == "optimization")){

      property <- property_bindings$property[x]
      format   <- property_bindings$format[x]
      getter   <- get(property_bindings$method[x])
      setter   <- get(paste0(property_bindings$method[x], "<-"))

      value <- getter(map, optimization_number = optimnum, .name = FALSE)
      if(format == "matrix") value_subset <- value[-sera_indices,,drop=FALSE]
      if(format == "vector") value_subset <- value[-sera_indices]
      map <- setter(map, optimization_number = optimnum, value = value_subset, .check = FALSE)

    }

    # Deal with colbases
    colBases(map, optimization_number = optimnum, .check = FALSE) <- colBases(map, optimization_number = optimnum)[-sera_indices]

  }

  # Deal with HI table
  titerTableLayers(map) <- lapply(titerTableLayers(map), function(tablelayer){
    tablelayer[,-sera_indices,drop=FALSE]
  })
  titerTableFlat(map) <- titerTableFlat(map)[,-sera_indices,drop=FALSE]

  # Return the map
  map

}



