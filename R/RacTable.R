
#' @import htmlwidgets
#' @export
RacTable <- function(
  map,
  width = NULL,
  height = NULL,
  elementId = NULL
) {

  settings <- list()

  # forward options using x
  x = list(
    mapData    = as.json(map),
    settings   = jsonlite::toJSON(
      settings,
      auto_unbox = TRUE
    )
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'RacTable',
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

#' Shiny bindings for RacTable
#'
#' Output and render functions for using RacTable within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a RacTable
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name RacTable-shiny
#' @noRd
#' @export
RacTableOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'RacTable', width, height, package = 'Racmacs')
}

#' @rdname RacTable-shiny
#' @noRd
#' @export
renderRacTable <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, RacTableOutput, env, quoted = TRUE)
}
