
#' @export
numAntigens.racmap <- function(map){
  if(!is.null(titerTable(map))) numAntigens <- nrow(titerTable(map))
  else if(!is.null(agNames(map)))  numAntigens <- length(agNames(map))
  else if(!is.null(agCoords(map))) numAntigens <- nrow(agCoords(map))
  else stop("Can't work out number of antigens", call. = FALSE)
  numAntigens
}

#' @export
numSera.racmap <- function(map){
  if(!is.null(titerTable(map))) numSera <- ncol(titerTable(map))
  else if(!is.null(srNames(map)))  numSera <- length(srNames(map))
  else if(!is.null(srCoords(map))) numSera <- nrow(srCoords(map))
  else stop("Can't work out number of sera", call. = FALSE)
  numSera
}

#' @export
numPoints.racmap <- function(map){
  numAntigens(map) + numSera(map)
}


#' @export
numOptimizations.racmap <- function(map){
  length(map$optimizations)
}

#' @export
optimizationProperties.racmap <- function(map, properties){
  lapply(map$optimizations, function(optimization) optimization[properties])
}

#' @export
removeOptimizations.racmap <- function(map){
  map$optimizations <- list()
  selectedOptimization(map) <- NULL
  map
}

#' @export
keepSingleOptimization.racmap <- function(map, optimization_number = NULL){
  if(is.null(optimization_number)) optimization_number <- selectedOptimization(map)
  map$optimizations <- map$optimizations[optimization_number]
  selectedOptimization(map) <- 1
  map
}

#' @export
selectedOptimization.racmap <- function(map){
  map[["selected_optimization"]]
}

#' @export
set_selectedOptimization.racmap <- function(map, value){
  map$selected_optimization <- value
  if(is.null(value)){
    optimization_attributes <- list_property_function_bindings("optimization")
    map[optimization_attributes$property] <- NULL
  } else {
    map[names(map$optimizations[[value]])] <- map$optimizations[[value]]
  }
  map
}

#' @export
sortOptimizations.racmap <- function(map){
  optimization_stresses <- vapply(X = seq_along(map$optimizations),
                                FUN = function(x) mapStress(map, x),
                                FUN.VALUE = numeric(1))
  map$optimizations <- map$optimizations[order(optimization_stresses)]
  selectedOptimization(map) <- 1
  map
}

#' @export
name.racmap <- function(map){
  map$table_name
}

#' @export
set_name.racmap <- function(map, value){
  map$table_name <- value
  map
}


#' @export
titerTable.racmap <- function(map, names = TRUE){
  titer_table <- map$table
  if(!names) titer_table <- unname(titer_table)
  titer_table
}

#' @export
set_titerTable.racmap <- function(map, value){
  value <- as.matrix(value)
  rownames(value) <- agNames(map)
  colnames(value) <- srNames(map)
  map$table <- value
  map
}




