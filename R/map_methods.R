
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
print.acmap <- function(map, all = FALSE){

  # Print short descriptor
  cat(crayon::green(sprintf("<%s>\n", class(map)[1])))
  mapname <- mapName(map)
  if(is.null(mapname)) mapname <- "[unnamed]"
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
#' @param map The acmap data object
#' @param options A named list of viewer options to pass to `RacViewer.options()`
#' @param ... Additional arguments to be passed to \code{\link{RacViewer}}
#' @param .jsCode Additional javascript code to be run after map has been loaded and rendered
#' @param .jsData Any data to supply to the .jsCode function
#' @param select_ags A vector of antigen indices to select in the plot
#' @param select_sr A vector of serum indices to select in the plot
#' @param show_procrustes If the map contains procrustes information, should procrustes lines be shown by default?
#' @param show_stressblobs If the map contains stress blob information, should stress blobs be shown by default?
#' @param keep_all_optimization_runs Should information on all the optimization runs be kept in the viewer, or just view the currently selected optimisation run.
#'
#' @export
#'
view.acmap <- function(
  map,
  ...,
  .jsCode = NULL,
  .jsData = NULL,
  select_ags = NULL,
  select_sr  = NULL,
  show_procrustes = NULL,
  show_stressblobs = NULL,
  keep_all_optimization_runs = FALSE,
  options = list()
  ){

  # Pass on only the selected optimization
  if(!keep_all_optimization_runs){
    map <- keepSingleOptimization(map)
  }

  # Add a procrustes grid if the main map is 3d and the comparitor map is 2d
  if(!is.null(map$procrustes) && !isFALSE(show_procrustes)){
    if(mapDimensions(map) == 3 && ncol(map$procrustes$ag_coords) == 2){
      map <- add_procrustes_grid(map)
    }
  }

  # View the map data in the viewer
  widget <- RacViewer(
    map = map,
    options = options,
    ...
  )

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
      data   = I(map$procrustes)
    )

  }

  # Show any blob data
  stressblobdata <- viewer_stressblobdata(map)
  if(!is.null(stressblobdata) && !isFALSE(show_stressblobs)){
    widget <- htmlwidgets::onRender(
      x      = widget,
      jsCode = "function(el, x, data) { el.viewer.addStressBlobs(data) }",
      data   = I(stressblobdata)
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


