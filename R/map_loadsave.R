
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
#' @family {functions for working with map data}
#'
#' @export
#'
read.acmap <- function(
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

  # Read the map from the file
  json <- read.acmap.json(filename)
  map  <- json_to_racmap(json)

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

  # Align optimizations if requested
  if(align_optimizations){
    map <- realignOptimizations(map)
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
#' @family {functions for working with map data}
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
#' @family {functions for working with map data}
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
#' @family {functions for working with map data}
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
list_property_function_bindings <- function(
  chart_object = NULL,
  include_wrappers = FALSE,
  method = NULL
  ){

  bindings <- tibble::tribble(
    ~property,               ~method,                ~object,          ~settable, ~subsettable, ~acmacs.r, ~format,   ~description,
    "selected_optimization", "selectedOptimization", "racmap",         TRUE,      TRUE,         FALSE,     "vector",  "The selected optimization number",
    "name",                  "mapName",              "chart",          TRUE,      TRUE,         TRUE,      "vector",  "Map name",
    "table_layers",          "titerTableLayers",     "chart",          TRUE,      TRUE,         TRUE,      "vector",  "Titer measurement data",
    "ag_names",              "agNames",              "antigens",       TRUE,      TRUE,         TRUE,      "vector",  "Antigen names",
    "ag_ids",                "agIDs",                "antigens",       TRUE,      TRUE,         FALSE,     "vector",  "Antigen IDs",
    "ag_group_values",       "agGroupValues",        "antigens",       TRUE,      TRUE,         FALSE,     "vector",  "Antigen group values",
    "ag_group_levels",       "agGroupLevels",        "antigens",       TRUE,      FALSE,        FALSE,     "vector",  "Antigen group levels",
    "ag_sequences",          "agSequences",          "antigens",       TRUE,      TRUE,         FALSE,     "matrix",  "Antigen sequences",
    "",                      "agNamesFull",          "antigens",       FALSE,     TRUE,         TRUE,      "vector",  "Full antigen names",
    "",                      "agNamesAbbreviated",   "antigens",       FALSE,     TRUE,         TRUE,      "vector",  "Abbreviated antigen names",
    "ag_dates",              "agDates",              "antigens",       TRUE,      TRUE,         TRUE,      "vector",  "Antigen dates",
    "ag_reference",          "agReference",          "antigens",       TRUE,      TRUE,         TRUE,      "vector",  "Is antigen a reference virus",
    #"" ,                     "",                     "antigens",       TRUE,     TRUE,          TRUE,      "vector",  "Reassortant information",
    #"" ,                     "",                     "antigens",       TRUE,     TRUE,          TRUE,      "vector",  "Antigen lineage",
    #"" ,                     "",                     "antigens",       TRUE,     TRUE,          TRUE,      "vector",  "Passage history",
    #"" ,                     "",                     "antigens",       TRUE,     TRUE,          TRUE,      "vector",  "Lab IDs",
    #"" ,                     "",                     "antigens",       TRUE,     TRUE,          TRUE,      "vector",  "Antigen annotations",
    #"" ,                     "",                     "antigens",       TRUE,     TRUE,          TRUE,      "vector",  "Antigen isolation years",
    "sr_names",              "srNames",               "sera",          TRUE,      TRUE,         TRUE,      "vector",  "Sera names",
    "sr_ids",                "srIDs",                 "sera",          TRUE,      TRUE,         FALSE,     "vector",  "Sera IDs",
    "sr_group_values",       "srGroupValues",         "sera",          TRUE,      TRUE,         FALSE,     "vector",  "Sera group values",
    "sr_group_levels",       "srGroupLevels",         "sera",          TRUE,      FALSE,        FALSE,     "vector",  "Sera group levels",
    "",                      "srNamesFull",           "sera",          FALSE,     TRUE,         TRUE,      "vector",  "Full sera names",
    "",                      "srNamesAbbreviated", "sera",             FALSE,     TRUE,         TRUE,      "vector",  "Abbreviated sera names",
    "sr_sequences",          "srSequences",           "sera",          TRUE,      TRUE,         FALSE,     "matrix",  "Sera sequences",
    #"" ,                      "",                     "sera",          TRUE,     TRUE,          TRUE,      "vector",  "Sera lineage",
    #"" ,                      "",                     "sera",          TRUE,     TRUE,          TRUE,      "vector",  "Sera reassortant",
    #"" ,                      "",                     "sera",          TRUE,     TRUE,          TRUE,      "vector",  "Sera serum ID",
    #"" ,                      "",                     "sera",          TRUE,     TRUE,          TRUE,      "vector",  "Sera species",
    #"" ,                      "",                     "sera",          TRUE,     TRUE,          TRUE,      "vector",  "Sera passage",
    #"" ,                      "",                     "sera",          TRUE,     TRUE,          TRUE,      "vector",  "Sera annotations",
    #"" ,                      "",                     "sera",          TRUE,     TRUE,          TRUE,      "vector",  "Sera years",
    "ag_shown",               "agShown",              "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Antigen shown",
    "ag_size",                "agSize",               "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Antigen size",
    "ag_fill",                "agFill",               "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Antigen fill color",
    "ag_outline",             "agOutline",            "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Antigen outline color",
    "ag_outline_width",       "agOutlineWidth",       "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Antigen outline width",
    "ag_rotation",            "agRotation",           "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Antigen rotation",
    "ag_aspect",              "agAspect",             "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Antigen aspect",
    "ag_shape",               "agShape",              "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Antigen shape",
    "ag_drawing_order",       "agDrawingOrder",       "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Antigen drawing order",
    "sr_shown",               "srShown",              "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Sera shown",
    "sr_size",                "srSize",               "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Sera size",
    "sr_fill",                "srFill",               "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Sera fill color",
    "sr_outline",             "srOutline",            "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Sera outline color",
    "sr_outline_width",       "srOutlineWidth",       "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Sera outline width",
    "sr_rotation",            "srRotation",           "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Sera rotation",
    "sr_aspect",              "srAspect",             "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Sera aspect",
    "sr_shape",               "srShape",              "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Sera shape",
    "sr_drawing_order",       "srDrawingOrder",       "plotspec",      TRUE,      TRUE,         TRUE,      "vector",  "Sera drawing order",
    "ag_base_coords",         "agBaseCoords",         "optimization",  TRUE,      TRUE,         TRUE,      "matrix",  "Antigen base coordinates",
    "sr_base_coords",         "srBaseCoords",         "optimization",  TRUE,      TRUE,         TRUE,      "matrix",  "Sera base coordinates",
    "map_comment",            "mapComment",           "optimization",  TRUE,      TRUE,         TRUE,      "vector",  "Map comment",
    "minimum_column_basis",   "minColBasis",          "optimization",  TRUE,      TRUE,         TRUE,      "vector",  "Map minimum column bases",
    "map_dimensions",         "mapDimensions",        "optimization",  FALSE,     TRUE,         TRUE,      "vector",  "Number of map dimensions",
    "map_transformation",     "mapTransformation",    "optimization",  TRUE,      TRUE,         TRUE,      "matrix",  "Map transformation",
    "map_translation",        "mapTranslation",       "optimization",  TRUE,      TRUE,         TRUE,      "matrix",  "Map translation",
    "map_stress",             "mapStress",            "optimization",  FALSE,     TRUE,         TRUE,      "vector",  "Map stress",
    "column_bases",           "colBases",             "optimization",  TRUE,      TRUE,         TRUE,      "vector",  "Map column bases"
  )

  wrappers <- tibble::tribble(
    ~property,               ~method,                ~object,          ~settable, ~subsettable, ~acmacs.r, ~format,   ~description,
    "table",                 "titerTable",           "racmap",         TRUE,      TRUE,         FALSE,     "matrix",  "The titer table",
    "ag_coords",             "agCoords",             "optimization",   TRUE,      TRUE,         FALSE,     "matrix",  "Antigen coordinates",
    "sr_coords",             "srCoords",             "optimization",   TRUE,      TRUE,         FALSE,     "matrix",  "Serum coordinates"
  )

  if(!is.null(method)){
    return(bindings[bindings$method == method,,drop=F])
  }

  if(!is.null(chart_object)){
    bindings <- subset(bindings, object %in% chart_object)
  }

  if(include_wrappers){
    bindings <- rbind(wrappers, bindings)
  }

  bindings

}


