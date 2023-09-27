
#' Getting and setting the map name
#'
#' @name mapName
#' @family map attribute functions
#' @eval roxygen_tags(
#'   methods = c("mapName", "mapName<-"),
#'   args    = c("map")
#' )
#'
mapName <- function(map) {
  check.acmap(map)
  map$name
}

`mapName<-` <- function(map, value) {
  check.acmap(map)
  map$name <- value
  map
}

#' Getting and setting the map description
#'
#' @name mapDescription
#' @family map attribute functions
#' @eval roxygen_tags(
#'   methods = c("mapDescription", "mapDescription<-"),
#'   args    = c("map")
#' )
#'
mapDescription <- function(map) {
  check.acmap(map)
  map$description
}

`mapDescription<-` <- function(map, value) {
  check.acmap(map)
  map$description <- value
  map
}

#' Getting and setting map titers
#'
#' Functions to get and set the map titer table. Note that when setting the
#' titer table like this any titer table layer information is lost, this is
#' normally not a problem unless the map is a result of merging two titer tables
#' together previously and you then go on the merge the titers again.
#'
#' @param map The acmap object
#' @param value A character matrix of titers to set
#'
#' @returns Returns a character matrix of titers.
#'
#' @name titerTable
#' @family map attribute functions
#' @seealso [adjustedTiterTable()], [htmlTiterTable()]
#'

#' @export
#' @rdname titerTable
titerTable <- function(map) {

  check.acmap(map)
  titers <- titerTableFlat(map)
  rownames(titers) <- agNames(map)
  colnames(titers) <- srNames(map)
  titers

}


#' @export
#' @rdname titerTable
`titerTable<-` <- function(map, value) {

  check.acmap(map)

  # Set the flat titer table
  titerTableFlat(map) <- value

  # Set the titer table layers
  titerTableLayers(map) <- list(value)

  # Return the map
  map

}


#' Getting and setting the flat titer table
#'
#' These are underlying functions to get and set the "flat" version of the titer
#' table only. When a map is merged, the titer tables are merged but a record of
#' the original titers associated with each map are kept as titer table layers
#' so that information on the original set of titers that made up the merge is
#' not lost. At the same time, the merged titer version of the titer table is
#' created and saved as the titer_table_flat attribute. When you access titers
#' through the `titerTable()` function, the flat version of the titer table is
#' retrieved (only really a relevant distinction for merged maps). When you set
#' titers through `titerTable<-()` titer table layers are lost. These functions
#' allow you to manipulate the flat version without effecting the titer table
#' layers information.
#'
#' @name titerTableFlat

#' @rdname titerTable
titerTableFlat <- function(map) {
  check.acmap(map)
  map$titer_table_flat
}

#' @rdname titerTable
`titerTableFlat<-` <- function(map, value) {
  check.acmap(map)
  check.dimensions(value, map)
  if (is.data.frame(value)) value <- as.matrix(value)
  check.validtiters(value)
  mode(value)          <- "character"
  map$titer_table_flat <- value
  map
}


#' Getting and setting titer table layers
#'
#' Functions to get and set the underlying titer table layers of a map (see
#' details).
#'
#' @param map The acmap object
#' @param value A list of titer table character vectors to set
#'
#' @details When you merge maps with `mergeMaps()` repeated antigen - serum
#'   titers are merged to create a new titer table but information on the
#'   original titers is not lost. The original titer tables, aligned to their
#'   new positions in the merged table, are kept as separate layers that can be
#'   accessed with these functions. If you have merged a whole bunch of
#'   different maps, these functions can be useful to check for example,
#'   variation in titer seen between a single antigen and serum pair.
#'
#' @returns A list of character matrices of titers.
#'
#' @name titerTableLayers
#' @family map attribute functions
#' @export
#'
titerTableLayers <- function(map) {
  check.acmap(map)
  table_layers <- map$titer_table_layers
  names(table_layers) <- layerNames(map)
  table_layers
}

#' @rdname titerTableLayers
`titerTableLayers<-` <- function(map, value) {

  # Check input
  check.acmap(map)
  if (!is.list(value)) {
    stop("Titer table layers must be a list of titer tables")
  }

  # Update layers
  value <- lapply(value, function(titers) {
    check.dimensions(titers, map)
    if (is.data.frame(titers)) titers <- as.matrix(titers)
    mode(titers) <- "character"
    check.validtiters(titers)
    titers
  })
  map$titer_table_layers <- value

  # Update the flat titer layer
  if (length(value) > 1) {
    titerTableFlat(map) <- ac_merge_titer_layers(value)
  } else {
    titerTableFlat(map) <- value[[1]]
  }

  # Return the updated map
  map

}


#' Return a list of titertypes tables
#'
#' @param map An acmap data object
#'
#' @noRd
titertypesTableLayers <- function(map) {

  lapply(
    titerTableLayers(map),
    function(titertable) {
      matrix(
        titer_types_int(titertable),
        numAntigens(map),
        numSera(map)
      )
    }
  )

}


#' Return a list of logtiter table layers
#'
#' @param map An acmap data object
#'
#' @returns A list of numeric matrices with logtiter values
#'
#' @family map attribute functions
#' @export
logtiterTableLayers <- function(map) {

  lapply(
    titerTableLayers(map),
    function(titertable) {
      matrix(
        log_titers(titertable, dilutionStepsize(map)),
        numAntigens(map),
        numSera(map)
      )
    }
  )

}


#' Get or set the dilution stepsize associated with a map
#'
#' This defaults to 1 but can be changed using this function with knock-on
#' effects for how < values are treated when maps are optimized or relaxed and
#' the way stress is calculated, see details.
#'
#' @param map The acmap object from which to get or set the dilution stepsize
#' @param value The dilution stepsize value to set
#'
#' @returns A number giving the current dilution stepsize setting for a map.
#'
#' @details Antigenic cartography was originally developed for HI titers which
#'   typically follow a 2-fold dilution series starting from 1/10, then 1/20,
#'   1/40 etc. This represents a "dilution stepsize" of 1 when converted to the
#'   log2 scale. When no inhibition was recorded at the highest dilution, the
#'   value is typically recorded as <10 but the optimization regime effectively
#'   treats this as a <=5, the rationale being that, had the dilution series been
#'   continued to higher concentrations, the next lowest titer would have been a
#'   5. Over time the method has also been applied to other neutralization
#'   assays that sometimes have a continuous read out with a lower end, in these
#'   cases a <10 really means a <10 since any other values like 9.8 or 7.62
#'   would also be possible. To indicate these continuous cases, you can specify
#'   the dilution stepsize as 0. Equally, if the dilution regime followed a
#'   different pattern, you can also set that here.
#'
#' @name dilutionStepsize
#' @family map attribute functions
#' @export
#'
dilutionStepsize <- function(map) {

  check.acmap(map)
  if (is.null(map$dilution_stepsize)) {
    1
  } else {
    map$dilution_stepsize
  }

}

#' @export
#' @rdname dilutionStepsize
`dilutionStepsize<-` <- function(map, value) {

  check.acmap(map)
  map$dilution_stepsize <- value
  map

}


#' Sort optimizations by stress
#'
#' Sorts all the optimization runs for a given map object by stress
#' (lowest to highest). Note that this is done by default when running
#' `optimizeMap()`.
#'
#' @param map The acmap object
#'
#' @returns An acmap object with optimizations sorted by stress.
#'
#' @family functions to work with map optimizations
#' @export
sortOptimizations <- function(map) {
  check.acmap(map)
  map$optimizations <- map$optimizations[order(allMapStresses(map))]
  map
}


# Helper function for getting a vector of properties associated with each
# optimization run, like stress
allMapProperties <- function(map, getter) {
  check.acmap(map)
  vapply(
    seq_len(numOptimizations(map)),
    function(i) {
      value <- getter(map, i)
      if (is.null(value)) value <- NA
      value
    },
    numeric(1)
  )
}


#' Get optimization properties
#'
#' Utility functions to get a vector of all the map optimization
#' properties.
#'
#' @param map The acmap object
#'
#' @returns A numeric vector of values
#'
#' @family functions to work with map optimizations
#' @name optimizationProperties

#' @rdname optimizationProperties
#' @export
allMapStresses <- function(map) {
  check.acmap(map)
  allMapProperties(map, mapStress)
}

#' @rdname optimizationProperties
#' @export
allMapDimensions <- function(map) {
  check.acmap(map)
  allMapProperties(map, mapDimensions)
}


#' Remove map optimizations
#'
#' Remove all optimization run data from a map object
#'
#' @param map The acmap object
#'
#' @returns An acmap object with all optimizations removed
#'
#' @family functions to work with map optimizations
#' @export
#'
removeOptimizations <- function(map) {
  check.acmap(map)
  map$optimizations <- NULL
  map
}


#' Keep specified optimization runs
#'
#' Keep only data from specified optimization runs.
#'
#' @param map The acmap object
#' @param optimization_numbers Optimizations to keep
#'
#' @returns Returns the updated acmap object
#'
#' @family functions to work with map optimizations
#'
#' @export
#'
keepOptimizations <- function(map, optimization_numbers) {
  check.numericvector(optimization_numbers)
  check.acmap(map)
  lapply(optimization_numbers, check.optnum, map = map)
  map$optimizations <- map$optimizations[optimization_numbers]
  map
}

#' Keep only a single optimization run
#'
#' @param map The acmap object
#' @param optimization_number The optimization run to keep
#'
#' @returns An acmap object with only one optimization kept
#'
#' @family functions for working with map data
#'
#' @export
#'
keepSingleOptimization <- function(map, optimization_number = 1) {
  keepOptimizations(map, optimization_number)
}

#' Keep only the lowest stress map optimization
#'
#' @param map The acmap object
#'
#' @returns An acmap object with only the lowest stress optimization kept
#'
#' @family functions for working with map data
#'
#' @export
#'
keepBestOptimization <- function(map) {
  map <- sortOptimizations(map)
  keepOptimizations(map, 1)
}


#' Get and set map layer names
#'
#' @param map The acmap object
#' @param value A vector of new layer names to apply to the map
#'
#' @returns A character vector of layer names
#'
#' @family functions for working with map data
#'
#' @name layerNames

#' @rdname layerNames
#' @export
layerNames <- function(map) {
  check.acmap(map)
  layer_names <- map$layer_names
  if (length(layer_names) == 0) layer_names <- NULL
  layer_names
}

#' @rdname layerNames
#' @export
`layerNames<-` <- function(map, value) {
  check.acmap(map)
  if (is.null(value)) {
    map$layer_names <- rep("", numLayers(map))
  } else {
    check.charactervector(value)
    if (length(value) != numLayers(map)) {
      stop("Number of layer names does not match the number of layers", call. = F)
    }
    map$layer_names <- value
  }
  map
}


#' Get and set antigen reactivity adjustments
#'
#' @param map The acmap object
#' @param value A vector of antigen reactivity adjustments to apply
#'
#' @family functions for working with map data
#'
#' @returns A numeric vector of antigen reactivity adjustments
#'
#' @name agReactivityAdjustments

#' @rdname agReactivityAdjustments
#' @export
agReactivityAdjustments <- function(map) {
  check.acmap(map)
  ag_reactivity_adjustments <- map$ag_reactivity_adjustments
  if (is.null(ag_reactivity_adjustments)) ag_reactivity_adjustments <- rep(0, numAntigens(map))
  ag_reactivity_adjustments
}

#' @rdname agReactivityAdjustments
#' @export
`agReactivityAdjustments<-` <- function(map, value) {
  check.acmap(map)
  check.numericvector(value)
  if (length(value) != numAntigens(map)) {
    stop("Number of reactivity adjustments does not match the number of antigens", call. = F)
  }
  map$ag_reactivity_adjustments <- value
  for (n in seq_len(numOptimizations(map))) {
    map$optimizations[[n]]$ag_reactivity_adjustments <- value
  }
  map
}


#' Get acmap attributes
#'
#' Functions to get various attributes about an acmap object.
#'
#' @param map The acmap data object
#'
#' @returns A number relating to the attribute
#'
#' @name acmapAttributes
#' @family map attribute functions
#'

#' @rdname acmapAttributes
#' @export
numAntigens <- function(map) {
  check.acmap(map)
  length(map$antigens)
}

#' @rdname acmapAttributes
#' @export
numSera <- function(map) {
  check.acmap(map)
  length(map$sera)
}

#' @rdname acmapAttributes
#' @export
numSeraGroups <- function(map) {
  length(unique(srGroups(map)))
}

#' @rdname acmapAttributes
#' @export
numPoints <- function(map) {
  check.acmap(map)
  numAntigens(map) + numSera(map)
}

#' @rdname acmapAttributes
#' @export
numOptimizations <- function(map) {
  check.acmap(map)
  length(map$optimizations)
}

#' @rdname acmapAttributes
#' @export
numLayers <- function(map) {
  check.acmap(map)
  length(titerTableLayers(map))
}


