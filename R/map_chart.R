
#' Return information about a map
#'
#' @param map The map object
#'
#' @name mapInfo
#'
NULL

#' @rdname mapInfo
#' @export
sortOptimizations <- function(map) {
  UseMethod("sortOptimizations", map)
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

#' @rdname mapInfo
#' @export
allMapStresses <- function(map) {
  allMapProperties(map, mapStress)
}

#' @rdname mapInfo
#' @export
allMapDimensions <- function(map) {
  allMapProperties(map, mapDimensions)
}

#' @rdname mapInfo
#' @export
removeOptimizations <- function(map) {
  UseMethod("removeOptimizations", map)
}

#' @rdname mapInfo
#' @export
keepSingleOptimization <- function(map, optimization_number = NULL) {
  UseMethod("keepSingleOptimization", map)
}

#' @rdname mapInfo
#' @export
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
#' @family functions to get and set map attributes
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
  UseMethod("numOptimizations", map)
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
  UseMethod("selectedOptimization", map)
}

#' @rdname selectedOptimization
#' @export
`selectedOptimization<-` <- function(map, value) {
  if(!is.null(value)){
    if(length(value) != 1 || value < 1 || is.na(as.integer(value))) { stop("Main optimization number must be a single positive integer", call. = FALSE) }
    if(value > numOptimizations(map)) { stop("Cannot set the main optimization number to more than the number of map optimizations (", numOptimizations(map),")", call. = FALSE) }
  }
  set_selectedOptimization(map, value)
}

#' @rdname mapInfo
#' @export
set_selectedOptimization <- function(map, value) {
  UseMethod("set_selectedOptimization", map)
}



