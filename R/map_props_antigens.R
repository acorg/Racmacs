
#' Strains in an antigenic map
#'
#' @param map The map object
#' @param value Value to be used (recycled as necessary)
#' @name mapStrains
#'
#' @return Returns an updated racmap object
#' @eval export_property_method_tags("antigens")
#'
NULL

# Getter
antigens_getter <- function(attribute){
  function(map){
    value <- classSwitch("getProperty_antigens", map, attribute)
    defaultProperty_antigens(map, attribute, value)
  }
}

# Setter
antigens_setter <- function(attribute){
  function(map, .check = TRUE, value){
    if(.check){
      checkProperty_antigens(map, attribute, value)
    }
    classSwitch("setProperty_antigens", map, attribute, value)
  }
}

# Property checker
checkProperty_antigens <- function(map, attribute, value){

  # if(length(value) != numAntigens(map)){
  #   stop(sprintf("Number of %s does not match number of antigens in the map", attribute))
  # }

}

# Default property setter
defaultProperty_antigens <- function(map, attribute, value){

  # Check if a null was returned
  if(is.null(value)){

    # Choose the default
    value <- switch(

      EXPR = attribute,
      agDates = "",
      agNames = return(NULL)

    )

    # Repeat to match the number of antigens
    value <- rep(value, numAntigens(map))

  }

  # Do any necessary conversions
  value <- switch(

    EXPR    = attribute,
    agDates = {value[as.character(value) == ""] <- NA; as.Date(value)},
    value

  )

  # Return the modified value
  value

}

# Bind the methods
bindObjectMethods("antigens")

