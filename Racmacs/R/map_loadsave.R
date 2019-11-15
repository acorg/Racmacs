
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
read.acmap <- function(filename,
                       optimization_number = NULL,
                       discard_other_optimizations = FALSE,
                       sort_optimizations          = FALSE,
                       align_optimizations         = FALSE,
                       only_best_optimization      = FALSE){

  as.list(
    read.acmap.cpp(
      filename = filename,
      optimization_number = optimization_number,
      discard_other_optimizations = discard_other_optimizations,
      sort_optimizations = sort_optimizations,
      align_optimizations = align_optimizations,
      only_best_optimization = only_best_optimization
    )
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

  # Expand the file path and check that the file exists
  if(!file.exists(filename)) stop("File '", filename, "' not found", call. = FALSE)
  file_path <- path.expand(filename)

  # Read in chart and attach include it in the racchart
  chart     <- suppressMessages({ new(acmacs.r::acmacs.Chart, file_path) })
  racchart  <- acmap.new(chart = chart)

  # Set optimization
  if(is.null(optimization_number)){
    if(numOptimizations(racchart) > 0){
      selectedOptimization(racchart) <- 1
    }
  } else {
    selectedOptimization(racchart) <- optimization_number
  }

  # Discard other optimizations if requested
  if(discard_other_optimizations){
    keepSingleOptimization(racchart, )
  }

  if(sort_optimizations || only_best_optimization){

    # Sort optimizations if requested
    racchart <- sortOptimizations(racchart)

    # Discard other optimizations if requested
    if(only_best_optimization){
      racchart <- keepSingleOptimization(racchart, 1)
    }

  }

  # Return the racchart
  racchart

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
    c("selected_optimization","selectedOptimization", "racmap",      TRUE,  "vector",  "The selected optimization number"),
    c("table_name",           "name",               "chart",       TRUE,  "vector",  "Table name"),
    c("table",                "titerTable",         "chart",       TRUE,  "vector",  "Titer measurement data"),
    #c("batch_runs",          "",                   "chart",       TRUE,  "vector",  "),
    c("ag_names",             "agNames",            "antigens",    TRUE,  "vector",  "Antigen names"),
    c("ag_full_name",         "agNamesFull",        "antigens",    FALSE, "vector",  "Full antigen names"),
    c("ag_abbreviated_name",  "agNamesAbbreviated", "antigens",    FALSE, "vector",  "Abbreviated antigen names"),
    c("ag_date",              "agDates",            "antigens",    TRUE,  "vector",  "Antigen dates"),
    c("ag_reference",         "agReference",        "antigens",    TRUE,  "vector",  "Is antigen a reference virus"),
    #c("ag_lineage",          "",                   "antigens",    TRUE,  "vector",  "Antigen lineage"),
    #c("ag_reassortant",      "",                   "antigens",    TRUE,  "vector",  "Reassortant information"),
    #c("ag_passage",          "",                   "antigens",    TRUE,  "vector",  "Passage history"),
    #c("ag_lab_ids",          "",                   "antigens",    TRUE,  "vector",  "Lab IDs"),
    #c("ag_annotations",      "",                   "antigens",    TRUE,  "vector",  "Antigen annotations"),
    #c("ag_years",            "",                   "antigens",    TRUE,  "vector",  "Antigen isolation years"),
    c("sr_names",             "srNames",            "sera",        TRUE,  "vector",  "Sera names"),
    c("sr_full_name",         "srNamesFull",        "sera",        FALSE, "vector",  "Full sera names"),
    c("sr_abbreviated_name",  "srNamesAbbreviated", "sera",        FALSE, "vector",  "Abbreviated sera names"),
    #c("sr_lineage",          "",                   "sera",        TRUE,  "vector",  "Sera lineage"),
    #c("sr_reassortant",      "",                   "sera",        TRUE,  "vector",  "Sera reassortant"),
    #c("sr_serum_id",         "",                   "sera",        TRUE,  "vector",  "Sera serum ID"),
    #c("sr_serum_species",    "",                   "sera",        TRUE,  "vector",  "Sera species"),
    #c("sr_passage",          "",                   "sera",        TRUE,  "vector",  "Sera passage"),
    #c("sr_annotations",      "",                   "sera",        TRUE,  "vector",  "Sera annotations"),
    #c("sr_years",            "",                   "sera",        TRUE,  "vector",  "Sera years"),
    c("ag_shown",             "agShown",            "plotspec",    TRUE,  "vector",  "Antigen shown"),
    c("ag_size",              "agSize",             "plotspec",    TRUE,  "vector",  "Antigen size"),
    c("ag_cols_fill",         "agFill",             "plotspec",    TRUE,  "vector",  "Antigen fill color"),
    c("ag_cols_outline",      "agOutline",          "plotspec",    TRUE,  "vector",  "Antigen outline color"),
    c("ag_outline_width",     "agOutlineWidth",     "plotspec",    TRUE,  "vector",  "Antigen outline width"),
    c("ag_rotation",          "agRotation",         "plotspec",    TRUE,  "vector",  "Antigen rotation"),
    c("ag_aspect",            "agAspect",           "plotspec",    TRUE,  "vector",  "Antigen aspect"),
    c("ag_shape",             "agShape",            "plotspec",    TRUE,  "vector",  "Antigen shape"),
    c("ag_drawing_order",     "agDrawingOrder",     "plotspec",    TRUE,  "vector",  "Antigen drawing order"),
    c("sr_shown",             "srShown",            "plotspec",    TRUE,  "vector",  "Sera shown"),
    c("sr_size",              "srSize",             "plotspec",    TRUE,  "vector",  "Sera size"),
    c("sr_cols_fill",         "srFill",             "plotspec",    TRUE,  "vector",  "Sera fill color"),
    c("sr_cols_outline",      "srOutline",          "plotspec",    TRUE,  "vector",  "Sera outline color"),
    c("sr_outline_width",     "srOutlineWidth",     "plotspec",    TRUE,  "vector",  "Sera outline width"),
    c("sr_rotation",          "srRotation",         "plotspec",    TRUE,  "vector",  "Sera rotation"),
    c("sr_aspect",            "srAspect",           "plotspec",    TRUE,  "vector",  "Sera aspect"),
    c("sr_shape",             "srShape",            "plotspec",    TRUE,  "vector",  "Sera shape"),
    c("sr_drawing_order",     "srDrawingOrder",     "plotspec",    TRUE,  "vector",  "Sera drawing order"),
    c("pt_drawing_order",     "ptDrawingOrder",     "plotspec",    TRUE,  "vector",  "Point drawing order"),
    c("ag_coords",            "agCoords",           "optimization",  TRUE,  "matrix",  "Antigen coordinates"),
    c("sr_coords",            "srCoords",           "optimization",  TRUE,  "matrix",  "Sera coordinates"),
    c("stress",               "mapStress",          "optimization",  FALSE, "vector",  "Map stress"),
    c("comment",              "mapComment",         "optimization",  TRUE,  "vector",  "Map comment"),
    c("dimensions",           "mapDimensions",      "optimization",  FALSE, "vector",  "Map dimensions"),
    c("minimum_column_basis", "minColBasis",        "optimization",  TRUE,  "vector",  "Map minimum column bases"),
    c("transformation",       "mapTransformation",  "optimization",  TRUE,  "matrix",  "Map transformation"),
    c("colbases",             "colBases",           "optimization",  TRUE,  "vector",  "Map column bases")
  )
  bindings <- as.data.frame(bindings, stringsAsFactors = FALSE)
  colnames(bindings) <- c("property", "method", "object", "settable", "format", "description")
  bindings[["settable"]] <- as.logical(bindings[["settable"]])

  if(!is.null(chart_object)){
    bindings <- subset(bindings, object == chart_object)
  }

  bindings

}





