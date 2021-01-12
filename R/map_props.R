
#' Getting and setting the map name
#'
#' You can use the standard `mapName()` function to get and set the map name.
#'
#' @name mapName
#' @family {map attribute functions}
#' @eval roxygen_tags(
#'   methods = c("mapName"),
#'   args    = c("map")
#' )
#'
mapName <- function(map){
  map$name
}

`mapName<-` <- function(map, value){
  map$name <- value
  map
}

#' Getting and setting map titers
#'
#' Functions to get and set the map titer table.
#'
#' @name titerTable
#' @family {map attribute functions}
#'

#' @export
#' @rdname titerTable
titerTable <- function(map){

  titers <- titerTableFlat(map)
  rownames(titers) <- agNames(map)
  colnames(titers) <- srNames(map)
  titers

}


#' @export
#' @rdname titerTable
`titerTable<-` <- function(map, value){

  # Set the flat titer table
  titerTableFlat(map) <- value

  # Set the titer table layers
  titerTableLayers(map) <- list(value)

  # Return the map
  map

}


#' @noRd
titerTableFlat <- function(map){
  map$titer_table_flat
}

#' @noRd
`titerTableFlat<-` <- function(map, value){
  if(is.data.frame(value)) value <- as.matrix(value)
  mode(value)        <- "character"
  map$titer_table_flat <- value
  map
}


#' Getting and setting titer table layers
#'
#' Functions to get and set the underlying titer table layers of a map (see details).
#'
#' @name titerTableLayers
#' @family {map attribute functions}
#' @eval roxygen_tags(
#'   methods = c("titerTableLayers"),
#'   args    = c("map")
#' )
#'
titerTableLayers <- function(map){
  map$titer_table_layers
}

`titerTableLayers<-` <- function(map, value){

  # Check input
  if(!is.list(value)){
    stop("Titer table layers must be a list of titer tables")
  }

  # Update layers
  value <- lapply(value, function(titers){
    if(is.data.frame(titers)) titers <- as.matrix(titers)
    mode(titers) <- "character"
    titers
  })
  map$titer_table_layers <- value

  # Update the flat titer layer
  if(length(value) > 1){
    titerTableFlat(map) <- ac_merge_titer_layers(value)
  } else {
    titerTableFlat(map) <- value[[1]]
  }

  # Return the updated map
  map

}

#' Sort optimizations by stress
#'
#' Sorts all the optimization runs for a given map object by stress
#' (lowest to highest). Note that this is done by default when running
#' [optimizeMap()].
#'
#' @param map map data object
#'
#' @family {functions to work with map optimizations}
#' @export
sortOptimizations <- function(map) {
  map$optimizations <- map$optimizations[order(allMapStresses(map))]
  map
}

# Get arbitrary map properties
allMapProperties <- function(map, getter){
  vapply(
    seq_len(numOptimizations(map)),
    function(i){
      value <- getter(map, i)
      if(is.null(value)) value <- NA
      value
    },
    numeric(1)
  )
}


#' Get optimization properties
#'
#' Utility functions to get a vector of all the map optimization
#' properties.
#'
#' @param map map data object
#'
#' @family {functions to work with map optimizations}
#' @name optimizationProperties

#' @rdname optimizationProperties
#' @export
allMapStresses <- function(map) {
  allMapProperties(map, mapStress)
}

#' @rdname optimizationProperties
#' @export
allMapDimensions <- function(map) {
  allMapProperties(map, mapDimensions)
}

#' Remove map optimizations
#'
#' Remove all optimization run data from a map object
#'
#' @param map the map data object
#'
#' @family {functions to work with map optimizations}
#' @export
#'
removeOptimizations <- function(map) {
  map$optimizations <- NULL
  map
}

#' Keep a single optimization run
#'
#' Keep only data from a single optimization run, either a specified
#' optimization (defaulting to the selected one), or the "best"
#' (lowest stress) optimization
#'
#' @param map the map data object
#'
#' @family {functions to work with map optimizations}
#' @name keepSingleOptimization

#' @export
#' @rdname keepSingleOptimization
keepSingleOptimization <- function(map, optimization_number = 1) {
  map$optimizations <- map$optimizations[optimization_number]
  map
}

#' @export
#' @rdname keepSingleOptimization
keepBestOptimization <- function(map) {
  map <- sortOptimizations(map)
  keepSingleOptimization(map, optimization_number = 1)
}




#' Get acmap attributes
#'
#' Functions to get various attributes about an acmap object.
#'
#' @param map The acmap data object
#'
#' @name acmapAttributes
#' @family {map attribute functions}
#'

#' @rdname acmapAttributes
#' @export
numAntigens <- function(map) {
  length(map$antigens)
}

#' @rdname acmapAttributes
#' @export
numSera <- function(map) {
  length(map$sera)
}

#' @rdname acmapAttributes
#' @export
numPoints <- function(map) {
  numAntigens(map) + numSera(map)
}

#' @rdname acmapAttributes
#' @export
numOptimizations <- function(map) {
  length(map$optimizations)
}


