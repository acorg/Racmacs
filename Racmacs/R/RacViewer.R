
#' Converting map data to the json format
#' Function to define what parts of the map data should be unboxed when exporting to json format.
unbox_map <- function(mapData){
  mapData$table_name <- jsonlite::unbox(mapData$table_name)
  mapData$comment    <- jsonlite::unbox(mapData$comment)
  mapData$caption    <- jsonlite::unbox(mapData$caption)

  if(!is.null(mapData$optimizations)){
      mapData$optimizations <- lapply(mapData$optimizations, function(brun){
        brun$dimensions           <- jsonlite::unbox(brun$dimensions)
        brun$stress               <- jsonlite::unbox(brun$stress)
        brun$comment              <- jsonlite::unbox(brun$comment)
        brun$minimum_column_basis <- jsonlite::unbox(brun$minimum_column_basis)
        brun
      })
  }

  mapData
}


#' Process map data for the viewer
process_mapViewerData <- function(mapData){

  # Convert to racmap if needed
  if("racchart" %in% class(mapData)){
    mapData <- as.list(mapData)
  }

  # Convert colors
  convertCol <- function(cols){
    as.vector(sapply(cols, function(col){
      if(tolower(col) == "transparent"){
        return("transparent")
      } else {
        return(gplots::col2hex(col))
      }
    }))
  }
  agFill(mapData)    <- convertCol(agFill(mapData))
  agOutline(mapData) <- convertCol(agOutline(mapData))
  srFill(mapData)    <- convertCol(srFill(mapData))
  srOutline(mapData) <- convertCol(srOutline(mapData))
  if(length(mapData$selected_optimization) == 1){
    mapData$selected_optimization <- jsonlite::unbox(mapData$selected_optimization - 1)
  }

  # Set defaults
  agAspect(mapData)       <- agAspect(mapData)
  agRotation(mapData)     <- agRotation(mapData)
  agOutlineWidth(mapData) <- agOutlineWidth(mapData)
  agDrawingOrder(mapData) <- agDrawingOrder(mapData)
  agShape(mapData)        <- agShape(mapData)
  agSize(mapData)         <- agSize(mapData)
  agShown(mapData)        <- agShown(mapData)

  srAspect(mapData)       <- srAspect(mapData)
  srRotation(mapData)     <- srRotation(mapData)
  srOutlineWidth(mapData) <- srOutlineWidth(mapData)
  srDrawingOrder(mapData) <- srDrawingOrder(mapData)
  srShape(mapData)        <- srShape(mapData)
  srSize(mapData)         <- srSize(mapData)
  srShown(mapData)        <- srShown(mapData)

  # Mark unboxed json components
  unbox_map(mapData)

}


#' Convert a map to json data
#'
#' @param map The acmap data
#'
#' @return Returns json as a string
#' @export
#'
map2json <- function(map){

  if(is.null(map)){
    return(NULL)
  }

  jsonlite::toJSON(
    process_mapViewerData(map),
    null = "list"
  )

}


#' Create a RacViewer widget
#'
#' This creates an html widget for viewing antigenic maps.
#'
#' @param map The map data object
#' @param controls Should controls be shown
#' @param stress Should stress be shown
#' @param rotation Viewer rotation
#' @param translation Viewer translation
#' @param zoom Viewer zoom
#' @param show_ags Should antigens be shown
#' @param show_sr Should sera be shown
#' @param width Width of the widget
#' @param height Height of the widget
#' @param elementId DOM element ID
#' @param selectable Should points be selectable
#'
#' @import htmlwidgets
#'
#' @export
RacViewer <- function(map,
                      rotation,
                      translation,
                      zoom,
                      hide_control_panel = FALSE,
                      width     = NULL,
                      height    = NULL,
                      elementId = NULL
                      ) {

  # create a list that contains the settings
  settings <- list(
    hide_control_panel = hide_control_panel
  )

  # forward options using x
  x = list(
    # mapData  = map2json(map),
    mapData = as.json(map),
    settings = jsonlite::toJSON(
      settings,
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
#'
#' @export
RacViewerOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'RacViewer', width, height, package = 'Racmacs')
}


#' @rdname RacViewer-shiny
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
#' @export
#'
RacViewerProxy <- function(id, session = shiny::getDefaultReactiveDomain()){

  proxy        <- list( id = shinyId, session = session )
  class(proxy) <- "RacViewerProxy"

  return(proxy)
}



