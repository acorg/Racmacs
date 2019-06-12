
#' @export
removeAntigens.racmap <- function(map, antigen_indices){

  property_bindings <- list_property_function_bindings()
  property_bindings <- property_bindings[substr(property_bindings$property, 1, 3) == "ag_",,drop=F]

  # Deal with HI table
  map$table <- map$table[-antigen_indices,,drop=FALSE]

  # Update antigen properties
  for(x in seq_len(nrow(property_bindings))){
    property <- property_bindings$property[x]
    format   <- property_bindings$format[x]
    if(!is.null(map[[property]])){
      if(format == "matrix") map[[property]] <- map[[property]][-antigen_indices,,drop=FALSE]
      if(format == "vector") map[[property]] <- map[[property]][-antigen_indices]
    }
  }

  # Update optimization properties
  map$optimizations <- lapply(map$optimizations, function(optimization){
    for(x in which(property_bindings$object == "optimization")){
      property <- property_bindings$property[x]
      format   <- property_bindings$format[x]
      if(!is.null(map[[property]])){
        if(format == "matrix") optimization[[property]] <- optimization[[property]][-antigen_indices,,drop=FALSE]
        if(format == "vector") optimization[[property]] <- optimization[[property]][-antigen_indices]
      }
    }
    optimization
  })

  # Return the map
  map

}

#' @export
removeSera.racmap <- function(map, sera_indices){

  property_bindings <- list_property_function_bindings()
  property_bindings <- property_bindings[substr(property_bindings$property, 1, 3) == "sr_",,drop=F]

  # Deal with HI table
  map$table <- map$table[,-sera_indices,drop=FALSE]

  # Deal with colbases
  map$colbases <- map$colbases[-sera_indices]

  # Update antigen properties
  for(x in seq_len(nrow(property_bindings))){
    property <- property_bindings$property[x]
    format   <- property_bindings$format[x]
    if(!is.null(map[[property]])){
      if(format == "matrix") map[[property]] <- map[[property]][-sera_indices,,drop=FALSE]
      if(format == "vector") map[[property]] <- map[[property]][-sera_indices]
    }
  }

  # Update optimization properties
  map$optimizations <- lapply(map$optimizations, function(optimization){

    for(x in which(property_bindings$object == "optimization")){
      property <- property_bindings$property[x]
      format   <- property_bindings$format[x]
      if(!is.null(map[[property]])){
        if(format == "matrix") optimization[[property]] <- optimization[[property]][-sera_indices,,drop=FALSE]
        if(format == "vector") optimization[[property]] <- optimization[[property]][-sera_indices]
      }
    }

    # Deal with colbases
    optimization$colbases <- optimization$colbases[-sera_indices]

    optimization

  })

  # Return the map
  map

}



