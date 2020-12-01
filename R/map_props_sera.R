
# Function factory for antigen attribute getter functions
sera_getter <- function(attribute){
  eval(
    substitute(env = list(attribute = attribute), expr = {
      function(map){
        value <- sapply(map$sera, function(sr){ sr[[attribute]] })
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
        value <- unname(value)
        for(x in seq_along(value)){
          map$sera[[x]][[attribute]] <- value[x]
        }
        map
      }
    })
  )
}

# Property checker
checkProperty_sera <- function(map, attribute, value){

  character_attributes <- c("group_value")
  if(attribute %in% character_attributes){
    value <- unname(as.character(value))
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
#'   methods = c("srNames", "srIDs", "srNamesFull", "srNamesAbbreviated"),
#'   args    = c("map")
#' )
#'
srIDs               <- sera_getter("id")
srGroupValues       <- sera_getter("group_value")
srNames             <- sera_getter("name")
srNamesFull         <- sera_getter("name_full")
srNamesAbbreviated  <- sera_getter("name_abbreviated")

`srNames<-`         <- sera_setter("name")
`srIDs<-`           <- sera_setter("id")
`srGroupValues<-`   <- sera_setter("group_value")


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


#' @export
srSequences <- function(map){
  do.call(rbind, lapply(map$sera, function(ag){ ag$sera }))
}

#' @export
`srSequences<-` <- function(map, value){
  if(nrow(value) != numSera(map)) stop("Number of sequences does not match number of antigens")
  for(x in seq_len(numSera(map))){
    map$sera[[x]]$sequence <- value[x,]
  }
  map
}

