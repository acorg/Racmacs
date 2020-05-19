
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
#' @noRd
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
    ~property,               ~method,                ~object,          ~settable, ~acmacs.r, ~format,   ~description,
    "selected_optimization", "selectedOptimization", "racmap",         TRUE,      FALSE,     "vector",  "The selected optimization number",
    "name",                  "name",                 "chart",          TRUE,      TRUE,      "vector",  "Map name",
    "table_layers",          "titerTableLayers",     "chart",          TRUE,      TRUE,      "vector",  "Titer measurement data",
    "ag_names",              "agNames",              "antigens",       TRUE,      TRUE,      "vector",  "Antigen names",
    "ag_ids",                "agIDs",                "antigens",       TRUE,      FALSE,     "vector",  "Antigen IDs",
    "ag_groups",             "agGroups",             "antigens",       TRUE,      FALSE,     "vector",  "Antigen groups",
    "",                      "agNamesFull",          "antigens",       FALSE,     TRUE,      "vector",  "Full antigen names",
    "",                      "agNamesAbbreviated",   "antigens",       FALSE,     TRUE,      "vector",  "Abbreviated antigen names",
    "ag_dates",              "agDates",              "antigens",       TRUE,      TRUE,      "vector",  "Antigen dates",
    "ag_reference",          "agReference",          "antigens",       TRUE,      TRUE,      "vector",  "Is antigen a reference virus",
    #"" ,                     "",                     "antigens",       TRUE,      TRUE,      "vector",  "Reassortant information",
    #"" ,                     "",                     "antigens",       TRUE,      TRUE,      "vector",  "Antigen lineage",
    #"" ,                     "",                     "antigens",       TRUE,      TRUE,      "vector",  "Passage history",
    #"" ,                     "",                     "antigens",       TRUE,      TRUE,      "vector",  "Lab IDs",
    #"" ,                     "",                     "antigens",       TRUE,      TRUE,      "vector",  "Antigen annotations",
    #"" ,                     "",                     "antigens",       TRUE,      TRUE,      "vector",  "Antigen isolation years",
    "sr_names",              "srNames",               "sera",          TRUE,      TRUE,      "vector",  "Sera names",
    "sr_ids",                "srIDs",                 "sera",          TRUE,      FALSE,     "vector",  "Sera IDs",
    "sr_groups",             "srGroups",              "sera",          TRUE,      FALSE,     "vector",  "Sera groups",
    "",                      "srNamesFull",           "sera",          FALSE,     TRUE,      "vector",  "Full sera names",
    "",                      "srNamesAbbreviated", "sera",             FALSE,     TRUE,      "vector",  "Abbreviated sera names",
    #"" ,                      "",                     "sera",          TRUE,      TRUE,      "vector",  "Sera lineage",
    #"" ,                      "",                     "sera",          TRUE,      TRUE,      "vector",  "Sera reassortant",
    #"" ,                      "",                     "sera",          TRUE,      TRUE,      "vector",  "Sera serum ID",
    #"" ,                      "",                     "sera",          TRUE,      TRUE,      "vector",  "Sera species",
    #"" ,                      "",                     "sera",          TRUE,      TRUE,      "vector",  "Sera passage",
    #"" ,                      "",                     "sera",          TRUE,      TRUE,      "vector",  "Sera annotations",
    #"" ,                      "",                     "sera",          TRUE,      TRUE,      "vector",  "Sera years",
    "ag_shown",               "agShown",              "plotspec",      TRUE,      TRUE,      "vector",  "Antigen shown",
    "ag_size",                "agSize",               "plotspec",      TRUE,      TRUE,      "vector",  "Antigen size",
    "ag_fill",                "agFill",               "plotspec",      TRUE,      TRUE,      "vector",  "Antigen fill color",
    "ag_outline",             "agOutline",            "plotspec",      TRUE,      TRUE,      "vector",  "Antigen outline color",
    "ag_outline_width",       "agOutlineWidth",       "plotspec",      TRUE,      TRUE,      "vector",  "Antigen outline width",
    "ag_rotation",            "agRotation",           "plotspec",      TRUE,      TRUE,      "vector",  "Antigen rotation",
    "ag_aspect",              "agAspect",             "plotspec",      TRUE,      TRUE,      "vector",  "Antigen aspect",
    "ag_shape",               "agShape",              "plotspec",      TRUE,      TRUE,      "vector",  "Antigen shape",
    "ag_drawing_order",       "agDrawingOrder",       "plotspec",      TRUE,      TRUE,      "vector",  "Antigen drawing order",
    "sr_shown",               "srShown",              "plotspec",      TRUE,      TRUE,      "vector",  "Sera shown",
    "sr_size",                "srSize",               "plotspec",      TRUE,      TRUE,      "vector",  "Sera size",
    "sr_fill",                "srFill",               "plotspec",      TRUE,      TRUE,      "vector",  "Sera fill color",
    "sr_outline",             "srOutline",            "plotspec",      TRUE,      TRUE,      "vector",  "Sera outline color",
    "sr_outline_width",       "srOutlineWidth",       "plotspec",      TRUE,      TRUE,      "vector",  "Sera outline width",
    "sr_rotation",            "srRotation",           "plotspec",      TRUE,      TRUE,      "vector",  "Sera rotation",
    "sr_aspect",              "srAspect",             "plotspec",      TRUE,      TRUE,      "vector",  "Sera aspect",
    "sr_shape",               "srShape",              "plotspec",      TRUE,      TRUE,      "vector",  "Sera shape",
    "sr_drawing_order",       "srDrawingOrder",       "plotspec",      TRUE,      TRUE,      "vector",  "Sera drawing order",
    "ag_base_coords",         "agBaseCoords",         "optimization",  TRUE,      TRUE,      "matrix",  "Antigen base coordinates",
    "sr_base_coords",         "srBaseCoords",         "optimization",  TRUE,      TRUE,      "matrix",  "Sera base coordinates",
    "map_comment",            "mapComment",           "optimization",  TRUE,      TRUE,      "vector",  "Map comment",
    "minimum_column_basis",   "minColBasis",          "optimization",  TRUE,      TRUE,      "vector",  "Map minimum column bases",
    "map_dimensions",         "mapDimensions",        "optimization",  FALSE,     TRUE,      "vector",  "Number of map dimensions",
    "map_transformation",     "mapTransformation",    "optimization",  TRUE,      TRUE,      "matrix",  "Map transformation",
    "map_translation",        "mapTranslation",       "optimization",  TRUE,      TRUE,      "matrix",  "Map translation",
    "map_stress",             "mapStress",            "optimization",  FALSE,     TRUE,      "vector",  "Map stress",
    "column_bases",           "colBases",             "optimization",  TRUE,      TRUE,      "vector",  "Map column bases"
  )

  wrappers <- tibble::tribble(
    ~property,               ~method,                ~object,          ~settable, ~acmacs.r, ~format,   ~description,
    "table",                 "titerTable",           "racmap",         TRUE,      FALSE,     "matrix",  "The titer table",
    "ag_coords",             "agCoords",             "optimization",   TRUE,      FALSE,     "matrix",  "Antigen coordinates",
    "sr_coords",             "srCoords",             "optimization",   TRUE,      FALSE,     "matrix",  "Serum coordinates"
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


