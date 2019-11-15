

## Add optimization --------
#' @export
optimization.add.racmap <- function(map,
                                    number_of_dimensions = NULL,
                                    ...){
  # Collect arguments
  optimization_args <- list(...)

  # Get the new optimization number
  optimization_num  <- numOptimizations(map) + 1


  optimization_attributes <- list_property_function_bindings("optimization")
  argument_methods      <- optimization_attributes$method[optimization_attributes$property %in% names(optimization_args)]
  argument_properties   <- optimization_attributes$property[optimization_attributes$property %in% names(optimization_args)]

  # Add blank optimization
  map$optimizations <- c(map$optimizations, list(list()))

  # Set the main optimization number to this optimization if not already specified
  if(is.null(selectedOptimization(map))) selectedOptimization(map) <- optimization_num

  # Apply arguments
  for(n in seq_along(argument_methods)){
    setter <- get(paste0(argument_methods[n], "<-"))
    map    <- setter(map, optimization_num, optimization_args[[argument_properties[n]]])
  }

  # Return the map
  map

}


## List optimizations
#' @export
listOptimizations.racmap <- function(racmap){
  racmap$optimizations
}

## Get information on a single optimization
#' @export
getOptimization.racmap <- function(map, optimization_number = NULL){
  optimization_number <- convertOptimizationNum(optimization_number, map)
  map$optimizations[[optimization_number]]
}


## Antigen and sera coordinates
#' @export
agCoords.racmap <- function(racmap, optimization_number = NULL, names = TRUE){
  optimization_number <- convertOptimizationNum(optimization_number, racmap)
  ag_coords <- racmap$optimizations[[optimization_number]]$ag_coords
  if(names) rownames(ag_coords) <- agNames(racmap)
  ag_coords
}

#' @export
srCoords.racmap <- function(racmap, optimization_number = NULL, names = TRUE){
  optimization_number <- convertOptimizationNum(optimization_number, racmap)
  sr_coords <- racmap$optimizations[[optimization_number]]$sr_coords
  if(names) rownames(sr_coords) <- srNames(racmap)
  sr_coords
}


#' @export
set_agCoords.racmap <- function(racmap, value, optimization_number = NULL){

  # Label the coordinate rows with antigen names
  rownames(value) <- agNames(racmap)

  # Get the specified optimization number
  optimization_number <- convertOptimizationNum(optimization_number, racmap)

  # Bake any current transformation
  racmap <- bakeTransformation(racmap, optimization_number)

  # Set the coordinates
  racmap$optimizations[[optimization_number]]$ag_coords <- value

  # Set the main map details to the new antigen coordinates
  if(selectedOptimization(racmap) == optimization_number){ racmap$ag_coords <- value }

  # Return the updated map
  racmap

}


#' @export
set_srCoords.racmap <- function(racmap, value, optimization_number = NULL){

  # Label the coordinate rows with serum names
  rownames(value) <- srNames(racmap)

  # Get the specified optimization number
  optimization_number <- convertOptimizationNum(optimization_number, racmap)

  # Bake any current transformation
  racmap <- bakeTransformation(racmap, optimization_number)

  # Set the coordinates
  racmap$optimizations[[optimization_number]]$sr_coords <- value

  # Set the main map details to the new serum coordinates
  if(selectedOptimization(racmap) == optimization_number){ racmap$sr_coords <- value }

  # Return the updated map
  racmap

}



#' @export
mapTransformation.racmap <- function(racmap, optimization_number = NULL){
  optimization_number <- convertOptimizationNum(optimization_number, racmap)
  transformation <- racmap$optimizations[[optimization_number]]$transformation
  if(is.null(transformation)){
    transformation <- diag(numDimensions(racmap, optimization_number))
  }
  transformation
}

#' @export
set_mapTransformation.racmap <- function(racmap, value, optimization_number = NULL){
  optimization_number <- convertOptimizationNum(optimization_number, racmap)
  racmap$optimizations[[optimization_number]]$transformation <- value
  racmap
}

#' @export
mapTranslation.racmap <- function(racmap, optimization_number = NULL){
  optimization_number <- convertOptimizationNum(optimization_number, racmap)
  translation <- racmap$optimizations[[optimization_number]]$translation
  if(is.null(translation)){
    translation <- rep(0, mapDimensions(racmap))
  }
  translation
}

#' @export
set_mapTranslation.racmap <- function(racmap, value, optimization_number = NULL){
  optimization_number <- convertOptimizationNum(optimization_number, racmap)
  racmap$optimizations[[optimization_number]]$translation <- value
  racmap
}

#' @export
minColBasis.racmap <- function(racmap, optimization_number = NULL){
  optimization_number <- convertOptimizationNum(optimization_number, racmap)
  forced_column_bases  <- racmap$optimizations[[optimization_number]]$forced_column_bases
  minimum_column_basis <- racmap$optimizations[[optimization_number]]$minimum_column_basis
  if(!is.null(forced_column_bases)){
    return("fixed")
  } else {
    return(minimum_column_basis)
  }
}

#' @export
set_minColBasis.racmap <- function(racmap, value, optimization_number = NULL){

  if(is.null(value)) return(racmap)
  optimization_number <- convertOptimizationNum(optimization_number, racmap)
  racmap$optimizations[[optimization_number]]$minimum_column_basis <- value

  titer_table <- titerTable(racmap)
  if(!is.null(titer_table)){
    colbases <- ac_getTableColbases(titer_table             = titer_table,
                                    minimum_column_basis = value)
    names(colbases) <- srNames(racmap)
    racmap$optimizations[[optimization_number]]$colbases <- colbases
  }

  racmap

}


#' @export
colBases.racmap <- function(racmap, optimization_number = NULL, name = TRUE){

  optimization_number <- convertOptimizationNum(optimization_number, racmap)
  colbases <- racmap$optimizations[[optimization_number]]$colbases
  if(!name) colbases <- unname(colbases)
  colbases

}

#' @export
set_colBases.racmap <- function(racmap, value, optimization_number = NULL){

  optimization_number <- convertOptimizationNum(optimization_number, racmap)

  names(value) <- srNames(racmap)
  racmap$optimizations[[optimization_number]]$colbases <- value
  racmap$optimizations[[optimization_number]]$minimum_column_basis <- "fixed"
  racmap

}

#' @export
mapStress.racmap <- function(racmap, optimization_number = NULL){
  optimization_number <- convertOptimizationNum(optimization_number, racmap)
  ac_calcStress(
    ag_coords = agCoords(racmap, optimization_number),
    sr_coords = srCoords(racmap, optimization_number),
    titer_table  = titerTable(racmap),
    colbases  = colBases(racmap, optimization_number)
  )
}


# Getting number of dimensions -------
#' @export
mapDimensions.racmap <- function(racmap, optimization_number = NULL){
  ncol(agCoords(racmap, optimization_number))
}


# Map comments --------
#' @export
mapComment.racmap <- function(racmap, optimization_number = NULL){
  optimization_number <- convertOptimizationNum(optimization_number, racmap)
  racmap$optimizations[[optimization_number]]$comment
}

#' @export
set_mapComment.racmap <- function(racmap, value, optimization_number = NULL){
  optimization_number <- convertOptimizationNum(optimization_number, racmap)
  racmap$optimizations[[optimization_number]]$comment <- value
  if(selectedOptimization(racmap) == optimization_number){ racmap$comment <- value }
  racmap
}







