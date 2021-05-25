
#' Set viewer options
#'
#' This function facilitates setting racviewer options by returning a list of
#' option settings.
#'
#' @param point.opacity Default opacity for unselected points
#' @param viewer.controls Should viewer controls be shown or hidden by default?
#' @param grid.display For 3d maps, should the grid be fixed in the background
#'   or enclose and rotate along with the map
#' @param grid.col Color to use for the grid shown behind the map
#'
#' @family {functions to view maps}
#'
#' @return Returns a named list of viewer options
#' @export
#'
RacViewer.options <- function(
  point.opacity = NA,
  viewer.controls = "hidden",
  grid.display = "static",
  grid.col = "#e0e0e0"
) {

  # Check input
  check.string(viewer.controls)
  check.string(grid.display)
  if (!is.na(point.opacity)) check.numeric(point.opacity)

  list(
    viewer.controls = viewer.controls,
    point.opacity = point.opacity,
    grid.display = grid.display,
    grid.col = grid.col
  )

}


#' Export the map viewer
#'
#' Export a map in a standalone html viewer
#'
#' @param map The acmap object
#' @param file File to save HTML into
#' @param selfcontained Whether to save the HTML as a single self-contained file
#'   (with external resources base64 encoded) or a file with external resources
#'   placed in an adjacent directory.
#' @param ... Further parameters to `view()`
#'
#' @family {functions to view maps}
#'
#' @export
#'
export_viewer <- function(
  map,
  file,
  selfcontained = TRUE,
  ...
  ) {

  # Check file has .html extension
  if (!grepl("\\.html$", file)) {
    stop("File extension must be '.html'")
  }

  # Export the widget to a temporary file first
  tmp_file <- tempfile(fileext = ".html")
  widget <- view(map, ...)

  widget <- htmlwidgets::saveWidget(
    widget        = widget,
    file          = tmp_file,
    selfcontained = selfcontained
  )

  # Move the file to the proper location
  file.copy(from = tmp_file,
            to   = file,
            overwrite = TRUE)

  # Remove the temporary file
  unlink(tmp_file)

  # Return the widget
  invisible(widget)

}
