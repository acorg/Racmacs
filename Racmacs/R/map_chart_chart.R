
# Utility function for finding a map optimization
findOptimization <- function(map, optimization_number){
  if(is.null(optimization_number)) optimization_number <- selectedOptimization(map)
  optimization_number
}

#' @export
numAntigens.racchart <- function(map){
  map$chart$number_of_antigens
}

#' @export
numSera.racchart <- function(map){
  map$chart$number_of_sera
}

#' @export
numPoints.racchart <- function(map){
  map$chart$number_of_points
}


#' @export
numOptimizations.racchart <- function(map){
  map$chart$number_of_projections
}

#' @export
optimizationProperties.racchart <- function(map, properties){

  optimization_property_function_bindings <- list_property_function_bindings("optimization")
  methods <- optimization_property_function_bindings$method[match(properties, optimization_property_function_bindings$property)]

  # Get other attributes needed for labelling
  ag_name_dependent_attributes  <- c("agCoords", "agTransformedCoords")
  sr_name_dependent_attributes  <- c("srCoords", "srTransformedCoords", "colBases")
  ag_num_dependent_attributes   <- c(ag_name_dependent_attributes, sr_name_dependent_attributes)
  titer_table_dependent_attributes <- c("colBases")

  ag_names     <- NULL
  sr_names     <- NULL
  titer_table     <- NULL
  num_antigens <- NULL
  if(sum(ag_name_dependent_attributes  %in% methods) > 0) ag_names     <- agNames(map)
  if(sum(sr_name_dependent_attributes  %in% methods) > 0) sr_names     <- srNames(map)
  if(sum(titer_table_dependent_attributes %in% methods) > 0) titer_table     <- titerTable(map)
  if(sum(ag_num_dependent_attributes   %in% methods) > 0) num_antigens <- map$chart$number_of_antigens

  lapply(map$chart$projections, function(optimization){
    optimization_properties <- getOptimizationAttributes(map,
                                                     optimization,
                                                     methods,
                                                     ag_names     = ag_names,
                                                     sr_names     = sr_names,
                                                     titer_table     = titer_table,
                                                     num_antigens = num_antigens)
    names(optimization_properties) <- properties
    optimization_properties
  })

}



#' @export
removeOptimizations.racchart <- function(map){
  map$chart$remove_all_projections()
  selectedOptimization(map) <- NULL
  map
}

#' @export
keepSingleOptimization.racchart <- function(map, optimization_number = NULL){
  optimization_number <- findOptimization(map, optimization_number)
  map$chart$remove_all_projections_except(optimization_number)
  selectedOptimization(map) <- 1
  map
}

#' @export
selectedOptimization.racchart <- function(map){
  map$racmap$selected_optimization
}

#' @export
set_selectedOptimization.racchart <- function(map, value){
  map$racmap$selected_optimization <- value
  map
}

#' @export
sortOptimizations.racchart <- function(map){
  map$chart$sort_projections()
  selectedOptimization(map) <- 1
  map
}


# apply(list_property_function_bindings("chart"), 1, function(attribute){
#   cat("#", attribute["description"], "\n")
#   cat("#' @export\n")
#   cat(attribute[2], ".racchart <- chartAttributeGetter('", attribute[2],"')\n", sep = "")
#   cat("\n")
#   cat("#' @export\n")
#   cat("set_", attribute[2], ".racchart <- chartAttributeSetter('", attribute[2],"')\n", sep = "")
#   cat("\n\n")
# })

# Getting optimization attributes ---------
getChartAttributes <- function(map,
                               chart,
                               chart_attributes,
                               ag_names     = NULL,
                               sr_names     = NULL,
                               name         = TRUE){

  # Get other attributes needed for labelling
  ag_name_dependent_attributes  <- c("titerTable")
  sr_name_dependent_attributes  <- c("titerTable")

  if(name && is.null(ag_names) && sum(ag_name_dependent_attributes  %in% chart_attributes) > 0) ag_names     <- agNames(map)
  if(name && is.null(sr_names) && sum(sr_name_dependent_attributes  %in% chart_attributes) > 0) sr_names     <- srNames(map)


  # Get any number of attributes from a optimization
  output <- lapply(chart_attributes, function(chart_attribute){

    # Chart name
    if(chart_attribute == "name"){

      return(chart$name)

    }

    # Sera coordinates
    if(chart_attribute == "titerTable"){

      titer_table <- chart$titers$all()
      if(name){
        colnames(titer_table) <- sr_names
        rownames(titer_table) <- ag_names
      }
      return(titer_table)

    }

    # Return an error if no attribute matched
    stop("No matching attribute found for ", chart_attribute, call. = FALSE)

  })

  # Name the outputs and return them
  names(output) <- chart_attributes
  output

}


# Setting chart attributes ------
setChartAttributes <- function(map,
                               chart,
                               chart_attributes,
                               values){

  # Get chart
  chart <- map$chart
  number_of_antigens <- chart$number_of_antigens

  # Get any number of attributes from a optimization
  lapply(chart_attributes, function(chart_attribute){

    # Antigen coordinates
    if(chart_attribute == "name"){

      value <- values[[chart_attribute]]
      if(is.null(value)) value <- ""
      map$chart$name <- value
      return()

    }

    # Sera coordinates
    if(chart_attribute == "titerTable"){

      titers <- map$chart$titers
      new_titers <- values[[chart_attribute]]
      if(is.null(new_titers)) new_titers <- matrix("*", map$chart$number_of_antigens, map$chart$number_of_sera)
      lapply(seq_len(nrow(new_titers)), function(ag){
        lapply(seq_len(ncol(new_titers)), function(sr){
          titers$set_titer(ag, sr, new_titers[ag,sr])
        })
      })
      return()

    }

    # Return an error if no attribute matched
    stop("No matching attribute found for ", chart_attribute, call. = FALSE)

  })

  # Return the updated map
  map

}



# Getter and setter function factories --------
chartAttributeGetter <- function(attribute){

  function(map, name = TRUE){
    chart  <- map$chart
    getChartAttributes(
      map = map,
      chart = chart,
      chart_attributes = attribute,
      name = name
    )[[attribute]]
  }

}

chartAttributeSetter <- function(attribute){

  function(map, value){
    chart <- map$chart
    value_list              <- list()
    value_list[[attribute]] <- value
    setChartAttributes(map, chart, attribute, value_list)
  }

}


# Table name
#' @export
name.racchart <- chartAttributeGetter('name')

#' @export
set_name.racchart <- chartAttributeSetter('name')


# HI table
#' @export
titerTable.racchart <- chartAttributeGetter('titerTable')

#' @export
set_titerTable.racchart <- chartAttributeSetter('titerTable')



