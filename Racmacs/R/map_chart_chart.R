
# Utility function for finding a map optimization
findOptimization <- function(map, optimization_number){
  if(is.null(optimization_number)) optimization_number <- selectedOptimization(map)
  optimization_number
}

#' @export
numOptimizations.racchart <- function(map){
  map$chart$number_of_projections
}


#' @export
removeOptimizations.racchart <- function(map){

  # Clear attributes
  map$chart$set_extension_field("translation",    "{}")
  map$chart$set_extension_field("transformation", "{}")

  # Remove projections
  map$chart$remove_all_projections()

  # Deselect map
  selectedOptimization(map) <- NULL

  # Return the map
  map

}

#' @export
keepSingleOptimization.racchart <- function(map, optimization_number = NULL){

  # Convert the optim number
  optimization_number <- convertOptimizationNum(optimization_number, map)

  # Get other attributes
  transformation <- mapTransformation(map, optimization_number)
  translation    <- mapTranslation(map, optimization_number)

  # Clear attributes
  map$chart$set_extension_field("translation",    "{}")
  map$chart$set_extension_field("transformation", "{}")

  # Remove other projections
  map$chart$remove_all_projections_except(optimization_number)

  # Select the map
  selectedOptimization(map) <- 1

  # Set the attributes
  mapTransformation(map, 1) <- transformation
  mapTranslation(map, 1) <- translation

  # Return the map
  map

}

#' @export
selectedOptimization.racchart <- function(map){
  unlist(jsonlite::fromJSON(map$chart$extension_field("selected_optimization")))
}

#' @export
set_selectedOptimization.racchart <- function(map, value){
  map$chart$set_extension_field("selected_optimization", jsonlite::toJSON(value))
  map
}

#' @export
sortOptimizations.racchart <- function(map){

  # Get the stress order
  stress_order <- order(allMapStresses(map))

  # Get other attributes
  transformations <- lapply(seq_len(numOptimizations(map)), mapTransformation, map = map)
  translations    <- lapply(seq_len(numOptimizations(map)), mapTranslation, map = map)

  # Sort projections
  map$chart$sort_projections()
  selectedOptimization(map) <- 1

  # Redefine attributes
  for(i in seq_along(stress_order)){
    mapTransformation(map, i) <- transformations[[stress_order[i]]]
    mapTranslation(map, i)    <- translations[[stress_order[i]]]
  }

  # Return the map
  map

}



