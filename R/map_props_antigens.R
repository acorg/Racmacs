
# Function factory for antigen attribute getter functions
antigens_getter <- function(attribute){
  eval(
    substitute(env = list(attribute = attribute), expr = {
      function(map){
        value <- classSwitch("getProperty_antigens", map, attribute)
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
        if(.check) checkProperty_antigens(map, attribute, value)
        classSwitch("setProperty_antigens", map, attribute, value)
      }
    })
  )
}

# Property checker
checkProperty_antigens <- function(map, attribute, value){

  if(length(value) != numAntigens(map)){
    stop(sprintf("Number of %s does not match number of antigens in the map", attribute))
  }

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
#' These functions get and set the antigen attributes for a given optimization run.
#'
#' @name agAttributes
#' @seealso
#' \code{\link{srAttributes}}
#' @family {antigen and sera attribute functions}
#' @eval roxygen_tags(
#'   methods = c("agNames", "agIDs", "agGroups", "agNamesFull", "agNamesAbbreviated", "agDates", "agReference"),
#'   args    = c("map")
#' )
#'
agIDs               <- antigens_getter("agIDs")
agGroups            <- antigens_getter("agGroups")
agDates             <- antigens_getter("agDates")
agReference         <- antigens_getter("agReference")
agNames             <- antigens_getter("agNames")
agNamesFull         <- antigens_getter("agNamesFull")
agNamesAbbreviated  <- antigens_getter("agNamesAbbreviated")

`agNames<-`         <- antigens_setter("agNames")
`agIDs<-`           <- antigens_setter("agIDs")
`agGroups<-`        <- antigens_setter("agGroups")
`agDates<-`         <- antigens_setter("agDates")
`agReference<-`     <- antigens_setter("agReference")
`agNames<-`         <- antigens_setter("agNames")


