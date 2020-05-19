
# Function factory for plotspec getter functions
plotspec_getter <- function(attribute){
  eval(
    substitute(env = list(attribute = attribute), expr = {
      function(map){
        value <- classSwitch("getProperty_plotspec", map, attribute)
        defaultProperty_plotspec(map, attribute, value)
      }
    })
  )
}

# Function factory for plotspec setter functions
plotspec_setter <- function(attribute){
  eval(
    substitute(env = list(attribute = attribute), expr = {
      function(map, .check = TRUE, value){
        if(.check) value <- checkProperty_plotspec(map, attribute, value)
        classSwitch("setProperty_plotspec", map, attribute, value)
      }
    })
  )
}


# Property checker
checkProperty_plotspec <- function(map, attribute, value){

  # Get attribute and type
  plotspec_attribute <- substr(attribute, 3, nchar(attribute))
  point_type         <- substr(attribute, 1, 2)

  # Get number of points
  if(point_type == "ag") num_points <- numAntigens(map); point_type_long <- "antigens"
  if(point_type == "sr") num_points <- numSera(map);     point_type_long <- "sera"

  # Repeat length 1 to match points
  if(length(value) == 1) value <- rep(value, num_points)

  # Check value lengths
  if(length(value) != num_points){
    stop(sprintf("Number of %s does not match number of %s in the map", attribute, point_type_long))
  }

  # Return the value
  value

}

# For setting defaults
defaultProperty_plotspec <- function(map, attribute, value){

  if(is.null(value)){

    num_antigens <- numAntigens(map)
    num_sera     <- numSera(map)

    value <- switch(
      attribute,

      agFill         = rep("green", num_antigens),
      agOutline      = rep("black", num_antigens),
      agAspect       = rep(1, num_antigens),
      agRotation     = rep(0, num_antigens),
      agOutlineWidth = rep(1, num_antigens),
      agDrawingOrder = rep(1, num_antigens),
      agShape        = rep("CIRCLE", num_antigens),
      agSize         = rep(5, num_antigens),
      agShown        = rep(TRUE, num_antigens),

      srFill         = rep("transparent", num_sera),
      srOutline      = rep("black", num_sera),
      srAspect       = rep(1, num_sera),
      srRotation     = rep(0, num_sera),
      srOutlineWidth = rep(1, num_sera),
      srDrawingOrder = rep(1, num_sera),
      srShape        = rep("BOX", num_sera),
      srSize         = rep(5, num_sera),
      srShown        = rep(TRUE, num_sera)
    )

  }

  value

}

# Converting draw priority
draw_order_to_priority <- function(drawing_order){

  if(isTRUE(all.equal(drawing_order, seq_along(drawing_order)))) rep_len(1, length(drawing_order))
  else                                                           order(drawing_order)

}

draw_priority_to_order <- function(drawing_priority){

  seq_along(drawing_priority)[order(drawing_priority)]

}

#' Getting and setting point plotting styles
#'
#' These functions get and set the styles to use for each point when plotting.
#'
#' @name ptStyles
#' @family {map point style functions}
#' @eval roxygen_tags(
#'   methods = c("agShown", "agSize", "agFill", "agOutline",
#'   "agOutlineWidth", "agRotation", "agAspect", "agShape", "agDrawingOrder",
#'   "srShown", "srSize", "srFill", "srOutline", "srOutlineWidth", "srRotation",
#'   "srAspect", "srShape", "srDrawingOrder"),
#'   args = c("map"),
#'   getterargs = NULL,
#'   setterargs = NULL
#' )
#'
agShown        <- plotspec_getter("agShown")
agSize         <- plotspec_getter("agSize")
agFill         <- plotspec_getter("agFill")
agOutline      <- plotspec_getter("agOutline")
agOutlineWidth <- plotspec_getter("agOutlineWidth")
agRotation     <- plotspec_getter("agRotation")
agAspect       <- plotspec_getter("agAspect")
agShape        <- plotspec_getter("agShape")
agDrawingOrder <- plotspec_getter("agDrawingOrder")
srShown        <- plotspec_getter("srShown")
srSize         <- plotspec_getter("srSize")
srFill         <- plotspec_getter("srFill")
srOutline      <- plotspec_getter("srOutline")
srOutlineWidth <- plotspec_getter("srOutlineWidth")
srRotation     <- plotspec_getter("srRotation")
srAspect       <- plotspec_getter("srAspect")
srShape        <- plotspec_getter("srShape")
srDrawingOrder <- plotspec_getter("srDrawingOrder")

`agShown<-`        <- plotspec_setter("agShown")
`agSize<-`         <- plotspec_setter("agSize")
`agFill<-`         <- plotspec_setter("agFill")
`agOutline<-`      <- plotspec_setter("agOutline")
`agOutlineWidth<-` <- plotspec_setter("agOutlineWidth")
`agRotation<-`     <- plotspec_setter("agRotation")
`agAspect<-`       <- plotspec_setter("agAspect")
`agShape<-`        <- plotspec_setter("agShape")
`agDrawingOrder<-` <- plotspec_setter("agDrawingOrder")
`srShown<-`        <- plotspec_setter("srShown")
`srSize<-`         <- plotspec_setter("srSize")
`srFill<-`         <- plotspec_setter("srFill")
`srOutline<-`      <- plotspec_setter("srOutline")
`srOutlineWidth<-` <- plotspec_setter("srOutlineWidth")
`srRotation<-`     <- plotspec_setter("srRotation")
`srAspect<-`       <- plotspec_setter("srAspect")
`srShape<-`        <- plotspec_setter("srShape")
`srDrawingOrder<-` <- plotspec_setter("srDrawingOrder")


