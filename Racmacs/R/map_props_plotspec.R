
#' Strains in an antigenic map
#'
#' @param map The map object
#' @param value Value to be used (recycled as necessary)
#' @name mapStrains
#'
#' @return Returns an updated racmap object
#' @eval export_property_method_tags("plotspec")
#'
NULL

# Getter
plotspec_getter <- function(attribute){
  function(map){
    attribute <- attribute
    value <- classSwitch("getProperty_plotspec", map, attribute)
    plotspec_default(map, attribute, value)
  }
}

# Setter
plotspec_setter <- function(attribute){
  function(map, .check = TRUE, value){
    if(.check){
      value <- checkProperty_plotspec(map, attribute, value)
    }
    classSwitch("setProperty_plotspec", map, attribute, value)
  }
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
plotspec_default <- function(map, attribute, value){

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

# Bind the methods
bindObjectMethods("plotspec")


