
#' Create a RacViewer widget
#'
#' This creates an html widget for viewing antigenic maps.
#'
#' @param map The map data object
#' @param show_procrustes should procrustes lines be shown
#' @param show_group_legend Show an interactive legend detailing different
#'   groups as set by `agGroups()` and `srGroups()`
#' @param options A named list of viewer options supplied to
#'   `racviewer.options()`
#' @param width Width of the widget
#' @param height Height of the widget
#' @param elementId DOM element ID
#'
#' @returns An object of class htmlwidget that will intelligently print itself
#'   into HTML in a variety of contexts including the R console, within R
#'   Markdown documents, and within Shiny output bindings.
#'
#' @family functions to view maps
#'
#' @import htmlwidgets
#' @export
RacViewer <- function(
  map,
  show_procrustes = FALSE,
  show_group_legend = FALSE,
  options   = list(),
  width     = NULL,
  height    = NULL,
  elementId = NULL
  ) {

  # Get map data as json
  if (is.null(map)) mapdata <- NULL
  else              mapdata <- as.json(map)

  # Parse options
  options <- do.call(RacViewer.options, options)
  options$show_group_legend <- show_group_legend

  # Add a rotating grid to the plotdata if specified
  if (options$grid.display == "rotate") {
    map <- addMapGrid(map, options$grid.col)
  }

  # Forward data using x
  x <- list(
    mapData  = mapdata,
    plotdata = jsonlite::toJSON(
      map$plot
    ),
    light = jsonlite::toJSON(
      map$light,
      null = "null"
    ),
    options  = jsonlite::toJSON(
      options,
      auto_unbox = TRUE,
      null = "null"
    )
  )

  # create widget
  htmlwidgets::createWidget(
    name = "RacViewer",
    x,
    width = width,
    height = height,
    package = "Racmacs",
    elementId = elementId,
    sizingPolicy = htmlwidgets::sizingPolicy(
      viewer.padding  = 0,
      browser.fill    = TRUE,
      browser.padding = 0
    )
  )
}

#' Shiny bindings for RacViewer
#'
#' Output and render functions for using RacViewer within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a RacViewer
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @returns An output or render function that enables the use of the widget
#'   within Shiny applications.
#'
#' @family shiny app functions
#'
#' @name RacViewer-shiny
#' @export
RacViewerOutput <- function(outputId, width = "100%", height = "100%") {
  htmlwidgets::shinyWidgetOutput(
    outputId,
    "RacViewer",
    width, height,
    package = "Racmacs"
  )
}


#' @rdname RacViewer-shiny
#' @export
renderRacViewer <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) expr <- substitute(expr) # force quoted
  htmlwidgets::shinyRenderWidget(expr, RacViewerOutput, env, quoted = TRUE)
}

