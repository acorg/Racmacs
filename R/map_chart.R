
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
  selectedOptimization(map) <- 1
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
  UseMethod("removeOptimizations", map)
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
keepSingleOptimization <- function(map, optimization_number = NULL) {
  if(is.null(optimization_number)) optimization_number <- selectedOptimization(map)
  map$optimizations <- map$optimizations[optimization_number]
  selectedOptimization(map) <- 1
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
  nrow(titerTable(map, .name = FALSE))
}

#' @rdname acmapAttributes
#' @export
numSera <- function(map) {
  ncol(titerTable(map, .name = FALSE))
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




#' Get or set the selected optimization
#'
#' Functions to get and set the currently selected optimization from an acmap object (see details).
#'
#' @param map The acmap data object
#'
#' @return Returns the selected optimization number.
#'
#' @md
#' @details At any one time a map object has one of the optimizations _selected_
#'   (by default the first one). Any information you read from this map that
#'   comes from a optimization (for example \code{\link{agCoords}}) and any functions that
#'   you perform that relate to a optimization (for example \code{\link{relaxMap}}), will
#'   be performed on the selected optimization by default.
#'
#' @name selectedOptimization
#' @family {functions for working with map data}
#'


#' @rdname selectedOptimization
#' @export
selectedOptimization <- function(map) {
  map[["selected_optimization"]]
}

#' @rdname selectedOptimization
#' @export
`selectedOptimization<-` <- function(map, value) {
  if(!is.null(value)){
    if(length(value) != 1 || value < 1 || is.na(as.integer(value))) { stop("Main optimization number must be a single positive integer", call. = FALSE) }
    if(value > numOptimizations(map)) { stop("Cannot set the main optimization number to more than the number of map optimizations (", numOptimizations(map),")", call. = FALSE) }
  }
  map[["selected_optimization"]] <- value
  map
}



