
#' Open a shiny gadget to view the map
#'
#' This function is equivalent to running `runGUI()` and loading a map file, but this
#' takes the acmap object to open as an input argument.
#'
#' @param map The acmap object to open in the GUI
#'
#' @returns No value returned, called for the side effect of starting the gadget.
#'
#' @family functions to view maps
#' @export
#'
mapGadget <- function(map) {

  check.acmap(map)
  ui <- mapGUI_ui()
  server <- mapGUI_server(map)
  shiny::runGadget(ui, server)

}
