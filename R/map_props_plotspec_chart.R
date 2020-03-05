
# Getting point plotspec attributes ----
getProperty_plotspec.racchart <- function(map, attribute){

  # Get attribute and type
  plotspec_attribute <- substr(attribute, 3, nchar(attribute))
  point_type         <- substr(attribute, 1, 2)

  # Get styles
  points <- map$chart$plot_spec$styles
  if(point_type == "ag") points <- points[seq_len(map$chart$number_of_antigens)]
  else                   points <- points[-seq_len(map$chart$number_of_antigens)]

  # Get any number of attributes from a group of antigens
  if(plotspec_attribute == "DrawingOrder"){

    drawing_priority <- draw_order_to_priority(map$chart$plot_spec$drawing_order)
    if(point_type == "ag") drawing_priority[seq_len(map$chart$number_of_antigens)]
    else                   drawing_priority[-seq_len(map$chart$number_of_antigens)]

  } else {
    sapply(points, function(point){

      switch(

        # Attribute to match
        EXPR = plotspec_attribute,

        # Point shown
        Shown = {
          point$shown
        },

        # Point size
        Size = {
          point$size
        },

        # Point fill color
        Fill = {
          point$fill
        },

        # Point outline color
        Outline = {
          point$outline
        },

        # Point outline width
        OutlineWidth = {
          point$outline_width
        },

        # Point rotation
        Rotation = {
          point$rotation
        },

        # Point aspect ratio
        Aspect = {
          point$aspect
        },

        # Point shape
        Shape = {
          point$shape
        },

        # Return an error if no attribute matched
        stop("No matching attribute found for ", attribute, call. = FALSE)

      )

    })
  }

}


# Setting point plotspec attributes ----
setProperty_plotspec.racchart <- function(map, attribute, value){

  # Get attribute and type
  plotspec_attribute <- substr(attribute, 3, nchar(attribute))
  point_type         <- substr(attribute, 1, 2)

  # Get plotspec and indices
  plotspec <- map$chart$plot_spec
  if(point_type == "ag") indices <- seq_len(map$chart$number_of_antigens)
  else                   indices <- seq_len(map$chart$number_of_sera) + map$chart$number_of_antigens

  # Seperate into unique levels
  value_factors <- as.factor(value)
  value_levels  <- levels(value_factors)

  # Apply each unique level
  lapply(value_levels, function(value_level){

    # Get matching indices
    index <- indices[which(value == value_level)]

    # Apply changes
    switch(

      # Attribute to match
      EXPR = plotspec_attribute,

      # Point shown
      Shown = {
        plotspec$set_shown(index, as.logical(value_level))
      },

      # Point size
      Size = {
        plotspec$set_size(index, as.numeric(value_level))
      },

      # Point fill color
      Fill = {
        plotspec$set_fill(index, value_level)
      },

      # Point outline color
      Outline = {
        plotspec$set_outline(index, value_level)
      },

      # Point outline width
      OutlineWidth = {
        plotspec$set_outline_width(index, as.numeric(value_level))
      },

      # Point rotation
      Rotation = {
        plotspec$set_rotation(index, as.numeric(value_level))
      },

      # Point aspect ratio
      Aspect = {
        plotspec$set_aspect(index, as.numeric(value_level))
      },

      # Point shape
      Shape = {
        plotspec$set_shape(index, value_level)
      },

      # Point shape
      DrawingOrder = {
        stop("Drawing order cannot be set on a cpp map")
      },

      # Return an error if no attribute matched
      stop("No matching attribute found for ", attribute, call. = FALSE)

    )

  })

  # Return the map
  map

}
