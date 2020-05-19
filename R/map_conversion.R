
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
#' @name convertingMaps
NULL


#' @rdname convertingMaps
#' @family {functions for working with map data}
#' @export
as.list.racchart <- function(map){

  if("racmap" %in% class(map)) return(map)
  json_to_racmap(
    as.json(map)
  )

}



#' @rdname convertingMaps
#' @family {functions for working with map data}
#' @export
as.cpp <- function(map){

  if("racchart" %in% class(map)) return(map)
  json <- as.json.racmap(map)
  tmp <- tempfile(fileext = ".ace")
  write(json, tmp)
  map.cpp <- read.acmap.cpp(tmp)
  selectedOptimization(map.cpp) <- selectedOptimization(map)
  map.cpp

}



#' Convert map to json format
#'
#' @param map The map data object
#'
#' @return Returns map data as .ace json format
#' @family {functions for working with map data}
#' @export
#'
as.json <- function(map){

  UseMethod("as.json", map)

}




