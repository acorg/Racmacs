
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


# Bind all methods for a particular type of object
bindObjectMethods <- function(object){

  # Getter and setter functions
  propGetter <- get(paste0(object, "_getter"))
  propSetter <- get(paste0(object, "_setter"))

  # Assign functions for each property getter and setter
  properties <- list_property_function_bindings(object)
  for(i in seq_len(nrow(properties))){

    getterName <- properties$method[i]
    getterFn   <- eval(substitute(propGetter(getterName)))

    setterName <- paste0(getterName, "<-")
    setterFn   <- eval(substitute(propSetter(getterName)))

    assign(
      x     = getterName,
      value = getterFn,
      envir = parent.frame()
    )

    assign(
      x     = setterName,
      value = setterFn,
      envir = parent.frame()
    )

  }

}


