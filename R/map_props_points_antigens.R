
# Function factory for antigen getter functions
antigens_getter <- function(fn){
  eval(
    substitute(env = list(
      fn = fn
    ), expr = {
      function(map){
        check.acmap(map)
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
        check.acmap(map)
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
#' `srAttributes()`
#' @family {antigen and sera attribute functions}
#' @eval roxygen_tags(
#'   methods = c(
#'   "agNames", "agNames<-",
#'   "agIDs",   "agIDs<-",
#'   "agDates", "agDates<-",
#'   "agNamesFull",
#'   "agNamesAbbreviated",
#'   "agReference"
#'   ),
#'   args    = c("map")
#' )
#'
agIDs               <- antigens_getter(ac_ag_get_id)
agDates             <- antigens_getter(ac_ag_get_date)
agReference         <- antigens_getter(ac_ag_get_reference)
agNames             <- antigens_getter(ac_ag_get_name)
agNamesFull         <- antigens_getter(ac_ag_get_name_full)
agNamesAbbreviated  <- antigens_getter(ac_ag_get_name_abbreviated)
agGroupValues       <- antigens_getter(ac_ag_get_group) # Not exported

`agIDs<-`               <- antigens_setter(ac_ag_set_id)
`agDates<-`             <- antigens_setter(ac_ag_set_date)
`agReference<-`         <- antigens_setter(ac_ag_set_reference)
`agNames<-`             <- antigens_setter(ac_ag_set_name)
`agNamesFull<-`         <- antigens_setter(ac_ag_set_name_full)
`agNamesAbbreviated<-`  <- antigens_setter(ac_ag_set_name_abbreviated)
`agGroupValues<-`       <- antigens_setter(ac_ag_set_group) # Not exported

#' Getting and setting antigen groups
#'
#' These functions get and set the antigen groupings for a map.
#'
#' @param map The acmap object
#' @param value A character or factor vector of groupings to apply to the antigens
#'
#' @name agGroups
#' @family {antigen and sera attribute functions}

#' @rdname agGroups
#' @export
agGroups <- function(map){

  check.acmap(map)
  aglevels <- map$ag_group_levels
  if(length(aglevels) == 0) return(NULL)
  factor(
    x = aglevels[agGroupValues(map) + 1],
    levels = aglevels
  )

}

#' @rdname agGroups
#' @export
`agGroups<-` <- function(map, value){

  check.acmap(map)
  if(is.null(value)){
    agGroupValues(map) <- 0
    map$ag_group_levels <- NULL
  } else {
    if(!is.factor(value)) value <- as.factor(value)
    agGroupValues(map) <- as.numeric(value) - 1
    map$ag_group_levels <- levels(value)
  }
  map

}


#' Getting and setting antigen sequence information
#'
#' @param map The acmap data object
#' @val A character matrix of sequences with rows equal to the number of antigens
#'
#' @name agSequences
#'

#' @rdname agSequences
#' @export
agSequences <- function(map){
  check.acmap(map)
  do.call(rbind, lapply(map$antigens, function(ag){ strsplit(ag$sequence, "")[[1]] }))
}

#' @rdname agSequences
#' @export
`agSequences<-` <- function(map, value){
  check.acmap(map)
  if(nrow(value) != numAntigens(map)) stop("Number of sequences does not match number of antigens")
  for(x in seq_len(numAntigens(map))){
    map$antigens[[x]]$sequence <- paste0(value[x,], collapse = "")
  }
  map
}

