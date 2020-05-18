
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




