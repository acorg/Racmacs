
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

#' @rdname mapInfo
#' @export
allMapStresses <- function(map) {
  vapply(
    X   = allMapProperties(map, "stress"),
    FUN = function(values){
      value <- values[["stress"]]
      if(is.null(value)) value <- NA
      value
    },
    FUN.VALUE = numeric(1)
  )
}

#' @rdname mapInfo
#' @export
allMapDimensions <- function(map) {
  vapply(
    X   = allMapProperties(map, "dimensions"),
    FUN = function(values){
      value <- values[["dimensions"]]
      if(is.null(value)) value <- NA
      value
    },
    FUN.VALUE = numeric(1)
  )
}


#' @rdname mapInfo
#' @export
allMapProperties <- function(map, properties = NULL){
  if(is.null(properties)) properties <- list_property_function_bindings("optimization")$property
  allowed_properties <- list_property_function_bindings("optimization")$property
  if(sum(!properties %in% allowed_properties) > 0) stop("Optimization properties must be one of:\n\n", paste(allowed_properties, collapse = "\n"), "\n\n")
  UseMethod("optimizationProperties", map)
}


#' @rdname mapInfo
#' @export
name <- function(map) {
  UseMethod("name", map)
}

#' @rdname mapInfo
#' @export
`name<-` <- function(map, value) {
  UseMethod("set_name", map)
}


#' @rdname mapInfo
#' @export
titerTable <- function(map, names = TRUE) {
  UseMethod("titerTable", map)
}

#' @rdname mapInfo
#' @export
`titerTable<-` <- function(map, value) {
  mode(value) <- "character"
  set_titerTable(map, value)
}

set_titerTable <- function(map, value) {
  UseMethod("set_titerTable", map)
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
  UseMethod("numAntigens", map)
}

#' @rdname acmapAttributes
#' @export
numSera <- function(map) {
  UseMethod("numSera", map)
}

#' @rdname acmapAttributes
#' @export
numPoints <- function(map) {
  UseMethod("numPoints", map)
}

#' @rdname acmapAttributes
#' @export
numOptimizations <- function(map) {
  UseMethod("numOptimizations", map)
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
#'
#' @family functions to get and set map attributes
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



