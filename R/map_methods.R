
#' Printing racmap objects
#'
#' Print information about a racmap object.
#'
#' @param x The map object
#' @param ... Additional arguments, ignored
#'
#' @export
#' @noRd
#'
print.acmap <- function(x, ...) {

  # Print short descriptor
  cat(crayon::green("<acmap>\n"))
  mapname <- mapName(x)
  if (is.null(mapname)) mapname <- "[unnamed]"
  cat(sprintf("%s\n", mapname))
  cat(sprintf("...%s antigens\n", numAntigens(x)))
  cat(sprintf("...%s sera\n", numSera(x)))
  cat(sprintf("...%s optimizations\n", numOptimizations(x)))
  invisible(x)

}


#' S3 method for viewing objects
#'
#' @param x The object to view
#' @param ... Additional arguments, not used.
#'
#' @family {functions to view maps}
#'
#' @export
view <- function(x, ...) {
  UseMethod("view", x)
}


#' Default method for viewing objects
#'
#' @param x The object to view
#' @param ... Additional arguments, passed to print.
#'
#' @family {functions to view maps}
#'
#' @export
view.default <- function(x, ...) {
  print(x)
}


#' Viewing racmap objects
#'
#' View a racmap object in the interactive viewer.
#'
#' @param x The acmap data object
#' @param optimization_number The optimization number to view
#' @param options A named list of viewer options to pass to
#'   `RacViewer.options()`
#' @param ... Additional arguments to be passed to `RacViewer()`
#' @param .jsCode Additional javascript code to be run after map has been loaded
#'   and rendered
#' @param .jsData Any data to supply to the .jsCode function
#' @param select_ags A vector of antigen indices to select in the plot
#' @param select_sr A vector of serum indices to select in the plot
#' @param show_procrustes If the map contains procrustes information, should
#'   procrustes lines be shown by default?
#' @param show_diagnostics If the map contains diagnostics information like
#'   stress blobs or hemisphering, should it be shown by default?
#' @param keep_all_optimization_runs Should information on all the optimization
#'   runs be kept in the viewer, or just view the currently selected
#'   optimisation run.
#'
#' @family {functions to view maps}
#'
#' @return Returns the htmlwidget object
#'
#' @export
#'
view.acmap <- function(
  x,
  optimization_number = 1,
  ...,
  .jsCode = NULL,
  .jsData = NULL,
  select_ags = NULL,
  select_sr  = NULL,
  show_procrustes = NULL,
  show_diagnostics = NULL,
  keep_all_optimization_runs = FALSE,
  options = list()
  ) {

  # Pass on only the selected optimization
  if (!keep_all_optimization_runs) {
    x <- keepSingleOptimization(x, optimization_number)
  }

  # Add a procrustes grid if the main map is 3d and the comparator map is 2d
  if (!is.null(x$procrustes) && !isFALSE(show_procrustes)) {
    if (mapDimensions(x) == 3 && ncol(x$procrustes$ag_coords) == 2) {
      x <- add_procrustes_grid(x)
    }
  }

  # View the map data in the viewer
  widget <- RacViewer(
    map = x,
    options = options,
    ...
  )

  # Make any antigen and serum selections
  if (!is.null(select_ags)) {
    widget <- htmlwidgets::onRender(
      x      = widget,
      jsCode = "function(el, x, data) { el.viewer.selectAntigensByIndices(data) }",
      data   = I(select_ags)
    )
  }

  if (!is.null(select_sr)) {
    widget <- htmlwidgets::onRender(
      x      = widget,
      jsCode = "function(el, x, data) { el.viewer.selectSeraByIndices(data) }",
      data   = I(select_sr)
    )
  }

  # Add any procrustes lines
  if (
    hasProcrustes(x, optimization_number)
    && !isFALSE(show_procrustes)
    ) {

    widget <- htmlwidgets::onRender(
      x      = widget,
      jsCode = "function(el, x, data) { el.viewer.addProcrustesToBaseCoords(data) }",
      data   = I(ptProcrustes(x, optimization_number))
    )

  }

  # Show any blob data
  if (
    hasTriangulationBlobs(x, optimization_number)
    && !isFALSE(show_diagnostics)
    ) {

    widget <- htmlwidgets::onRender(
      x      = widget,
      jsCode = "function(el, x, data) { el.viewer.addTriangulationBlobs(data) }",
      data   = I(ptTriangulationBlobs(x, optimization_number))
    )

  }

  # Show any bootstrap data
  if (
    hasBootstrapData(x, optimization_number)
    && !isFALSE(show_diagnostics)
  ) {

    widget <- htmlwidgets::onRender(
      x      = widget,
      jsCode = "function(el, x, data) { el.viewer.showBootstrapPoints(data) }",
      data   = I(bootstrapData(x, optimization_number))
    )

  }

  # Show any bootstrap blob data
  if (
    hasBootstrapBlobs(x, optimization_number)
    && !isFALSE(show_diagnostics)
  ) {

    widget <- htmlwidgets::onRender(
      x      = widget,
      jsCode = "function(el, x, data) { el.viewer.addTriangulationBlobs(data) }",
      data   = I(ptBootstrapBlobs(x, optimization_number))
    )

  }

  # Show any hemisphering data
  if (
    hasHemisphering(x, optimization_number)
    && !isFALSE(show_diagnostics)
    ) {

    widget <- htmlwidgets::onRender(
      x      = widget,
      jsCode = "function(el, x, data) { el.viewer.showHemisphering(data) }",
      data   = I(ptHemisphering(x, optimization_number))
    )

  }

  # Add any map legends
  if (!is.null(x$legend)) {
    widget <- htmlwidgets::onRender(
      x      = widget,
      jsCode = sprintf("function(el, x, data) {
        var div = document.createElement('div');
        div.innerHTML      = `%s`;
        div.racviewer      = el.viewer;
        el.viewer.viewport.div.appendChild(div);
      }", as.character(make_html_legend(x$legend))),
      data   = NULL
    )
  }

  # Execute any additional javascript code
  if (!is.null(.jsCode)) {
    widget <- htmlwidgets::onRender(
      x      = widget,
      jsCode = .jsCode,
      data   = .jsData
    )
  }

  # Return the widget as an output
  widget

}
