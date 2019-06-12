
#' Open the Racmacs GUI
#'
#' @export
#'
runGUI <- function(){
    shiny::runApp(system.file('shinyapps/RacmacsGUI', package='Racmacs'))
}

