
# Function factory for antigen attribute getter functions
antigens_getter <- function(attribute){
  eval(
    substitute(env = list(attribute = attribute), expr = {
      function(map){
        value <- sapply(map$antigens, function(ag){ ag[[attribute]] })
        if(is.null(unlist(value))) return(NULL)
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

  character_attributes <- c("group_values")
  if(attribute %in% character_attributes){
    value <- unname(as.character(value))
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
#'   methods = c("agNames", "agIDs", "agNamesFull", "agNamesAbbreviated", "agDates", "agReference"),
#'   args    = c("map")
#' )
#'
agIDs               <- antigens_getter("id")
agGroupValues       <- antigens_getter("group_values")
agDates             <- antigens_getter("date")
agReference         <- antigens_getter("reference")
agNames             <- antigens_getter("name")
agNamesFull         <- antigens_getter("name_full")
agNamesAbbreviated  <- antigens_getter("name_abbreviated")

`agNames<-`         <- antigens_setter("name")
`agIDs<-`           <- antigens_setter("id")
`agGroupValues<-`   <- antigens_setter("group_values")
`agDates<-`         <- antigens_setter("date")
`agReference<-`     <- antigens_setter("reference")

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

#' @export
agSequences <- function(map){
  do.call(rbind, lapply(map$antigens, function(ag){ ag$sequence }))
}

#' @export
`agSequences<-` <- function(map, value){
  if(nrow(value) != numAntigens(map)) stop("Number of sequences does not match number of antigens")
  for(x in seq_len(numAntigens(map))){
    map$antigens[[x]]$sequence <- value[x,]
  }
  map
}



