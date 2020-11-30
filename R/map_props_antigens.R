
# Function factory for antigen attribute getter functions
antigens_getter <- function(attribute){
  eval(
    substitute(env = list(attribute = attribute), expr = {
      function(map){
        value <- sapply(map$antigens, function(ag){ ag[[attribute]] })
        defaultProperty_antigens(map, attribute, value)
      }
    })
  )
}

# Function factory for sera attribute setter functions
antigens_setter <- function(attribute){
  eval(
    substitute(env = list(attribute = attribute), expr = {
      function(map, .check = TRUE, value){
        if(.check) value <- checkProperty_antigens(map, attribute, value)
        value <- unname(value)
        for(x in seq_along(value)){
          map$antigens[[x]][[attribute]] <- value[x]
        }
        map
      }
    })
  )
}

# Property checker
checkProperty_antigens <- function(map, attribute, value){

  if(attribute == "agSequences"){
    if(nrow(value) != numAntigens(map)){
      stop(sprintf("Number of %s rows does not match number of antigens in the map", attribute))
    }
    if(!is.matrix(value)){
      value <- unname(as.matrix(value))
    }
  }

  character_attributes <- c("agGroupValues", "agGroupLevels")
  if(attribute %in% character_attributes){
    value <- unname(as.character(value))
  }

  length_exceptions <- c("agSequences", "agGroupLevels")
  if(!attribute %in% length_exceptions && length(value) != numAntigens(map)){
    stop(sprintf("Number of %s does not match number of antigens in the map", attribute))
  }

  value

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


#' Getting and setting antigen attributes
#'
#' These functions get and set the antigen attributes for a map.
#'
#' @name agAttributes
#' @seealso
#' \code{\link{srAttributes}}
#' @family {antigen and sera attribute functions}
#' @eval roxygen_tags(
#'   methods = c("agNames", "agIDs", "agNamesFull", "agNamesAbbreviated", "agDates", "agReference", "agSequences"),
#'   args    = c("map")
#' )
#'
agIDs               <- antigens_getter("agIDs")
agGroupValues       <- antigens_getter("agGroupValues")
agGroupLevels       <- antigens_getter("agGroupLevels")
agDates             <- antigens_getter("agDates")
agReference         <- antigens_getter("agReference")
agNames             <- antigens_getter("agNames")
agNamesFull         <- antigens_getter("agNamesFull")
agNamesAbbreviated  <- antigens_getter("agNamesAbbreviated")
agSequences         <- antigens_getter("agSequences")

`agNames<-`         <- antigens_setter("agNames")
`agIDs<-`           <- antigens_setter("agIDs")
`agGroupValues<-`   <- antigens_setter("agGroupValues")
`agGroupLevels<-`   <- antigens_setter("agGroupLevels")
`agDates<-`         <- antigens_setter("agDates")
`agReference<-`     <- antigens_setter("agReference")
`agNames<-`         <- antigens_setter("agNames")
`agSequences<-`     <- antigens_setter("agSequences")


#' Getting and setting antigen groups
#'
#' These functions get and set the antigen groupings for a map.
#' @name agGroups
#' @family {antigen and sera attribute functions}

#' @rdname agGroups
#' @export
agGroups <- function(map){

  if(is.null(agGroupValues(map))) return(NULL)
  factor(
    x = agGroupValues(map),
    levels = agGroupLevels(map)
  )

}

#' @rdname agGroups
#' @export
`agGroups<-` <- function(map, value){

  if(!is.factor(value)) value <- as.factor(value)
  agGroupValues(map) <- as.character(value)
  agGroupLevels(map) <- levels(value)
  map

}

