
#' Open the Racmacs GUI
#'
#' This function opens the Racmacs GUI in a new window
#'
#' @export
#'
runGUI <- function(){
    shiny::runApp(system.file('shinyapps/RacmacsGUI', package='Racmacs'))
}

