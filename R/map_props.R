
#' Getting and setting the map name
#'
#' @name mapName
#' @family {map attribute functions}
#' @eval roxygen_tags(
#'   methods = c("mapName", "mapName<-"),
#'   args    = c("map")
#' )
#'
mapName <- function(map){
  check.acmap(map)
  map$name
}

`mapName<-` <- function(map, value){
  check.acmap(map)
  map$name <- value
  map
}

#' Getting and setting map titers
#'
#' Functions to get and set the map titer table. Note that when setting the
#' titer table like this any titer table layer information is lost, this is
#' normally not a problem unless the map is a result of merging two titer tables
#' together previously and you then go on the merge the titers again.
#'
#' @param map The acmap object
#' @param value A character matrix of titers to set
#'
#' @name titerTable
#' @family {map attribute functions}
#'

#' @export
#' @rdname titerTable
titerTable <- function(map){

  check.acmap(map)
  titers <- titerTableFlat(map)
  rownames(titers) <- agNames(map)
  colnames(titers) <- srNames(map)
  titers

}


#' @export
#' @rdname titerTable
`titerTable<-` <- function(map, value){

  check.acmap(map)

  # Set the flat titer table
  titerTableFlat(map) <- value

  # Set the titer table layers
  titerTableLayers(map) <- list(value)

  # Return the map
  map

}


#' Getting and setting the flat titer table
#'
#' These are underlying functions to get and set the "flat" version of the titer
#' table only. When a map is merged, the titer tables are merged but a record of
#' the original titers associated with each map are kept as titer table layers
#' so that information on the original set of titers that made up the merge is
#' not lost. At the same time, the merged titer version of the titer table is
#' created and saved as the titer_table_flat attribute. When you access titers
#' through the `titerTable()` function, the flat version of the titer table is
#' retrieved (only really a relevant distinction for merged maps). When you set
#' titers through `titerTable<-()` titer table layers are lost. These functions
#' allow you to manipulate the flat version without effecting the titer table
#' layers information.
#'
#' @name titerTableFlat

#' @rdname titerTable
titerTableFlat <- function(map){
  check.acmap(map)
  map$titer_table_flat
}

#' @rdname titerTable
`titerTableFlat<-` <- function(map, value){
  check.acmap(map)
  if(is.data.frame(value)) value <- as.matrix(value)
  mode(value)        <- "character"
  map$titer_table_flat <- value
  map
}


#' Getting and setting titer table layers
#'
#' Functions to get and set the underlying titer table layers of a map (see details).
#'
#' @param map The acmap object
#' @param value A list of titer table character vectors to set
#'
#' @details When you merge maps with `mergeMaps()` repeated antigen - serum
#'   titers are merged to create a new titer table but information on the
#'   original titers is not lost. The original titer tables, aligned to their
#'   new positions in the merged table, are kept as separate layers that can be
#'   accessed with these functions. If you have merged a whole bunch of
#'   different maps, these functions can be useful to check for example,
#'   variation in titer seen between a single antigen and serum pair.
#'
#' @name titerTableLayers
#' @family {map attribute functions}
#' @export
#'
titerTableLayers <- function(map){
  check.acmap(map)
  map$titer_table_layers
}

#' @rdname titerTableLayers
`titerTableLayers<-` <- function(map, value){

  # Check input
  check.acmap(map)
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
#' `optimizeMap()`.
#'
#' @param map The acmap object
#'
#' @family {functions to work with map optimizations}
#' @export
sortOptimizations <- function(map) {
  check.acmap(map)
  map$optimizations <- map$optimizations[order(allMapStresses(map))]
  map
}


# Helper function for getting a vector of properties associated with each
# optimization run, like stress
allMapProperties <- function(map, getter){
  check.acmap(map)
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
#' @param map The acmap object
#'
#' @family {functions to work with map optimizations}
#' @name optimizationProperties

#' @rdname optimizationProperties
#' @export
allMapStresses <- function(map) {
  check.acmap(map)
  allMapProperties(map, mapStress)
}

#' @rdname optimizationProperties
#' @export
allMapDimensions <- function(map) {
  check.acmap(map)
  allMapProperties(map, mapDimensions)
}


#' Remove map optimizations
#'
#' Remove all optimization run data from a map object
#'
#' @param map The acmap object
#'
#' @family {functions to work with map optimizations}
#' @export
#'
removeOptimizations <- function(map) {
  check.acmap(map)
  map$optimizations <- NULL
  map
}


#' Keep specified optimization runs
#'
#' Keep only data from specified optimization runs.
#'
#' @param map The acmap object
#' @param optimization_numbers Optimizations to keep
#'
#' @family {functions to work with map optimizations}
#'
#' @export
#'
keepOptimizations <- function(map, optimization_numbers){
  check.numericvector(optimization_numbers)
  check.acmap(map)
  if(numOptimizations(map) == 0) stop("Map has no optimization runs", call. = FALSE)
  if(min(optimization_numbers) < 1) stop("Invalid optimization number", call. = FALSE)
  if(max(optimization_numbers) > numOptimizations(map)) stop("Invalid optimization number", call. = FALSE)
  map$optimizations <- map$optimizations[optimization_numbers]
  map
}

#' Keep only a single optimization run
#'
#' @param map The acmap object
#' @param optimization_number The optimization run to keep
#'
#' @export
#'
keepSingleOptimization <- function(map, optimization_number = 1) {
  keepOptimizations(map, optimization_number)
}

#' Keep only the lowest stress map optimization
#'
#' @param map The acmap object
#'
#' @export
#'
keepBestOptimization <- function(map) {
  map <- sortOptimizations(map)
  keepOptimizations(map, 1)
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
  check.acmap(map)
  length(map$antigens)
}

#' @rdname acmapAttributes
#' @export
numSera <- function(map) {
  check.acmap(map)
  length(map$sera)
}

#' @rdname acmapAttributes
#' @export
numPoints <- function(map) {
  check.acmap(map)
  numAntigens(map) + numSera(map)
}

#' @rdname acmapAttributes
#' @export
numOptimizations <- function(map) {
  check.acmap(map)
  length(map$optimizations)
}


