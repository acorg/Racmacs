
#' Printing racmap objects
#'
#' Print information about a racmap object.
#'
#' @param map The map object
#' @export
#' @noRd
#'
#' @examples
#' # Print subset of information about a map
#' print(h3map2004)
#'
print.rac <- function(map, all = FALSE){

  # Print short descriptor
  cat(crayon::green(sprintf("<%s>\n", class(map)[1])))
  mapname <- name(map)
  if(mapname == "") mapname <- "[unnamed]"
  cat(sprintf("%s\n", mapname))
  cat(sprintf("...%s antigens\n", numAntigens(map)))
  cat(sprintf("...%s sera\n", numSera(map)))
  cat(sprintf("...%s optimizations\n", numOptimizations(map)))
  invisible(map)

}

#' @export
view <- function(x, ...){
  UseMethod("view", x)
}

#' @export
view.default <- function(x, ...){
  print(x)
}

#' Viewing racmap objects
#'
#' View a racmap object in the interactive viewer.
#'
#' @param racmap The racmap object
#' @param ... Arguments to be passed to \code{\link{view_map}}
#'
#' @export
#' @noRd
#'
view.rac <- function(map,
                     ...,
                     .jsCode = NULL,
                     .jsData = NULL,
                     select_ags = NULL,
                     select_sr  = NULL,
                     show_procrustes = NULL,
                     show_stressblobs = NULL){

  # Clone the map
  map <- cloneMap(map)

  # Pass on only the selected optimization
  map <- keepSingleOptimization(map)

  # View the map data in the viewer
  widget <- RacViewer(map = map,
                      hide_control_panel = TRUE,
                      ...)

  # Make any antigen and serum selections
  if(!is.null(select_ags)){
    widget <- htmlwidgets::onRender(
      x      = widget,
      jsCode = "function(el, x, data) { el.viewer.selectAntigensByIndices(data) }",
      data   = I(select_ags)
    )
  }

  if(!is.null(select_sr)){
    widget <- htmlwidgets::onRender(
      x      = widget,
      jsCode = "function(el, x, data) { el.viewer.selectSeraByIndices(data) }",
      data   = I(select_sr)
    )
  }

  # Add any procrustes lines
  if(!is.null(map$procrustes) && !isFALSE(show_procrustes)){
    widget <- htmlwidgets::onRender(
      x      = widget,
      jsCode = "function(el, x, data) { el.viewer.addProcrustesToBaseCoords(data) }",
      data   = I(map$procrustes$pc_coords)
    )
  }

  # Show any blob data
  if(hasStressBlobs(map) && !isFALSE(show_stressblobs)){
    widget <- htmlwidgets::onRender(
      x      = widget,
      jsCode = "function(el, x, data) { el.viewer.addStressBlobs(data) }",
      data   = I(map$stressblobs)
    )
  }

  # Add any map legends
  if(!is.null(map$legend)){
    widget <- htmlwidgets::onRender(
      x      = widget,
      jsCode = sprintf("function(el, x, data) {
        var div = document.createElement('div');
        div.innerHTML      = `%s`;
        div.racviewer      = el.viewer;
        el.viewer.viewport.div.appendChild(div);
      }", as.character(make_html_legend(map$legend))),
      data   = NULL
    )
  }

  # Execute any additional javascript code
  if(!is.null(.jsCode)){
    widget <- htmlwidgets::onRender(
      x      = widget,
      jsCode = .jsCode,
      data   = .jsData
    )
  }

  # Return the widget as an output
  widget

}


