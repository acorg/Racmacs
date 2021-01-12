
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

  # Read the data from the file
  jsondata <- paste(readLines(filename, warn = FALSE), collapse = "\n")
  map <- json_to_acmap(jsondata)

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

  # Check file extension
  nfilechar <- nchar(filename)
  if(substr(filename, nfilechar-3, nfilechar) != ".ace"){
    stop("File format must be '.ace'", call. = FALSE)
  }

  # Save to a file
  conn <- xzfile(filename, "w")
  writeChar(as.json(map), conn, eos = NULL)
  close(conn)

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

