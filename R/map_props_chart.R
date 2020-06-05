
# Function factory for antigen attribute getter functions
chart_getter <- function(attribute){
  eval(
    substitute(env = list(attribute = attribute), expr = {
      function(map){
        value <- classSwitch("getProperty_chart", map, attribute)
        defaultProperty_chart(map, attribute, value)
      }
    })
  )
}

# Function factory for sera attribute setter functions
chart_setter <- function(attribute){
  eval(
    substitute(env = list(attribute = attribute), expr = {
      function(map, .check = TRUE, value){
        if(.check) checkProperty_chart(map, attribute, value)
        classSwitch("setProperty_chart", map, attribute, value)
      }
    })
  )
}

# Property checker
checkProperty_chart <- function(map, attribute, value){

  switch(

    EXPR       = attribute,
    titerTableLayers = {
      if(class(value) != "list"){
        stop("Input must be a list of titer layers")
      }
      value <- lapply(value, function(titers){
        if(is.data.frame(titers)) titers <- as.matrix(titers)
        if(!is.matrix(titers)) stop("Input must be a list of titer matrices")
        mode(titers) <- "character"
        titers
      })
      value
    },
    value

  )

}

# Conversion of values
defaultProperty_chart <- function(map, attribute, value, .name){

  # Check if a null was returned
  if(is.null(value)){

    # Choose the default
    value <- switch(

      EXPR = attribute,
      name = "",
      value

    )

  }

  value

}

#' Getting and setting the map name
#'
#' You can use the standard `name()` function to get and set the map name.
#'
#' @name name
#' @family {map attribute functions}
#' @eval roxygen_tags(
#'   methods = c("name"),
#'   args    = c("map")
#' )
#'
name     <- chart_getter("name")
`name<-` <- chart_setter("name")


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
titerTableLayers     <- chart_getter("titerTableLayers")
`titerTableLayers<-` <- chart_setter("titerTableLayers")





