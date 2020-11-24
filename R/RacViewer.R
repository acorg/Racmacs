
#' Create a RacViewer widget
#'
#' This creates an html widget for viewing antigenic maps.
#'
#' @param map The map data object
#' @param rotation Viewer rotation
#' @param translation Viewer translation
#' @param zoom Viewer zoom
#' @param options A named list of viewer options supplied to `racviewer.options()`
#' @param width Width of the widget
#' @param height Height of the widget
#' @param plotdata
#' @param show_procrustes
#' @param elementId DOM element ID
#'
#' @import htmlwidgets
#' @noRd
#' @export
RacViewer <- function(
  map,
  rotation,
  translation,
  zoom,
  plotdata  = NULL,
  show_procrustes = FALSE,
  options   = list(),
  width     = NULL,
  height    = NULL,
  elementId = NULL
  ) {

  # Get map data as json
  if(is.null(map)) mapdata <- NULL
  else             mapdata <- as.json(map)

  # Add a rotating grid to the plotdata if specified
  if(options$grid.display == "rotate"){
    map <- addMapGrid(map)
  }

  # forward options using x
  x = list(
    mapData  = mapdata,
    plotdata = jsonlite::toJSON(map$plot),
    options  = jsonlite::toJSON(
      do.call(RacViewer.options, options),
      auto_unbox = TRUE
    )
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'RacViewer',
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
#' @name RacViewer-shiny
#' @noRd
#' @export
RacViewerOutput <- function(outputId, width = '100%', height = '100%'){
  htmlwidgets::shinyWidgetOutput(outputId, 'RacViewer', width, height, package = 'Racmacs')
}


#' @rdname RacViewer-shiny
#' @noRd
#' @export
renderRacViewer <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, RacViewerOutput, env, quoted = TRUE)
}



#' Create a proxy RacViewer object
#'
#' @param id ID of RacViewer instance
#' @param session Session object of shiny application
#'
#' @return Returns a chart proxy
#' @noRd
#' @export
RacViewerProxy <- function(id, session = shiny::getDefaultReactiveDomain()){

  proxy        <- list( id = shinyId, session = session )
  class(proxy) <- "RacViewerProxy"

  return(proxy)
}


#' Create a map snapshot
#'
#' @param map The map data file
#' @param width Snapshot width
#' @param height Snapshot height
#' @param filename File to save image to
#' @param ... Further parameters to pass to view
#'
#' @family {functions to view maps}
#' @export
#'
snapshotMap <- function(map, width = 800, height = 800, filename = NULL, ...){

  # Generate the widget
  widget   <- view(map, ...)

  # Save the widget to a temporary file
  tmpdir  <- tempdir()
  tmppage <- file.path(tmpdir, "RacmapSnaphot.html")
  htmlwidgets::saveWidget(widget, file = tmppage)
  pagepath <- normalizePath(tmppage)

  # Set the path to chrome
  chrome   <- "/Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome"

  # Run the screenshot command
  command <- paste0(
    "cd ", tmpdir, "; ",
    chrome, " --headless --disable-gpu --screenshot --window-size=", width,",", height," ", pagepath
  )
  system(command, ignore.stdout = TRUE, ignore.stderr = TRUE)

  # Get the path to the screenshot generated
  screenshot <- file.path(tmpdir, "screenshot.png")

  # Save the screenshot to a file or output the base64 img data
  if(is.null(filename)){

    system2("base64", screenshot, TRUE)

  } else {

    file.rename(
      from = screenshot,
      to   = filename
    )

  }

}


copyR3JSlib <- function(){
  unlink("inst/htmlwidgets/RacViewer/lib/r3js/lib", recursive = TRUE)
  file.copy(
    from = "../../packages/r3js/inst/htmlwidgets/lib",
    to   = "inst/htmlwidgets/RacViewer/lib/r3js",
    recursive = TRUE
  )
}


linkR3JSlib <- function(){
  unlink("inst/htmlwidgets/RacViewer/lib/r3js/lib", recursive = TRUE)
  file.symlink(
    from = "../../../../../../r3js/inst/htmlwidgets/lib",
    to   = "inst/htmlwidgets/RacViewer/lib/r3js/lib"
  )
}



