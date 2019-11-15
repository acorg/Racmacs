
# Apply plotspec from another map
#' @export
applyPlotspec.racchart <- function(map, source_map){

  # Get matching antigens and sera
  ag_matches <- match_mapAntigens(map, source_map, warnings = FALSE)
  sr_matches <- match_mapSera(map, source_map, warnings = FALSE)

  # Match up point indices and pairs
  pt_pairs <- data.frame(
    indices = seq_len(numPoints(map)),
    matches = c(ag_matches, sr_matches + numAntigens(source_map))
  )

  # Discard NAs
  pt_pairs <- pt_pairs[!is.na(pt_pairs$matches),,drop=FALSE]
  if(nrow(pt_pairs) == 0){
    warning("No matching points found in the plotspec source map")
    return(map)
  }

  # Get the antigen and sera plotspec properties
  source_plotspec <- source_map$chart$plot_spec
  source_points   <- source_plotspec$styles

  # Get property method bindings
  property_function_bindings <- list_property_function_bindings()
  point_attributes <- property_function_bindings$method[property_function_bindings$object == "plotspec"]
  point_attributes <- substr(point_attributes, 3, nchar(point_attributes))
  point_attributes <- unique(point_attributes)

  ## Get point attributes from the plotspec map
  point_values <- getPointAttributes(racchart = source_map,
                                     plotspec = source_plotspec,
                                     points   = source_points[pt_pairs$matches],
                                     point_indices = pt_pairs$matches,
                                     point_attributes = point_attributes)

  # Get the antigen and sera plotspec properties
  map_plotspec <- map$chart$plot_spec
  map_points   <- map_plotspec$styles

  ## Set point attributes on the main map
  map <- setPointAttributes(racchart         = map,
                            plotspec         = map_plotspec,
                            point_indices    = pt_pairs$indices,
                            point_attributes = point_attributes,
                            values           = point_values,
                            warnings         = FALSE)

  ## Return the updated map
  map

}


# Get the plotspec and point objects from a chart
getRacchartPlotspec <- function(racchart){

  racchart$chart$plot_spec

}


getRacchartPlotspecAntigenPoints <- function(racchart){

  racchart$chart$plot_spec$styles[seq_len(numAntigens(racchart))]

}


getRacchartPlotspecSeraPoints <- function(racchart){

  racchart$chart$plot_spec$styles[numAntigens(racchart) + seq_len(numSera(racchart))]

}


# Getting optimization attributes ---------
#' @export
getPointAttributes <- function(racchart,
                               plotspec,
                               points,
                               point_indices,
                               point_attributes){

  # Get any number of attributes from a group of antigens
  output <- lapply(seq_along(points), function(n){

    point <- points[[n]]
    lapply(point_attributes, function(point_attribute){

      # Point shown
      if(point_attribute == "Shown"){
        return(point$shown)
      }

      # Point size
      if(point_attribute == "Size"){
        return(point$size)
      }

      # Point fill color
      if(point_attribute == "Fill"){
        return(point$fill)
      }

      # Point outline
      if(point_attribute == "Outline"){
        return(point$outline)
      }

      # Point outline width
      if(point_attribute == "OutlineWidth"){
        return(point$outline_width)
      }

      # Point rotation
      if(point_attribute == "Rotation"){
        return(point$rotation)
      }

      # Point aspect ratio
      if(point_attribute == "Aspect"){
        return(point$aspect)
      }

      # Point shape
      if(point_attribute == "Shape"){
        return(point$shape)
      }

      # Skip point drawing order (fetched below)
      if(point_attribute == "DrawingOrder"){
        return(1)
      }

      # Return an error if no attribute matched
      stop("No matching attribute found for ", point_attribute, call. = FALSE)

    })

  })

  # Rotate list
  output <- lapply(seq_along(output[[1]]), function(attribute){
    unlist(lapply(output, function(point){
      point[[attribute]]
    }))
  })
  names(output) <- point_attributes

  # Add information on drawing order
  if("DrawingOrder" %in% point_attributes){
    output[["DrawingOrder"]] <- plotspec$drawing_order[point_indices]
  }

  # Return the outputs
  output

}


# Setting optimization attributes ------
#' @export
setPointAttributes <- function(racchart,
                               plotspec,
                               point_indices,
                               point_attributes,
                               values,
                               warnings = TRUE){

  if(warnings){}

  # Get any number of attributes from a group of antigens
  lapply(point_attributes, function(point_attribute){

    # Point shown
    if(point_attribute == "Shown"){
      point_values  <- values[[point_attribute]]
      value_factors <- as.factor(point_values)
      lapply(levels(value_factors), function(value){
        value <- as.logical(value)
        plotspec$set_shown(point_indices[point_values == value], value)
      })
      return()
    }

    # Point size
    if(point_attribute == "Size"){
      point_values  <- values[[point_attribute]]
      value_factors <- as.factor(point_values)
      lapply(levels(value_factors), function(value){
        value <- as.numeric(value)
        plotspec$set_size(point_indices[point_values == value], value)
      })
      return()
    }

    # Point fill color
    if(point_attribute == "Fill"){
      point_values  <- values[[point_attribute]]
      value_factors <- as.factor(point_values)
      lapply(levels(value_factors), function(value){
        plotspec$set_fill(point_indices[point_values == value], value)
      })
      return()
    }

    # Point outline
    if(point_attribute == "Outline"){
      point_values  <- values[[point_attribute]]
      value_factors <- as.factor(point_values)
      lapply(levels(value_factors), function(value){
        plotspec$set_outline(point_indices[point_values == value], value)
      })
      return()
    }

    # Point outline width
    if(point_attribute == "OutlineWidth"){
      point_values  <- values[[point_attribute]]
      value_factors <- as.factor(point_values)
      lapply(levels(value_factors), function(value){
        value <- as.numeric(value)
        plotspec$set_outline_width(point_indices[point_values == value], value)
      })
      return()
    }

    # Point rotation
    if(point_attribute == "Rotation"){
      point_values  <- values[[point_attribute]]
      value_factors <- as.factor(point_values)
      lapply(levels(value_factors), function(value){
        value <- as.numeric(value)
        plotspec$set_rotation(point_indices[point_values == value], value)
      })
      return()
    }

    # Point aspect ratio
    if(point_attribute == "Aspect"){
      point_values  <- values[[point_attribute]]
      value_factors <- as.factor(point_values)
      lapply(levels(value_factors), function(value){
        value <- as.numeric(value)
        plotspec$set_aspect(point_indices[point_values == value], value)
      })
      return()
    }

    # Point shape
    if(point_attribute == "Shape"){
      point_values  <- values[[point_attribute]]
      value_factors <- as.factor(point_values)
      lapply(levels(value_factors), function(value){
        plotspec$set_shape(point_indices[point_values == value], value)
      })
      return()
    }

    # Skip point drawing order (set below)
    if(point_attribute == "DrawingOrder"){
      return()
    }

    # Return an error if no attribute matched
    stop("No matching attribute found for ", point_attribute, call. = FALSE)

  })

  # Set information on drawing order
  if("DrawingOrder" %in% point_attributes){
    # if(warnings){
    #   warning("Setting of point drawing order to a chart object is not yet supported, attempt was ignored.", call. = FALSE)
    # }
  }

  # Return the updated racchart
  racchart

}


# Getter and setter function factories --------
ptAttributeGetter <- function(attribute){

  pt_type   <- substr(attribute, 1, 2)
  attribute <- substr(attribute, 3, nchar(attribute))

  if(pt_type == "ag"){
    pointGetter  <- getRacchartPlotspecAntigenPoints
    pointIndices <- function(racchart) seq_len(numAntigens(racchart))
  }
  if(pt_type == "sr"){
    pointGetter  <- getRacchartPlotspecSeraPoints
    pointIndices <- function(racchart) seq_len(numSera(racchart)) + numAntigens(racchart)
  }

  function(racchart){
    getPointAttributes(racchart,
                       racchart$chart$plot_spec,
                       pointGetter(racchart),
                       pointIndices(racchart),
                       attribute)[[attribute]]
  }

}

ptAttributeSetter <- function(attribute){

  pt_type   <- substr(attribute, 1, 2)
  attribute <- substr(attribute, 3, nchar(attribute))

  if(pt_type == "ag"){ indicesGetter <- function(racchart) seq_len(numAntigens(racchart))                     }
  if(pt_type == "sr"){ indicesGetter <- function(racchart) seq_len(numSera(racchart)) + numAntigens(racchart) }

  function(racchart, value){
    plotspec                <- getRacchartPlotspec(racchart)
    point_indices           <- indicesGetter(racchart)
    value_list              <- list()
    value_list[[attribute]] <- value
    setPointAttributes(racchart, plotspec, point_indices, attribute, value_list)
  }

}



# Antigen shown
#' @export
agShown.racchart <- ptAttributeGetter('agShown')

#' @export
set_agShown.racchart <- ptAttributeSetter('agShown')



# Antigen size
#' @export
agSize.racchart <- ptAttributeGetter('agSize')

#' @export
set_agSize.racchart <- ptAttributeSetter('agSize')



# Antigen fill color
#' @export
agFill.racchart <- ptAttributeGetter('agFill')

#' @export
set_agFill.racchart <- ptAttributeSetter('agFill')



# Antigen outline color
#' @export
agOutline.racchart <- ptAttributeGetter('agOutline')

#' @export
set_agOutline.racchart <- ptAttributeSetter('agOutline')



# Antigen outline width
#' @export
agOutlineWidth.racchart <- ptAttributeGetter('agOutlineWidth')

#' @export
set_agOutlineWidth.racchart <- ptAttributeSetter('agOutlineWidth')



# Antigen rotation
#' @export
agRotation.racchart <- ptAttributeGetter('agRotation')

#' @export
set_agRotation.racchart <- ptAttributeSetter('agRotation')



# Antigen aspect
#' @export
agAspect.racchart <- ptAttributeGetter('agAspect')

#' @export
set_agAspect.racchart <- ptAttributeSetter('agAspect')



# Antigen shape
#' @export
agShape.racchart <- ptAttributeGetter('agShape')

#' @export
set_agShape.racchart <- ptAttributeSetter('agShape')



# Antigen drawing order
#' @export
agDrawingOrder.racchart <- ptAttributeGetter('agDrawingOrder')

#' @export
set_agDrawingOrder.racchart <- ptAttributeSetter('agDrawingOrder')



# Sera shown
#' @export
srShown.racchart <- ptAttributeGetter('srShown')

#' @export
set_srShown.racchart <- ptAttributeSetter('srShown')



# Sera size
#' @export
srSize.racchart <- ptAttributeGetter('srSize')

#' @export
set_srSize.racchart <- ptAttributeSetter('srSize')



# Sera fill color
#' @export
srFill.racchart <- ptAttributeGetter('srFill')

#' @export
set_srFill.racchart <- ptAttributeSetter('srFill')



# Sera outline color
#' @export
srOutline.racchart <- ptAttributeGetter('srOutline')

#' @export
set_srOutline.racchart <- ptAttributeSetter('srOutline')



# Sera outline width
#' @export
srOutlineWidth.racchart <- ptAttributeGetter('srOutlineWidth')

#' @export
set_srOutlineWidth.racchart <- ptAttributeSetter('srOutlineWidth')



# Sera rotation
#' @export
srRotation.racchart <- ptAttributeGetter('srRotation')

#' @export
set_srRotation.racchart <- ptAttributeSetter('srRotation')



# Sera aspect
#' @export
srAspect.racchart <- ptAttributeGetter('srAspect')

#' @export
set_srAspect.racchart <- ptAttributeSetter('srAspect')



# Sera shape
#' @export
srShape.racchart <- ptAttributeGetter('srShape')

#' @export
set_srShape.racchart <- ptAttributeSetter('srShape')



# Sera drawing order
#' @export
srDrawingOrder.racchart <- ptAttributeGetter('srDrawingOrder')

#' @export
set_srDrawingOrder.racchart <- ptAttributeSetter('srDrawingOrder')



# Point drawing order
#' @export
ptDrawingOrder.racchart <- function(map){
  map$chart$plot_spec$drawing_order
}

#' @export
set_ptDrawingOrder.racchart <- function(map){
  warning("Setting drawing order on cpp maps not yet supported")
  map
}


