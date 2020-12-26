
# Function factory for sera getter functions
sera_getter <- function(fn){
  eval(
    substitute(env = list(
      fn = fn
    ), expr = {
      function(map){
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
#' \code{\link{agAttributes}}
#' @family {antigen and sera attribute functions}
#' @eval roxygen_tags(
#'   methods = c("srNames", "srIDs", "srNamesFull", "srNamesAbbreviated", "srDates", "srReference"),
#'   args    = c("map")
#' )
#'
srIDs               <- sera_getter(ac_sr_get_id)
srGroupValues       <- sera_getter(ac_sr_get_group_values)
srDates             <- sera_getter(ac_sr_get_date)
srReference         <- sera_getter(ac_sr_get_reference)
srNames             <- sera_getter(ac_sr_get_name)
srNamesFull         <- sera_getter(ac_sr_get_name_full)
srNamesAbbreviated  <- sera_getter(ac_sr_get_name_abbreviated)

`srIDs<-`               <- sera_setter(ac_sr_set_id)
`srGroupValues<-`       <- sera_setter(ac_sr_set_group_values)
`srDates<-`             <- sera_setter(ac_sr_set_date)
`srReference<-`         <- sera_setter(ac_sr_set_reference)
`srNames<-`             <- sera_setter(ac_sr_set_name)
`srNamesFull<-`         <- sera_setter(ac_sr_set_name_full)
`srNamesAbbreviated<-`  <- sera_setter(ac_sr_set_name_abbreviated)


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
  do.call(rbind, lapply(map$sera, function(sr){ sr$sera }))
}

#' @export
`srSequences<-` <- function(map, value){
  if(nrow(value) != numSera(map)) stop("Number of sequences does not match number of sera")
  for(x in seq_len(numSera(map))){
    map$sera[[x]]$sequence <- value[x,]
  }
  map
}

