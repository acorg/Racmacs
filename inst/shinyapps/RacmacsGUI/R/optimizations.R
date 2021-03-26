
# Changing selected optimization
server_optimizationChanged <- function(env) {

  opt_selected <- env$input$optimizationChanged + 1
  if (opt_selected != env$storage$opt_selected) {
    message(sprintf("Optimization %s selected", opt_selected))
    env$storage$opt_selected <- env$input$optimizationChanged + 1
  }

}

# Remove optimizations
server_removeOptimizations <- function(env) {

  shiny::showNotification(
    ui = "Removing optimizations... ",
    duration = NULL,
    closeButton = FALSE,
    id = "removing",
    type = "message",
    session = env$session
  )

  message("Removing optimizations...", appendLF = F)

  # Realign the optimizations
  env$storage$map <- removeOptimizations(env$storage$map)

  # Reload the map data
  env$session$sendCustomMessage("reloadMapData", as.json(env$storage$map))

  message("done.")

  shiny::showNotification(
    ui = "Removing optimizations... complete.",
    duration = 1,
    closeButton = FALSE,
    id = "removing",
    type = "message",
    session = env$session
  )

}

# Aligning optimizations
server_alignOptimizations <- function(env) {

  # Require optimizations
  reqOptimizations(env$storage$map, env$session)

  message("Orienting optimizations...", appendLF = F)
  shiny::showNotification(
    ui = "Aligning optimizations... ",
    duration = NULL,
    closeButton = FALSE,
    id = "orienting",
    type = "message",
    session = env$session
  )

  # Realign the optimizations
  env$storage$map <- realignOptimizations(env$storage$map)

  # Reload the map data
  env$session$sendCustomMessage("reloadMapData", as.json(env$storage$map))
  message("done.")

  shiny::showNotification(
    ui = "Aligning optimizations... complete.",
    duration = 1,
    closeButton = FALSE,
    id = "orienting",
    type = "message",
    session = env$session
  )

}


# Reflecting a map
server_reflectMap <- function(env) {

  message("Map reflected.")
  env$storage$map <- reflectMap(
    env$storage$map,
    axis = env$input$reflectMap,
    optimization_number = env$storage$opt_selected
  )
  env$session$sendCustomMessage("reloadMapData", as.json(env$storage$map))

}


# Altering map coords
server_coordsChanged <- function(env) {

  agCoords(env$storage$map, env$storage$opt_selected) <- list2matrix(env$input$coordsChanged$antigens)
  srCoords(env$storage$map, env$storage$opt_selected) <- list2matrix(env$input$coordsChanged$sera)
  env$session$sendCustomMessage("reloadMapData", as.json(env$storage$map))
  message("Coordinates updated.")

}
