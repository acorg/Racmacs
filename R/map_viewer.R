

#' Set viewer options
#'
#' This function facilitates setting racviewer options by returning a list of
#' option settings.
#'
#' @param point.opacity Default opacity for unselected points, or "inherit" to take
#'   opacity from the color values themselves.
#' @param viewer.controls Should viewer controls be shown or hidden by default?
#' @param grid.display For 3d maps, should the grid be fixed in the background
#'   or enclose and rotate along with the map
#' @param grid.col Color to use for the grid shown behind the map
#' @param background.col Color for the viewer background
#' @param show.names Toggle name labels on, can be true or false or "antigens"
#'   or "sera"
#' @param show.errorlines Toggle error lines on
#' @param show.connectionlines Toggle connection lines on
#' @param show.titers Toggle titer labels on
#' @param xlim x limits to zoom the plot to
#' @param ylim y limits to zoom the plot to
#' @param translation Plot starting translation
#' @param rotation Plot starting rotation as an XYZ Euler rotation
#' @param zoom Plot starting zoom factor
#'
#' @family functions to view maps
#'
#' @return Returns a named list of viewer options
#' @export
#'
RacViewer.options <- function(
  point.opacity = NA,
  viewer.controls = "hidden",
  grid.display = "static",
  grid.col = "#cfcfcf",
  background.col = "#ffffff",
  show.names = FALSE,
  show.errorlines = FALSE,
  show.connectionlines = FALSE,
  show.titers = FALSE,
  xlim = NULL,
  ylim = NULL,
  translation = c(0, 0, 0),
  rotation = c(0, 0, 0),
  zoom = NULL
  ) {

  # Check input
  check.string(viewer.controls)
  check.string(grid.display)
  if (!is.na(point.opacity) && point.opacity != "inherit") {
    check.numeric(point.opacity)
  }

  list(
    viewer.controls = viewer.controls,
    point.opacity = point.opacity,
    grid.display = grid.display,
    grid.col = grid.col,
    background.col = background.col,
    show.names = show.names,
    show.errorlines = show.errorlines,
    show.connectionlines = show.connectionlines,
    show.titers = show.titers,
    xlim = xlim,
    ylim = ylim,
    translation = translation,
    rotation = rotation,
    zoom = zoom
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
#' @returns Called for the side effect of saving the viewer to an html file but
#'   invisibly returns the map viewer htmlwidget.
#'
#' @family functions to view maps
#'
#' @export
#'
export_viewer <- function(map,
                          file,
                          selfcontained = TRUE,
                          ...) {
  # Check file has .html extension
  if (!grepl("\\.html$", file)) {
    stop("File extension must be '.html'")
  }

  # Export the widget to a temporary file first
  tmp_file <- tempfile(fileext = ".html")
  widget <- view(map, ...)

  name <- Racmacs::mapName(map)
  if (is.null(name)) {
    title <- class(widget)[[1]]
  } else {
    title <- paste("RacViewer", name, sep = " - ")
  }

  widget <- htmlwidgets::saveWidget(
    widget = widget,
    file = tmp_file,
    selfcontained = selfcontained,
    title = title
  )

  # Move the file to the proper location
  file.copy(
    from = tmp_file,
    to = file,
    overwrite = TRUE
  )

  # Remove the temporary file
  unlink(tmp_file)

  # Return the widget
  invisible(widget)
}
