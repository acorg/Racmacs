
# Function factory for plotspec getter functions
plotspec_getter <- function(pttype, fn){
  eval(
    substitute(env = list(
      pttype = pttype,
      fn = fn
    ), expr = {
      if(pttype == "ag"){
        function(map){
          check.acmap(map)
          sapply(map$antigens, fn)
        }
      } else {
        function(map, value){
          check.acmap(map)
          sapply(map$sera, fn)
        }
      }
    })
  )
}

# Function factory for plotspec setter functions
plotspec_setter <- function(pttype, fn, checker_fn = NULL){
  eval(
    substitute(env = list(
      pttype = pttype,
      fn = fn
    ), expr = {
      if(pttype == "ag"){
        function(map, value){
          check.acmap(map)
          if(is.null(value)){ stop("Cannot set null value") }
          if(!is.null(checker_fn)){ checker_fn(value) }
          if(length(value) == 1){
            value <- rep_len(value, numAntigens(map))
          } else if(length(value) != numAntigens(map)){
            stop("Input does not match the number of antigens", call. = FALSE)
          }
          map$antigens <- lapply(seq_along(map$antigens), function(x){
            fn(map$antigens[[x]], value[x])
          })
          map
        }
      } else {
        function(map, value){
          check.acmap(map)
          if(is.null(value)){ stop("Cannot set null value") }
          if(!is.null(checker_fn)){ checker_fn(value) }
          if(length(value) == 1){
            value <- rep_len(value, numSera(map))
          } else if(length(value) != numSera(map)){
            stop("Input does not match the number of sera", call. = FALSE)
          }
          map$sera <- lapply(seq_along(map$sera), function(x){
            fn(map$sera[[x]], value[x])
          })
          map
        }
      }
    })
  )
}


#' Getting and setting point plotting styles
#'
#' These functions get and set the styles to use for each point when plotting.
#'
#' @name ptStyles
#' @family {map point style functions}
#' @eval roxygen_tags(
#'   methods = c(
#'   "agShown", "srShown", "agShown<-", "srShown<-",
#'   "agSize", "srSize", "agSize<-", "srSize<-",
#'   "agFill", "srFill", "agFill<-", "srFill<-",
#'   "agOutline", "srOutline", "agOutline<-", "srOutline<-",
#'   "agOutlineWidth", "srOutlineWidth", "agOutlineWidth<-", "srOutlineWidth<-",
#'   "agRotation", "srRotation", "agRotation<-", "srRotation<-",
#'   "agAspect", "srAspect", "agAspect<-", "srAspect<-",
#'   "agShape", "srShape", "agShape<-", "srShape<-",
#'   ),
#'   args = c("map")
#' )
#'
agShown        <- plotspec_getter("ag", ac_ag_get_shown)
agSize         <- plotspec_getter("ag", ac_ag_get_size)
agFill         <- plotspec_getter("ag", ac_ag_get_fill)
agOutline      <- plotspec_getter("ag", ac_ag_get_outline)
agOutlineWidth <- plotspec_getter("ag", ac_ag_get_outline_width)
agRotation     <- plotspec_getter("ag", ac_ag_get_rotation)
agAspect       <- plotspec_getter("ag", ac_ag_get_aspect)
agShape        <- plotspec_getter("ag", ac_ag_get_shape)
srShown        <- plotspec_getter("sr", ac_sr_get_shown)
srSize         <- plotspec_getter("sr", ac_sr_get_size)
srFill         <- plotspec_getter("sr", ac_sr_get_fill)
srOutline      <- plotspec_getter("sr", ac_sr_get_outline)
srOutlineWidth <- plotspec_getter("sr", ac_sr_get_outline_width)
srRotation     <- plotspec_getter("sr", ac_sr_get_rotation)
srAspect       <- plotspec_getter("sr", ac_sr_get_aspect)
srShape        <- plotspec_getter("sr", ac_sr_get_shape)

`agShown<-`        <- plotspec_setter("ag", ac_ag_set_shown, check.logicalvector)
`agSize<-`         <- plotspec_setter("ag", ac_ag_set_size, check.numericvector)
`agFill_raw<-`     <- plotspec_setter("ag", ac_ag_set_fill, check.charactervector)
`agOutline_raw<-`  <- plotspec_setter("ag", ac_ag_set_outline, check.charactervector)
`agOutlineWidth<-` <- plotspec_setter("ag", ac_ag_set_outline_width, check.numericvector)
`agRotation<-`     <- plotspec_setter("ag", ac_ag_set_rotation, check.numericvector)
`agAspect<-`       <- plotspec_setter("ag", ac_ag_set_aspect, check.numericvector)
`agShape<-`        <- plotspec_setter("ag", ac_ag_set_shape, check.charactervector)
`srShown<-`        <- plotspec_setter("sr", ac_sr_set_shown, check.logicalvector)
`srSize<-`         <- plotspec_setter("sr", ac_sr_set_size, check.numericvector)
`srFill_raw<-`     <- plotspec_setter("sr", ac_sr_set_fill, check.charactervector)
`srOutline_raw<-`  <- plotspec_setter("sr", ac_sr_set_outline, check.charactervector)
`srOutlineWidth<-` <- plotspec_setter("sr", ac_sr_set_outline_width, check.numericvector)
`srRotation<-`     <- plotspec_setter("sr", ac_sr_set_rotation, check.numericvector)
`srAspect<-`       <- plotspec_setter("sr", ac_sr_set_aspect, check.numericvector)
`srShape<-`        <- plotspec_setter("sr", ac_sr_set_shape, check.charactervector)

# Extra functions that include a color validation step
validate_colors <- function(cols){
  tryCatch(
    col2rgb(cols),
    error = function(e){
      stop(e$message, call. = FALSE)
    }
  )
}

`agFill<-` <- function(map, value){
  validate_colors(value)
  `agFill_raw<-`(map, value)
}

`srFill<-` <- function(map, value){
  validate_colors(value)
  `srFill_raw<-`(map, value)
}

`agOutline<-` <- function(map, value){
  validate_colors(value)
  `agOutline_raw<-`(map, value)
}

`srOutline<-` <- function(map, value){
  validate_colors(value)
  `srOutline_raw<-`(map, value)
}


# Functions that set point drawing order
#' @export
ptDrawingOrder <- function(map){
  drawing_order <- map$pt_drawing_order
  if(is.null(drawing_order)) drawing_order <- seq_len(numPoints(map))
  drawing_order
}

#' @export
`ptDrawingOrder<-` <- function(map, value){
  if(!is.numeric(value)) stop("drawing order must be numeric", call. = FALSE)
  if(sort(value) != seq_along(value)) stop("drawing incorrectly specified", call. = FALSE)
  map$pt_drawing_order <- value
  map
}

