
# Running optimizations
server_runOptimizations <- function(env) {

  shiny::showNotification(
    ui = "Optimizing map...",
    duration = NULL,
    closeButton = FALSE,
    id = "optimizing",
    type = "message",
    session = env$session
  )

  # Optimise the map
  env$storage$map <- optimizeMap(
    map = env$storage$map,
    number_of_dimensions           = as.numeric(env$input$runOptimizations$numdims),
    number_of_optimizations        = as.numeric(env$input$runOptimizations$numruns),
    minimum_column_basis           = env$input$runOptimizations$mincolbasis,
    # discard_previous_optimizations = FALSE,
    sort_optimizations             = TRUE
  )

  shiny::showNotification(
    ui = "Optimizing map... complete.",
    duration = 1,
    closeButton = FALSE,
    id = "optimizing",
    type = "message",
    session = env$session
  )

  # Reload the map
  env$session$sendCustomMessage("loadMapData", as.json(env$storage$map))

}
