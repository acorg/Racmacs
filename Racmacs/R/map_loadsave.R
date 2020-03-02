
#' Read in acmap data from a file
#'
#' Reads an antigenic map file and converts it into an acmap data object.
#'
#' @param filename Path to the file.
#' @param optimization_number The optimization number to select (defaults to the first, see \code{\link{selectedOptimization}}).
#' @param discard_other_optimizations Should other optimizations be discarded?
#' @param sort_optimizations Should optimizations be sorted in order of stress when the map data is read?
#' @param align_optimizations Should optimizations be rotated and translated to
#'   match each other as closely as possible?
#' @param only_best_optimization Should only the best (lowest stress) optimization
#'   be kept?
#'
#' @return Returns the acmap data object.
#'
#' @example examples/example_make_map_from_scratch.R
#'
#' @export
#'
#' @family functions to create and save acmap objects
read.acmap <- function(
  filename,
  optimization_number         = NULL,
  discard_other_optimizations = FALSE,
  sort_optimizations          = FALSE,
  align_optimizations         = FALSE,
  only_best_optimization      = FALSE
){

  read.mapfile(
    map_format = "racmap",
    filename                    = filename,
    optimization_number         = optimization_number,
    discard_other_optimizations = discard_other_optimizations,
    sort_optimizations          = sort_optimizations,
    align_optimizations         = align_optimizations,
    only_best_optimization      = only_best_optimization
  )

}



#' Read in acmap data from a file in the C++ format
#'
#' Reads an antigenic map file in the C++ format, which may be quicker when
#' performing many optimizations.
#'
#' @param filename Path to the file.
#' @param optimization_number The optimization number to select (defaults to the first, see \code{\link{selectedOptimization}}).
#' @param discard_other_optimizations Should other optimizations be discarded?
#' @param sort_optimizations Should optimizations be sorted in order of stress when the map data is read?
#' @param align_optimizations Should optimizations be rotated and translated to
#'   match each other as closely as possible?
#' @param only_best_optimization Should only the best (lowest stress) optimization
#'   be kept?
#'
#' @return Returns the acmap c++ data object.
#'
#' @example examples/example_make_map_from_scratch.R
#'
#' @export
#'
#' @family functions to create and save acmap objects
#'
read.acmap.cpp <- function(filename,
                           optimization_number = NULL,
                           discard_other_optimizations = FALSE,
                           sort_optimizations          = FALSE,
                           align_optimizations         = FALSE,
                           only_best_optimization      = FALSE){

  read.mapfile(
    map_format = "racchart",
    filename                    = filename,
    optimization_number         = optimization_number,
    discard_other_optimizations = discard_other_optimizations,
    sort_optimizations          = sort_optimizations,
    align_optimizations         = align_optimizations,
    only_best_optimization      = only_best_optimization
  )

}


# Underlying function for reading a map file
read.mapfile <- function(
  map_format,
  filename,
  optimization_number         = NULL,
  discard_other_optimizations = FALSE,
  sort_optimizations          = FALSE,
  align_optimizations         = FALSE,
  only_best_optimization      = FALSE
){

  # Expand the file path and check that the file exists
  if(!file.exists(filename)) stop("File '", filename, "' not found", call. = FALSE)
  file_path <- path.expand(filename)

  # Read in the map file data
  if(map_format == "racmap"){

    json <- read.acmap.json(filename)
    map  <- json_to_racmap(json)

  } else if(map_format == "racchart") {

    # Create the new map
    chart <- suppressMessages({ new(acmacs.r::acmacs.Chart, file_path) })
    map   <- racchart.new(chart = chart)

    # Get transformations from the map object if null in special attribute
    projections         <- chart$projections
    alt_transformations <- get_chartAttribute(map, "transformation")
    map_transformations <- lapply(seq_len(numOptimizations(map)), function(x){ NULL })

    for(n in seq_len(numOptimizations(map))){
      if(is.null(alt_transformations[[n]])){
        map_transformations[[n]] <- projections[[n]]$transformation
      } else {
        map_transformations[[n]] <- alt_transformations[[n]]
      }
    }

    # Set them as the map transformations
    map <- set_chartAttribute(map, "transformation", lapply(map_transformations, as.vector))

    # Get and set bootstrap data
    bootstrap <- map$chart$extension_field("bootstrap")
    if(!is.na(bootstrap)){
      map <- setMapAttribute(map, "bootstrap", bootstrapFromJsonlist(jsonToList(bootstrap)))
    }

  } else {

    # If unrecognised format given
    stop(sprintf("Map format '%s' not recognised", map_format))

  }

  # Set optimization
  if(is.null(optimization_number)){
    if(numOptimizations(map) > 0){
      selectedOptimization(map) <- 1
    }
  } else {
    selectedOptimization(map) <- optimization_number
  }

  # Discard other optimizations if requested
  if(discard_other_optimizations){
    keepSingleOptimization(map, optimization_number)
  }

  if(sort_optimizations || only_best_optimization){

    # Sort optimizations if requested
    map <- sortOptimizations(map)

    # Discard other optimizations if requested
    if(only_best_optimization){
      map <- keepSingleOptimization(map, 1)
    }

  }

  # Return the map
  map

}


#' Save acmap data to a file
#'
#' Save acmap data to a file in a given format, must be one of '.ace', '.save' or '.save.xs' (see details).
#'
#' @param map The acmap data object.
#' @param filename Path to the file.
#'
#' @details Although several file formats are supported, you should save files
#'   with the '.ace' extension. This is the most recent, while the others are
#'   mostly there for backwards compatibility to other software.
#'
#' @export
#'
#' @family functions to create and save acmap objects
#'
save.acmap <- function(map, filename){
  nfilechar <- nchar(filename)
  if(substr(filename, nfilechar-3, nfilechar) != ".ace"
     && substr(filename, nfilechar-4, nfilechar) != ".save"
     && substr(filename, nfilechar-6, nfilechar) != ".save.xs"){
    stop("File format must be one of '.ace', '.save' or '.save.xs'", call. = FALSE)
  }
  UseMethod("save.acmap")
}

#' @export
save.acmap.racmap <- function(map, file){
  chart <- as.cpp(map)
  save.acmap(chart, file)
}

#' @export
save.acmap.racchart <- function(map, file){
  map$chart$save(path.expand(file))
}



#' Save acmap coordinate data to a file
#'
#' Saves acmap coordinate data of all or specified antigens and sera to a .csv file.
#'
#' @param map The acmap data object.
#' @param filename Path to the file.
#'
#' @export
#'
#' @family functions to create and save acmap objects
#'
save.coords <- function(map, filename, antigens = TRUE, sera = TRUE){

  antigens <- get_ag_indices(antigens, map)
  sera     <- get_sr_indices(sera, map)

  nfilechar <- nchar(filename)
  if(substr(filename, nfilechar-3, nfilechar) != ".csv"){
    stop("File format must be .csv")
  }

  type   <- c(rep("antigen", length(antigens)), rep("sera", length(sera)))
  name   <- c(agNames(map)[antigens], srNames(map)[sera])
  coords <- rbind(agCoords(map)[antigens,], srCoords(map)[sera,])
  write.csv(
    x = cbind(type, name, coords),
    file = filename,
    row.names = FALSE
  )

}

#' Save titer data to a file
#'
#' Saves titer data of all or specified antigens and sera to a .csv file.
#'
#' @param map The acmap data object.
#' @param filename Path to the file.
#'
#' @export
#'
#' @family functions to create and save acmap objects
#'
save.titerTable <- function(map, filename, antigens = TRUE, sera = TRUE){

  antigens <- get_ag_indices(antigens, map)
  sera     <- get_sr_indices(sera, map)

  nfilechar <- nchar(filename)
  if(substr(filename, nfilechar-3, nfilechar) != ".csv"){
    stop("File format must be .csv")
  }

  write.csv(
    x = titerTable(map)[antigens, sera],
    file = filename
  )

}





# Set the property and function bindings
# racmap property | method name | part of chart object | settable | type | description
#' @export
list_property_function_bindings <- function(chart_object = NULL){

  bindings <- rbind(
    c("selected_optimization", "selectedOptimization", "racmap",      TRUE,  "vector",  "The selected optimization number"),
    c("name",                  "name",               "chart",         TRUE,  "vector",  "Map name"),
    c("table_layers",          "titerTableLayers",   "chart",         TRUE,  "vector",  "Titer measurement data"),
    #c" ,"",                   "chart",        TRUE,  "vector",  "),
    c("ag_names",              "agNames",            "antigens",      TRUE,  "vector",  "Antigen names"),
    c("ag_ids",                "agIDs",              "antigens",      TRUE,  "vector",  "Antigen IDs"),
    c("",                      "agNamesFull",        "antigens",      FALSE, "vector",  "Full antigen names"),
    c("",                      "agNamesAbbreviated", "antigens",      FALSE, "vector",  "Abbreviated antigen names"),
    c("ag_dates",              "agDates",            "antigens",      TRUE,  "vector",  "Antigen dates"),
    c("ag_reference",          "agReference",        "antigens",      TRUE,  "vector",  "Is antigen a reference virus"),
    #c" ,"",                   "antigens",     TRUE,  "vector",  "Antigen lineage"),
    #c" ,"",                   "antigens",     TRUE,  "vector",  "Reassortant information"),
    #c" ,"",                   "antigens",     TRUE,  "vector",  "Passage history"),
    #c" ,"",                   "antigens",     TRUE,  "vector",  "Lab IDs"),
    #c" ,"",                   "antigens",     TRUE,  "vector",  "Antigen annotations"),
    #c" ,"",                   "antigens",     TRUE,  "vector",  "Antigen isolation years"),
    c("sr_names",              "srNames",            "sera",          TRUE,  "vector",  "Sera names"),
    c("sr_ids",                "srIDs",              "sera",          TRUE,  "vector",  "Sera IDs"),
    c("",                      "srNamesFull",        "sera",          FALSE, "vector",  "Full sera names"),
    c("",                      "srNamesAbbreviated", "sera",          FALSE, "vector",  "Abbreviated sera names"),
    #c" ,"",                   "sera",        TRUE,  "vector",  "Sera lineage"),
    #c" ,"",                   "sera",        TRUE,  "vector",  "Sera reassortant"),
    #c" ,"",                   "sera",        TRUE,  "vector",  "Sera serum ID"),
    #c" ,"",                   "sera",        TRUE,  "vector",  "Sera species"),
    #c" ,"",                   "sera",        TRUE,  "vector",  "Sera passage"),
    #c" ,"",                   "sera",        TRUE,  "vector",  "Sera annotations"),
    #c" ,"",                   "sera",        TRUE,  "vector",  "Sera years"),
    c("ag_shown",               "agShown",            "plotspec",      TRUE,  "vector",  "Antigen shown"),
    c("ag_size",                "agSize",             "plotspec",      TRUE,  "vector",  "Antigen size"),
    c("ag_fill",                "agFill",             "plotspec",      TRUE,  "vector",  "Antigen fill color"),
    c("ag_outline",             "agOutline",          "plotspec",      TRUE,  "vector",  "Antigen outline color"),
    c("ag_outline_width",       "agOutlineWidth",     "plotspec",      TRUE,  "vector",  "Antigen outline width"),
    c("ag_rotation",            "agRotation",         "plotspec",      TRUE,  "vector",  "Antigen rotation"),
    c("ag_aspect",              "agAspect",           "plotspec",      TRUE,  "vector",  "Antigen aspect"),
    c("ag_shape",               "agShape",            "plotspec",      TRUE,  "vector",  "Antigen shape"),
    c("ag_drawing_order",       "agDrawingOrder",     "plotspec",      TRUE,  "vector",  "Antigen drawing order"),
    c("sr_shown",               "srShown",            "plotspec",      TRUE,  "vector",  "Sera shown"),
    c("sr_size",                "srSize",             "plotspec",      TRUE,  "vector",  "Sera size"),
    c("sr_fill",                "srFill",             "plotspec",      TRUE,  "vector",  "Sera fill color"),
    c("sr_outline",             "srOutline",          "plotspec",      TRUE,  "vector",  "Sera outline color"),
    c("sr_outline_width",       "srOutlineWidth",     "plotspec",      TRUE,  "vector",  "Sera outline width"),
    c("sr_rotation",            "srRotation",         "plotspec",      TRUE,  "vector",  "Sera rotation"),
    c("sr_aspect",              "srAspect",           "plotspec",      TRUE,  "vector",  "Sera aspect"),
    c("sr_shape",               "srShape",            "plotspec",      TRUE,  "vector",  "Sera shape"),
    c("sr_drawing_order",       "srDrawingOrder",     "plotspec",      TRUE,  "vector",  "Sera drawing order"),
    c("ag_base_coords",         "agBaseCoords",       "optimization",  TRUE,  "matrix",  "Antigen base coordinates"),
    c("sr_base_coords",         "srBaseCoords",       "optimization",  TRUE,  "matrix",  "Sera base coordinates"),
    c("map_comment",            "mapComment",         "optimization",  TRUE,  "vector",  "Map comment"),
    c("minimum_column_basis",   "minColBasis",        "optimization",  TRUE,  "vector",  "Map minimum column bases"),
    c("map_dimensions",         "mapDimensions",      "optimization",  TRUE,  "matrix",  "Number of map dimensions"),
    c("map_transformation",     "mapTransformation",  "optimization",  TRUE,  "matrix",  "Map transformation"),
    c("map_translation",        "mapTranslation",     "optimization",  TRUE,  "matrix",  "Map translation"),
    c("column_bases",           "colBases",           "optimization",  TRUE,  "vector",  "Map column bases")
  )
  bindings <- as.data.frame(bindings, stringsAsFactors = FALSE)
  colnames(bindings) <- c("property", "method", "object", "settable", "format", "description")
  bindings[["settable"]] <- as.logical(bindings[["settable"]])

  if(!is.null(chart_object)){
    bindings <- subset(bindings, object == chart_object)
  }

  bindings

}


export_property_method_tags <- function(object){

  bindings <- list_property_function_bindings(object)
  c(
    paste0("@export ", bindings$method),
    paste0("@export ", bindings$method, "<-")
  )

}


