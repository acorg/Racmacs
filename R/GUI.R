
#' Open the Racmacs GUI
#'
#' This function opens the Racmacs GUI in a new window
#'
#' @family shiny app functions
#' @export
#' @returns Nothing returned, called only for the side effect of starting the viewer.
runGUI <- function() {
  shiny::runApp(system.file("shinyapps/RacmacsGUI", package = "Racmacs"))
}
