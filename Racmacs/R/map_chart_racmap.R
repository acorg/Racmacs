
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
  # if(is.null(value)){
  #   optimization_attributes <- list_property_function_bindings("optimization")
  #   map[optimization_attributes$property] <- NULL
  # } else {
  #   map[names(map$optimizations[[value]])] <- map$optimizations[[value]]
  # }
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



