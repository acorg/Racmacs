
#' Open the Racmacs GUI
#'
#' This function opens the Racmacs GUI in a new window
#'
#' @export
#'
runGUI <- function() {
  shiny::runApp(system.file("shinyapps/RacmacsGUI", package = "Racmacs"))
}

# Utility functions for the GUI
# Convert a list of lists to a matrix
list2matrix <- function(x) {
  do.call(rbind, lapply(x, unlist))
}


# Convert data to json format
data2json <- function(x) {
  jsonlite::toJSON(x)
}


# Convert point selections into TRUE, FALSE or base 1 indices
convertSelectedPoints <- function(selections, map) {

  antigens <- unlist(selections$antigens) + 1
  sera     <- unlist(selections$sera) + 1

  if (length(antigens) == 0 && length(sera) == 0) {
    return(list(antigens = TRUE, sera = TRUE))
  }

  if (length(antigens) == numAntigens(map))  antigens <- TRUE
  if (length(sera) == numSera(map))          sera <- TRUE
  if (length(antigens) == 0)                 antigens <- FALSE
  if (length(sera) == 0)                     sera <- FALSE

  list(
    antigens = antigens,
    sera = sera
  )

}


# Function to execute code
execute <- function(command) {

  tryCatch(
    expr = {
      eval(command)
    },
    error = function(e) {
      shiny::showNotification(
        e$message,
        closeButton = FALSE,
        duration = 1,
        type = "error"
      )
      message(e$message)
    }
  )
  invisible()

}
