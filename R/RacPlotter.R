
#' @export
RacPlotter <- function(map,
                       rotation,
                       translation,
                       zoom,
                       xlim = NULL,
                       ylim = NULL,
                       plotdata  = NULL,
                       width     = NULL,
                       height    = NULL,
                       elementId = NULL
) {

  # Keep only the selected optimization
  map <- keepSingleOptimization(map)

  # Calculate plot limits
  if(is.null(xlim) | is.null(ylim)){
    all_coords <- rbind(agCoords(map), srCoords(map))
    if(!is.null(map$procrustes)){
      all_coords <- rbind(
        all_coords,
        applyMapTransform(map$procrustes$pc_coords$ag, map),
        applyMapTransform(map$procrustes$pc_coords$sr, map)
      )
    }
    padding <- 1
    xlim <- c(floor(min(all_coords[,1], na.rm = T))-padding, ceiling(max(all_coords[,1], na.rm = T))+padding)
    ylim <- c(floor(min(all_coords[,2], na.rm = T))-padding, ceiling(max(all_coords[,2], na.rm = T))+padding)
  }

  # Create a list that contains the settings
  settings <- list(
    xlim = xlim,
    ylim = ylim
  )

  # forward options using x
  x = list(
    mapData    = as.json(map),
    procrustes = map$procrustes$pc_coords,
    legend     = map$legend,
    plotdata   = jsonlite::toJSON(map$plot),
    settings   = jsonlite::toJSON(
      settings,
      auto_unbox = TRUE
    )
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'RacPlotter',
    x,
    width = width,
    height = height,
    package = 'Racmacs',
    elementId = elementId,
    sizingPolicy = htmlwidgets::sizingPolicy(
      viewer.padding  = 0,
      browser.fill    = TRUE,
      browser.padding = 0
    )
  )
}


#' Shiny bindings for RacPlotter
#'
#' Output and render functions for using RacPlotter within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a RacPlotter
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name RacPlotter-shiny
#' @noRd
#' @export
RacPlotterOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'RacPlotter', width, height, package = 'Racmacs')
}

#' @rdname RacPlotter-shiny
#' @noRd
#' @export
renderRacPlotter <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, RacPlotterOutput, env, quoted = TRUE)
}
