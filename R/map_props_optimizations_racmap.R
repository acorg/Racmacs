
# Getting point plotspec attributes ----
getProperty_optimization.racmap <- function(map, optimization_number, attribute){

  # Get any number of attributes from a group of antigens
  switch(

    # Attribute to match
    EXPR = attribute,

    # Base coordinates for antigens
    agBaseCoords = {
      map$optimizations[[optimization_number]][[attribute]]
    },

    # Base coordinates for sera
    srBaseCoords = {
      map$optimizations[[optimization_number]][[attribute]]
    },

    mapComment = {
      map$optimizations[[optimization_number]][[attribute]]
    },

    mapDimensions = {
      map$optimizations[[optimization_number]][[attribute]]
    },

    mapStress = {
      map$optimizations[[optimization_number]][[attribute]]
    },

    minColBasis = {
      if(!is.null(map$optimizations[[optimization_number]]$forcedColumnBases)) {
        "fixed"
      } else {
        map$optimizations[[optimization_number]]$minColBasis
      }
    },

    mapTransformation = {
      map$optimizations[[optimization_number]][[attribute]]
    },

    mapTranslation = {
      map$optimizations[[optimization_number]][[attribute]]
    },

    colBases = {
      if(!is.null(map$optimizations[[optimization_number]]$forcedColumnBases)) {
        map$optimizations[[optimization_number]]$forcedColumnBases
      } else {
        ac_getTableColbases(titerTable(map, .name = FALSE), map$optimizations[[optimization_number]]$minColBasis)
      }
    },

    # Return an error if no attribute matched
    stop("No matching attribute found for ", attribute, call. = FALSE)

  )

}


# Setting point plotspec attributes ----
setProperty_optimization.racmap <- function(map, optimization_number, attribute, value, .check = TRUE){

  # Get the optimization
  optimization <- map$chart$projections[[optimization_number]]

  # Get any number of attributes from a group of antigens
  switch(

    # Attribute to match
    EXPR = attribute,

    # Base coordinates for antigens
    agBaseCoords = {
      map$optimizations[[optimization_number]][[attribute]] <- value
      if(.check) map <- updateStress(map, optimization_number)
    },

    # Base coordinates for sera
    srBaseCoords = {
      map$optimizations[[optimization_number]][[attribute]] <- value
      if(.check) map <- updateStress(map, optimization_number)
    },

    mapComment = {
      map$optimizations[[optimization_number]][[attribute]] <- value
    },

    mapDimensions = {
      map$optimizations[[optimization_number]][[attribute]] <- value
    },

    mapStress = {
      map$optimizations[[optimization_number]][[attribute]] <- value
    },

    minColBasis = {
      map$optimizations[[optimization_number]]$forcedColumnBases <- NULL
      map$optimizations[[optimization_number]]$minColBasis <- value
      if(.check) map <- updateStress(map, optimization_number)
    },

    mapTransformation = {
      map$optimizations[[optimization_number]][[attribute]] <- value
    },

    mapTranslation = {
      map$optimizations[[optimization_number]][[attribute]] <- value
    },

    colBases = {
      map$optimizations[[optimization_number]]$forcedColumnBases <- value
      if(.check) map <- updateStress(map, optimization_number)
    },

    # Return an error if no attribute matched
    stop("No matching attribute found for ", attribute, call. = FALSE)

  )

  # Return the map
  map

}
