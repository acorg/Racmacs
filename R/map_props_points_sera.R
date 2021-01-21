
# Function factory for sera getter functions
sera_getter <- function(fn){
  eval(
    substitute(env = list(
      fn = fn
    ), expr = {
      function(map){
        check.acmap(map)
        sapply(map$sera, fn)
      }
    })
  )
}

# Function factory for sera setter functions
sera_setter <- function(fn){
  eval(
    substitute(env = list(
      fn = fn
    ), expr = {
      function(map, value){
        if(is.null(value)){ stop("Cannot set null value") }
        check.acmap(map)
        map$sera <- lapply(seq_along(map$sera), function(x){
          fn(map$sera[[x]], value[x])
        })
        map
      }
    })
  )
}


#' Getting and setting sera attributes
#'
#' These functions get and set the sera attributes for a map.
#'
#' @name srAttributes
#' @seealso
#' `agAttributes()`
#' @family {antigen and sera attribute functions}
#' @eval roxygen_tags(
#'   methods = c(
#'   "srNames", "srNames<-",
#'   "srIDs",   "srIDs<-",
#'   "srDates", "srDates<-",
#'   "srNamesFull",
#'   "srNamesAbbreviated",
#'   "srReference"
#'   ),
#'   args    = c("map")
#' )
#'
srIDs               <- sera_getter(ac_sr_get_id)
srDates             <- sera_getter(ac_sr_get_date)
srReference         <- sera_getter(ac_sr_get_reference)
srNames             <- sera_getter(ac_sr_get_name)
srNamesFull         <- sera_getter(ac_sr_get_name_full)
srNamesAbbreviated  <- sera_getter(ac_sr_get_name_abbreviated)
srGroupValues       <- sera_getter(ac_sr_get_group)

`srIDs<-`               <- sera_setter(ac_sr_set_id)
`srDates<-`             <- sera_setter(ac_sr_set_date)
`srReference<-`         <- sera_setter(ac_sr_set_reference)
`srNames<-`             <- sera_setter(ac_sr_set_name)
`srNamesFull<-`         <- sera_setter(ac_sr_set_name_full)
`srNamesAbbreviated<-`  <- sera_setter(ac_sr_set_name_abbreviated)
`srGroupValues<-`       <- sera_setter(ac_sr_set_group)


#' Getting and setting sera groups
#'
#' These functions get and set the sera groupings for a map.
#'
#' @param map The acmap object
#' @param value A character or factor vector of groupings to apply to the sera
#'
#' @name srGroups
#' @family {antigen and sera attribute functions}

#' @rdname srGroups
#' @export
srGroups <- function(map){

  check.acmap(map)
  srlevels <- map$sr_group_levels
  if(length(srlevels) == 0) return(NULL)
  factor(
    x = srlevels[srGroupValues(map) + 1],
    levels = srlevels
  )

}

#' @rdname srGroups
#' @export
`srGroups<-` <- function(map, value){

  check.acmap(map)
  if(is.null(value)){
    srGroupValues(map) <- 0
    map$sr_group_levels <- NULL
  } else {
    if(!is.factor(value)) value <- as.factor(value)
    srGroupValues(map) <- as.numeric(value) - 1
    map$sr_group_levels <- levels(value)
  }
  map

}


#' Getting and setting sera sequence information
#'
#' @param map The acmap data object
#' @param val A character matrix of sequences with rows equal to the number of sera
#'
#' @name srSequences
#'

#' @rdname srSequences
#' @export
srSequences <- function(map){
  check.acmap(map)
  do.call(rbind, lapply(map$sera, function(sr){ strsplit(sr$sequence, "")[[1]] }))
}

#' @rdname srSequences
#' @export
`srSequences<-` <- function(map, value){
  check.acmap(map)
  if(nrow(value) != numSera(map)) stop("Number of sequences does not match number of sera")
  for(x in seq_len(numSera(map))){
    map$sera[[x]]$sequence <- paste0(value[x,], collapse = "")
  }
  map
}

