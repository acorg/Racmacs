
# Function factory for antigen attribute getter functions
sera_getter <- function(attribute){
  eval(
    substitute(env = list(attribute = attribute), expr = {
      function(map){
        value <- classSwitch("getProperty_sera", map, attribute)
        defaultProperty_sera(map, attribute, value)
      }
    })
  )
}

# Function factory for sera attribute setter functions
sera_setter <- function(attribute){
  eval(
    substitute(env = list(attribute = attribute), expr = {
      function(map, .check = TRUE, value){
        if(.check) value <- checkProperty_sera(map, attribute, value)
        classSwitch("setProperty_sera", map, attribute, value)
      }
    })
  )
}

# Property checker
checkProperty_sera <- function(map, attribute, value){

  if(attribute == "srSequences"){
    if(nrow(value) != numSera(map)){
      stop(sprintf("Number of %s cols does not match number of sera in the map", attribute))
    }
    if(!is.matrix(value)){
      value <- unname(as.matrix(value))
    }
  }

  character_attributes <- c("srGroupValues", "srGroupLevels")
  if(attribute %in% character_attributes){
    value <- unname(as.character(value))
  }

  length_exceptions <- c("srSequences", "srGroupLevels")
  if(!attribute %in% length_exceptions && length(value) != numSera(map)){
    stop(sprintf("Number of %s does not match number of sera in the map", attribute))
  }

  value

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


#' Getting and setting sera attributes
#'
#' These functions get and set the sera attributes for a map.
#'
#' @name srAttributes
#' @seealso
#' \code{\link{agAttributes}}
#' @family {antigen and sera attribute functions}
#' @eval roxygen_tags(
#'   methods = c("srNames", "srIDs", "srNamesFull", "srNamesAbbreviated", "srSequences"),
#'   args    = c("map")
#' )
#'
srIDs               <- sera_getter("srIDs")
srGroupValues       <- sera_getter("srGroupValues")
srGroupLevels       <- sera_getter("srGroupLevels")
srNames             <- sera_getter("srNames")
srNamesFull         <- sera_getter("srNamesFull")
srNamesAbbreviated  <- sera_getter("srNamesAbbreviated")
srSequences         <- sera_getter("srSequences")

`srNames<-`         <- sera_setter("srNames")
`srIDs<-`           <- sera_setter("srIDs")
`srGroupValues<-`   <- sera_setter("srGroupValues")
`srGroupLevels<-`   <- sera_setter("srGroupLevels")
`srSequences<-`     <- sera_setter("srSequences")


#' Getting and setting sera groups
#'
#' These functions get and set the sera groupings for a map.
#' @name srGroups
#' @family {antigen and sera attribute functions}

#' @rdname srGroups
#' @export
srGroups <- function(map){

  if(is.null(srGroupValues(map))) return(NULL)
  factor(
    x = srGroupValues(map),
    levels = srGroupLevels(map)
  )

}

#' @rdname srGroups
#' @export
`srGroups<-` <- function(map, value){

  if(!is.factor(value)) value <- as.factor(value)
  srGroupValues(map) <- as.character(value)
  srGroupLevels(map) <- levels(value)
  map

}



