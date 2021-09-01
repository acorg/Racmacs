
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

  antigens <- unique(unlist(selections$antigens) + 1)
  sera <- unique(unlist(selections$sera) + 1)

  if (length(antigens) == 0 && length(sera) == 0) {
    antigens <- seq_len(numAntigens(map))
    sera <- seq_len(numSera(map))
  }

  list(
    antigens = antigens,
    sera = sera
  )

}

# Require that a map is relaxed, otherwise stop execution of reactive function
reqRelaxed <- function(map, optimization_num, session) {

  relaxed <- mapRelaxed(map, optimization_num)
  if (!relaxed) {
    shiny::showNotification(
      "The map is not fully relaxed",
      closeButton = FALSE,
      duration = 1,
      type = "error",
      session = session
    )
    shiny::req(relaxed)
  }

}

# Require that a map has optimizations, otherwise stop execution of a reactive function
reqOptimizations <- function(
  map,
  session
  ) {

  has_optimizations <- numOptimizations(map) > 0
  if (!has_optimizations) {
    shiny::showNotification(
      "The map has no optimizations",
      closeButton = FALSE,
      duration = 1,
      type = "error",
      session = session
    )
    shiny::req(has_optimizations)
  }

}
