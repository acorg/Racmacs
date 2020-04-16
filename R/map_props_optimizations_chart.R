
# Getting point plotspec attributes ----
getProperty_optimization.racchart <- function(map, optimization_number, attribute){

  # Get the optimization
  optimization <- map$chart$projections[[optimization_number]]

  # Get any number of attributes from a group of antigens
  switch(

    # Attribute to match
    EXPR = attribute,

    # Base coordinates for antigens
    agBaseCoords = {
      optimization$layout[seq_len(map$chart$number_of_antigens),,drop=F]
    },

    # Base coordinates for sera
    srBaseCoords = {
      optimization$layout[-seq_len(map$chart$number_of_antigens),,drop=F]
    },

    mapComment = {
      optimization$comment
    },

    mapDimensions = {
      optimization$number_of_dimensions
    },

    minColBasis = {
      if(length(optimization$forced_column_bases) > 1 ||
         !is.na(optimization$forced_column_bases)){
        "fixed"
      } else {
        optimization$minimum_column_basis
      }
    },

    mapTransformation = {
      transform <- unlist(get_optimizationAttribute(map, optimization_number, "transformation"))
      if(length(transform) == 0) return(NULL)
      matrix(
        transform,
        sqrt(length(transform))
      )
    },

    mapTranslation = {
      unlist(get_optimizationAttribute(map, optimization_number, "translation"))
    },

    colBases = {
      map$chart$column_bases(optimization_number)
    },

    # Return an error if no attribute matched
    stop("No matching attribute found for ", attribute, call. = FALSE)

  )

}


# Setting point plotspec attributes ----
setProperty_optimization.racchart <- function(map, optimization_number, attribute, value){

  # Get the optimization
  optimization <- map$chart$projections[[optimization_number]]

  # Get any number of attributes from a group of antigens
  switch(

    # Attribute to match
    EXPR = attribute,

    # Base coordinates for antigens
    agBaseCoords = {
      layout <- optimization$layout
      layout[seq_len(map$chart$number_of_antigens),] <- value
      optimization$layout <- layout
    },

    # Base coordinates for sera
    srBaseCoords = {
      layout <- optimization$layout
      layout[-seq_len(map$chart$number_of_antigens),] <- value
      optimization$layout <- layout
    },

    mapComment = {
      stop("Map comment cannot be set on an acmapp.cpp object")
    },

    mapDimensions = {
      stop("Map dimensions cannot be set")
    },

    minColBasis = {
      stop("Minimum column bases cannot be set on an acmap.cpp object", call. = FALSE)
    },

    mapTransformation = {
      # print(value)
      # print(mapDimensions(map, optimization_number))
      set_optimizationAttribute(map, optimization_number, "transformation", as.vector(value))
    },

    mapTranslation = {
      set_optimizationAttribute(map, optimization_number, "translation", value)
    },

    colBases = {
      for(x in which(!is.na(value))){
        optimization$set_column_basis(x, value[x])
      }
    },

    # Return an error if no attribute matched
    stop("No matching attribute found for ", attribute, call. = FALSE)

  )

  # Return the map
  map

}
