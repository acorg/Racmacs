
#' Read in acmap data from a file
#'
#' Reads an antigenic map file and converts it into an acmap data object.
#'
#' @param filename Path to the file.
#' @param optimization_number Numeric vector of optimization runs to keep, the
#'   default, NULL, keeps information on all optimization runs
#' @param sort_optimizations Should optimizations be sorted in order of stress
#'   when the map data is read?
#' @param align_optimizations Should optimizations be rotated and translated to
#'   match the orientation of the first optimization as closely as possible?
#'
#' @return Returns the acmap data object.
#'
#' @family {functions for working with map data}
#' @export
#'
read.acmap <- function(
  filename,
  optimization_number = NULL,
  sort_optimizations  = FALSE,
  align_optimizations = FALSE
  ) {

  # Expand the file path and check that the file exists
  if (!file.exists(filename)) {
    stop("File '", filename, "' not found", call. = FALSE)
  }

  # Read the data from the file
  jsondata <- paste(readLines(filename, warn = FALSE), collapse = "\n")
  map <- json_to_acmap(jsondata)

  # Apply arguments
  if (!is.null(optimization_number)) {
    map <- keepOptimizations(map, optimization_number)
  }
  if (sort_optimizations) {
    map <- sortOptimizations(map)
  }
  if (align_optimizations) {
    map <- realignOptimizations(map)
  }

  # Return the map
  map

}


#' Save acmap data to a file
#'
#' Save acmap data to a file. The preferred extension is ".ace", although
#' the format of the file will be a json file of map data compressed using
#' 'xz' compression.
#'
#' @param map The acmap data object.
#' @param filename Path to the file.
#'
#' @export
#'
#' @family {functions for working with map data}
#'
save.acmap <- function(
  map,
  filename
  ) {

  # Check file extension
  nfilechar <- nchar(filename)
  if (substr(filename, nfilechar - 3, nfilechar) != ".ace") {
    stop("File format must be '.ace'", call. = FALSE)
  }

  # Save to a file
  conn <- xzfile(filename, "w")
  writeChar(as.json(map), conn, eos = NULL)
  close(conn)

}


#' Convert map to json format
#'
#' @param map The map data object
#'
#' @return Returns map data as .ace json format
#' @family {functions for working with map data}
#' @export
#'
as.json <- function(map) {

  acmap_to_json(
    map = map,
    version = paste0("racmacs-ace-v", utils::packageVersion("Racmacs"))
  )

}


#' Save acmap coordinate data to a file
#'
#' Saves acmap coordinate data of all or specified antigens and sera to a .csv
#' file.
#'
#' @param map The acmap data object.
#' @param filename Path to the file.
#' @param antigens Antigens to include, either as a numeric vector of indices or
#'   character vector of names.
#' @param sera Sera to include, either as a numeric vector of indices or
#'   character vector of names.
#'
#' @export
#'
#' @family {functions for working with map data}
#'
save.coords <- function(
  map,
  filename,
  optimization_number = 1,
  antigens = TRUE,
  sera = TRUE
  ) {

  check.acmap(map)
  check.optnum(map, optimization_number)

  antigens <- get_ag_indices(antigens, map)
  sera     <- get_sr_indices(sera, map)

  nfilechar <- nchar(filename)
  if (substr(filename, nfilechar - 3, nfilechar) != ".csv") {
    stop("File format must be .csv")
  }

  type   <- c(rep("antigen", length(antigens)), rep("sera", length(sera)))
  name   <- c(agNames(map)[antigens], srNames(map)[sera])
  coords <- rbind(
    agCoords(map, optimization_number)[antigens, ],
    srCoords(map, optimization_number)[sera, ]
  )
  utils::write.csv(
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
#' @param antigens Antigens to include, either as a numeric vector of indices or
#'   character vector of names.
#' @param sera Sera to include, either as a numeric vector of indices or
#'   character vector of names.
#'
#' @export
#'
#' @family {functions for working with map data}
#'
save.titerTable <- function(
  map,
  filename,
  antigens = TRUE,
  sera = TRUE
  ) {

  antigens <- get_ag_indices(antigens, map)
  sera     <- get_sr_indices(sera, map)

  nfilechar <- nchar(filename)
  if (substr(filename, nfilechar - 3, nfilechar) != ".csv") {
    stop("File format must be .csv")
  }

  utils::write.csv(
    x = titerTable(map)[antigens, sera],
    file = filename
  )

}
