
#' Strains in an antigenic map
#'
#' @param map The map object
#' @param value Value to be used (recycled as necessary)
#' @name mapStrains
#'
#' @return Returns an updated racmap object
#' @eval export_property_method_tags("chart")
#'
NULL

# Getter
chart_getter <- function(attribute){
  function(map, .name = TRUE){
    value <- classSwitch("getProperty_chart", map, attribute)
    convertProperty_chart(map, attribute, value, .name)
  }
}

# Setter
chart_setter <- function(attribute){
  function(map, .check = TRUE, value){
    if(.check){
      value <- checkProperty_chart(map, attribute, value)
    }
    classSwitch("setProperty_chart", map, attribute, value)
  }
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
        if(class(titers) == "data.frame") titers <- as.matrix(titers)
        if(class(titers) != "matrix") stop("Input must be a list of titer matrices")
        mode(titers) <- "character"
        titers
      })
      value
    },
    value

  )

}

# Conversion of values
convertProperty_chart <- function(map, attribute, value, .name){

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

# Bind the methods
bindObjectMethods("chart")


