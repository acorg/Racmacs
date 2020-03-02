
#' Strains in an antigenic map
#'
#' @param map The map object
#' @param value Value to be used (recycled as necessary)
#' @name mapStrains
#'
#' @return Returns an updated racmap object
#' @eval export_property_method_tags("sera")
#'
NULL

# Getter
sera_getter <- function(attribute){
  function(map){
    value <- classSwitch("getProperty_sera", map, attribute)
    defaultProperty_sera(map, attribute, value)
  }
}

# Setter
sera_setter <- function(attribute){
  function(map, .check = TRUE, value){
    if(.check){
      checkProperty_sera(map, attribute, value)
    }
    classSwitch("setProperty_sera", map, attribute, value)
  }
}

# Property checker
checkProperty_sera <- function(map, attribute, value){

  if(length(value) != numSera(map)){
    stop(sprintf("Number of %s does not match number of sera in the map", attribute))
  }

}

# Default property setter
defaultProperty_sera <- function(map, attribute, value){

  # Check if a null was returned
  if(is.null(value)){

    # Choose the default
    value <- switch(

      EXPR = attribute,
      srDates = "",
      srNames = return(NULL)

    )

    # Repeat to match the number of sera
    value <- rep(value, length(srNames(map)))

  }

  # Return the modified value
  value

}

# Bind the methods
bindObjectMethods("sera")

