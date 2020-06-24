
#' Set viewer settings for a map
#'
#' A function to control visual features of the map display in the interactive viewer.
#'
#' @param map
#'
#' @return
#' @export
#'
#' @examples
get_viewer_options <- function(
  map
){
  lapply(getMapAttribute(map, "viewer_settings"), unlist)
}

#' @examples
set_viewer_options <- function(
  map,
  grid.col = "#eeeeee"
){
  settings <- list(
    grid.col = grid.col
  )
  setMapAttribute(map, "viewer_settings", settings)
}


