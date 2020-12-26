
# Function factory for antigen getter functions
antigens_getter <- function(fn){
  eval(
    substitute(env = list(
      fn = fn
    ), expr = {
      function(map){
        sapply(map$antigens, fn)
      }
    })
  )
}

# Function factory for antigen setter functions
antigens_setter <- function(fn){
  eval(
    substitute(env = list(
      fn = fn
    ), expr = {
      function(map, value){
        if(is.null(value)){ stop("Cannot set null value") }
        map$antigens <- lapply(seq_along(map$antigens), function(x){
          fn(map$antigens[[x]], value[x])
        })
        map
      }
    })
  )
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
agIDs               <- antigens_getter(ac_ag_get_id)
agGroupValues       <- antigens_getter(ac_ag_get_group_values)
agDates             <- antigens_getter(ac_ag_get_date)
agReference         <- antigens_getter(ac_ag_get_reference)
agNames             <- antigens_getter(ac_ag_get_name)
agNamesFull         <- antigens_getter(ac_ag_get_name_full)
agNamesAbbreviated  <- antigens_getter(ac_ag_get_name_abbreviated)

`agIDs<-`               <- antigens_setter(ac_ag_set_id)
`agGroupValues<-`       <- antigens_setter(ac_ag_set_group_values)
`agDates<-`             <- antigens_setter(ac_ag_set_date)
`agReference<-`         <- antigens_setter(ac_ag_set_reference)
`agNames<-`             <- antigens_setter(ac_ag_set_name)
`agNamesFull<-`         <- antigens_setter(ac_ag_set_name_full)
`agNamesAbbreviated<-`  <- antigens_setter(ac_ag_set_name_abbreviated)

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



