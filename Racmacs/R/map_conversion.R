
#' Converting between map formats
#'
#' Functions to convert between the 'racmap' and 'racchart' formats (see details).
#'
#' @param map The map object to be converted.
#'
#' @return Returns the converted map data object.
#'
#' @details There are two map data formats supported within Racmacs termed an
#'   'acmap' and an 'acchart'.
#'
#'   In short, if all you want to do is access the
#'   map data for your own plotting or visualization or analysis, you can
#'   choose the 'acmap' format, which is simply an R \code{\link[base]{list}}.
#'
#'   If you plan to do further manipulation of the map in terms of doing further
#'   optimization runs, diagnostic testing etc. then you should choose the 'acchart'
#'   format.
#'
#'   The reason for this is that the guts of most of the map making functions come
#'   through the package acmacs.r, which uses underlying C++ objects for manipulation
#'   of data. The 'acchart' format manipulates the underlying C++ object directly and
#'   calls methods to make and relax maps, which will be very quick, however each time
#'   a read or write call is made to this object there is some overhead which can
#'   quickly slow down operations like altering all the coordinates in a set of 100
#'   optimizations. In these cases, the list-based 'acmap' format will perform better.
#'
#'   In practise, you shouldn't notice too much difference but if one format is
#'   particularly slow when you think it shouldn't be (often the 'acchart') format,
#'   you may consider using or converting to the other.
#'
#' @name convertingMaps
NULL


#' @rdname convertingMaps
#' @export
as.list.racchart <- function(map, verbose = FALSE){

  # Return the object if already a racmap
  if(class(map)[1] == "racmap"){
    warning("Map object is already of class 'racmap'")
    return(map)
  }

  # Generate a new blank racmap object
  if(verbose) message("Creating new object.")
  racmap <- racmap.new()

  # Get property method bindings
  property_function_bindings <- list_property_function_bindings()

  # Get the antigen properties
  if(verbose) message("Getting antigen properties.")
  antigens <- map$chart$antigens
  agAttributes <- getAntigenAttributes(map,
                                       antigens,
                                       property_function_bindings$method[property_function_bindings$object == "antigens"])
  names(agAttributes) <- property_function_bindings$property[property_function_bindings$object == "antigens"]
  racmap[names(agAttributes)] <- agAttributes


  # Get the sera properties
  if(verbose) message("Getting sera properties.")
  sera <- map$chart$sera
  srAttributes <- getSerumAttributes(map,
                                     sera,
                                     property_function_bindings$method[property_function_bindings$object == "sera"])
  names(srAttributes) <- property_function_bindings$property[property_function_bindings$object == "sera"]
  racmap[names(srAttributes)] <- srAttributes


  # Get the antigen and sera plotspec properties
  plotspec <- map$chart$plot_spec
  points   <- plotspec$styles
  point_attributes <- property_function_bindings$method[property_function_bindings$object == "plotspec"]
  point_attributes <- substr(point_attributes, 3, nchar(point_attributes))
  point_attributes <- unique(point_attributes)

  point_properties <- property_function_bindings$property[property_function_bindings$object == "plotspec"]
  point_properties <- substr(point_properties, 4, nchar(point_properties))
  point_properties <- unique(point_properties)


  ## Antigens
  if(verbose) message("Getting antigen plotspec.")
  ag_indices <- seq_len(numAntigens(map))
  ag_points  <- points[ag_indices]
  agPointAttributes <- getPointAttributes(map,
                                          plotspec,
                                          ag_points,
                                          ag_indices,
                                          point_attributes)
  names(agPointAttributes) <- paste0("ag_", point_properties)
  racmap[names(agPointAttributes)] <- agPointAttributes


  ## Sera
  if(verbose) message("Getting sera plotspec.")
  sr_indices <- seq_len(numSera(map)) + numAntigens(map)
  sr_points  <- points[sr_indices]
  srPointAttributes <- getPointAttributes(map,
                                          plotspec,
                                          sr_points,
                                          sr_indices,
                                          point_attributes)
  names(srPointAttributes) <- paste0("sr_", point_properties)
  racmap[names(srPointAttributes)] <- srPointAttributes

  ## Drawing order
  ptDrawingOrder(racmap) <- ptDrawingOrder(map)

  ## Get the chart properties
  if(verbose) message("Getting chart properties.")
  chart <- map$chart
  chartAttributes <- getChartAttributes(map,
                                        chart,
                                        property_function_bindings$method[property_function_bindings$object == "chart"],
                                        ag_names     = agAttributes$ag_names,
                                        sr_names     = srAttributes$sr_names)
  names(chartAttributes)         <- property_function_bindings$property[property_function_bindings$object == "chart"]
  racmap[names(chartAttributes)] <- chartAttributes

  ## Optimizations
  if(verbose) message("Getting optimizations", appendLF = FALSE)
  optimizations <- map$chart$projections
  optimization_attributes <- property_function_bindings$method[property_function_bindings$object == "optimization"]
  optimization_properties <- property_function_bindings$property[property_function_bindings$object == "optimization"]

  optimizationAttributes <- lapply(optimizations, function(optimization){
    if(verbose) message(".", appendLF = FALSE)
    proj_attributes <- getOptimizationAttributes(map,
                                               optimization,
                                               optimization_attributes,
                                               ag_names     = agAttributes$ag_names,
                                               sr_names     = srAttributes$sr_names,
                                               titer_table     = chartAttributes$table,
                                               num_antigens = length(agAttributes$ag_names))
    names(proj_attributes) <- optimization_properties

    # Deal with fixed column bases
    if(length(optimization$forced_column_bases) > 1 || !is.na(optimization$forced_column_bases)){
      proj_attributes$minimum_column_basis <- "fixed"
    }

    proj_attributes
  })
  racmap$optimizations <- optimizationAttributes
  if(verbose) message("")


  ## Get the racmap properties
  if(verbose) message("Getting racmap properties.")
  racmap_property_function_bindings <- property_function_bindings[property_function_bindings$object == "racmap",,drop=FALSE]
  for(x in seq_len(nrow(racmap_property_function_bindings))){
    getter <- get(racmap_property_function_bindings$method[x])
    setter <- get(paste0(racmap_property_function_bindings$method[x], "<-"))
    racmap <- setter(racmap, getter(map))
  }

  # Copy additional properties
  racmap$diagnostics <- map$diagnostics
  racmap$procrustes  <- map$procrustes

  # Return the updated racmap
  racmap

}



#' @rdname convertingMaps
#' @export
as.cpp <- function(map, warnings = TRUE){

  # Return the object if already a chart
  if(warnings && class(map)[1] == "racchart"){
    warning("Map object is already of class 'racchart'")
    return(map)
  }

  # Generate a new blank chart object
  racchart <- acmap.new(num_antigens = numAntigens(map),
                        num_sera     = numSera(map))

  # Get settable property method bindings
  property_function_bindings <- list_property_function_bindings()
  property_function_bindings <- property_function_bindings[property_function_bindings$settable,,drop=FALSE]


  # Set the chart properties
  chart_property_function_bindings <- property_function_bindings[property_function_bindings$object == "chart"
                                                                 & property_function_bindings$property %in% names(map)
                                                                 & property_function_bindings$settable,]
  chart_properties <- map[chart_property_function_bindings$property]
  names(chart_properties) <- chart_property_function_bindings$method

  racchart <- setChartAttributes(racchart,
                                 racchart$chart,
                                 chart_property_function_bindings$method,
                                 chart_properties)


  # Get and set the antigen properties
  ag_property_function_bindings <- property_function_bindings[property_function_bindings$object == "antigens"
                                                              & property_function_bindings$property %in% names(map)
                                                              & property_function_bindings$settable,]
  ag_properties <- map[ag_property_function_bindings$property]
  names(ag_properties) <- ag_property_function_bindings$method

  racchart <- setAntigenAttributes(racchart           = racchart,
                                   antigens           = racchart$chart$antigens,
                                   antigen_attributes = ag_property_function_bindings$method,
                                   values             = ag_properties,
                                   warnings           = warnings)

  # Get and set the sera properties
  sr_property_function_bindings <- property_function_bindings[property_function_bindings$object == "sera"
                                                              & property_function_bindings$property %in% names(map)
                                                              & property_function_bindings$settable,]
  sr_properties <- map[sr_property_function_bindings$property]
  names(sr_properties) <- sr_property_function_bindings$method

  racchart <- setSerumAttributes(racchart         = racchart,
                                 sera             = racchart$chart$sera,
                                 serum_attributes = sr_property_function_bindings$method,
                                 values           = sr_properties,
                                 warnings         = warnings)

  # Get the antigen and sera plotspec properties
  point_property_function_bindings <- property_function_bindings[property_function_bindings$object == "plotspec"
                                                                 & property_function_bindings$property %in% names(map)
                                                                 & property_function_bindings$settable,]
  ag_point_property_function_bindings <- point_property_function_bindings[substr(point_property_function_bindings$property, 1, 2) == "ag",]
  sr_point_property_function_bindings <- point_property_function_bindings[substr(point_property_function_bindings$property, 1, 2) == "sr",]

  point_methods    <- unique(substr(point_property_function_bindings$method,   3, nchar(point_property_function_bindings$method)))
  point_properties <- unique(substr(point_property_function_bindings$property, 4, nchar(point_property_function_bindings$property)))
  point_values <- lapply(point_properties, function(point_property){
    c(map[[paste0("ag_", point_property)]],
      map[[paste0("sr_", point_property)]])
  })
  names(point_values) <- point_methods

  racchart <- setPointAttributes(racchart         = racchart,
                                 plotspec         = racchart$chart$plot_spec,
                                 point_indices    = seq_len(numPoints(map)),
                                 point_attributes = point_methods,
                                 values           = point_values,
                                 warnings         = warnings)

  # Optimizations
  optimizations <- map$optimizations
  optimization_property_function_bindings <- property_function_bindings[property_function_bindings$object == "optimization"
                                                                      & property_function_bindings$property %in% names(map)
                                                                      & property_function_bindings$settable,]
  optimization_attributes <- optimization_property_function_bindings$method
  optimization_properties <- optimization_property_function_bindings$property

  # Add optimizations
  for(n in seq_along(map$optimizations)){

    optimization <- map$optimizations[[n]]
    racchart <- do.call(
      addOptimization,
      c(list(map      = racchart,
             warnings = warnings),
        optimization[names(optimization) %in% optimization_properties])
    )

  }

  # Set the racmap properties
  racmap_property_function_bindings <- property_function_bindings[property_function_bindings$object == "racmap",,drop=FALSE]
  for(x in seq_len(nrow(racmap_property_function_bindings))){
    getter   <- get(racmap_property_function_bindings$method[x])
    setter   <- get(paste0(racmap_property_function_bindings$method[x], "<-"))
    racchart <- setter(racchart, getter(map))
  }

  # Copy additional properties
  racchart$diagnostics <- map$diagnostics

  # Return the chart
  racchart

}



#' Convert map to json format
#'
#' @param map The map data object
#'
#' @return Returns map data as .ace json format
#' @export
#'
as.json <- function(map){

  UseMethod("as.json", map)

}


#' @export
as.json.racmap <- function(map){

  chart <- as.cpp(map)
  as.json(chart)

}


#' @export
as.json.racchart <- function(map){

  map$chart$save()

}



