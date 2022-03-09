
# Adding stress blob information
server_triangulationBlobs <- function(env) {

  shiny::showNotification(
    ui = "Calculating triangulation blobs...",
    duration = NULL,
    closeButton = FALSE,
    id = "blobs",
    type = "message",
    session = env$session
  )

  # # Convert point selections
  # point_selections <- convertSelectedPoints(
  #   env$input$triangulationBlobs$selected_points,
  #   env$storage$map
  # )

  # Calculate blob data
  # withProgress(
  #   message = "Calculating stress blobs",
  #   value = 0, {
  #     blob_data <- calculate_stressBlob(
  #       map          = env$storage$map,
  #       stress_lim   = as.numeric(env$input$triangulationBlobs$stresslim),
  #       grid_spacing = as.numeric(env$input$triangulationBlobs$gridspacing),
  #       antigens     = point_selections$antigens,
  #       sera         = point_selections$sera,
  #       progress_fn  = setProgress
  #     )
  #   }
  # )

  # Add to the map
  env$storage$map <- triangulationBlobs(
    map = env$storage$map,
    optimization_number = env$storage$opt_selected,
    stress_lim = as.numeric(env$input$triangulationBlobs$stresslim),
    grid_spacing = as.numeric(env$input$triangulationBlobs$gridspacing)
  )

  shiny::showNotification(
    ui = "Calculating blobs... complete.",
    duration = 1,
    closeButton = FALSE,
    id = "blobs",
    type = "message",
    session = env$session
  )

  # Load the stress blob data
  env$session$sendCustomMessage(
    "addBlobData",
    I(ptTriangulationBlobs(
      map = env$storage$map,
      optimization_number = env$storage$opt_selected
    ))
  )

}


# Check and add hemisphering information
server_checkHemisphering <- function(env) {

  # Check the map is relaxed
  reqRelaxed(env$storage$map, env$storage$opt_selected, env$session)

  # Start notify
  shiny::showNotification(
    ui = "Checking for hemisphering or trapped points...",
    duration = NULL,
    closeButton = FALSE,
    id = "hemisphering",
    type = "message",
    session = env$session
  )

  # Check for hemisphering
  env$storage$map <- checkHemisphering(env$storage$map, env$storage$opt_selected)

  # Send hemisphering information to display
  env$session$sendCustomMessage(
    "addHemispheringData",
    I(ptHemisphering(
      env$storage$map,
      env$storage$opt_selected
    ))
  )

  # End notify
  shiny::showNotification(
    ui = "Checking for hemisphering or trapped points... complete.",
    duration = 1,
    closeButton = FALSE,
    id = "hemisphering",
    type = "message",
    session = env$session
  )

}

# Moving trapped points
server_moveTrappedPoints <- function(env) {

  shiny::showNotification(
    ui = "Moving trapped points...",
    duration = NULL,
    closeButton = FALSE,
    id = "moving",
    type = "message",
    session = env$session
  )

  message("Moving trapped points...", appendLF = FALSE)
  env$storage$map <- moveTrappedPoints(
    env$storage$map,
    env$storage$opt_selected
  )
  env$session$sendCustomMessage("animateCoords", list(
    antigens = agCoords(env$storage$map, env$storage$opt_selected),
    sera     = srCoords(env$storage$map, env$storage$opt_selected),
    stress   = mapStress(env$storage$map, env$storage$opt_selected)
  ))
  env$session$sendCustomMessage("updateMapData", as.json(env$storage$map))
  message("done.")

  shiny::showNotification(
    ui = "Moving trapped points... complete.",
    duration = 1,
    closeButton = FALSE,
    id = "moving",
    type = "message",
    session = env$session
  )

}

# Procrustes points
server_procrustesMap <- function(env) {

  shiny::showNotification(
    ui = "Calculating procrustes... ",
    duration = NULL,
    closeButton = FALSE,
    id = "procrustes",
    type = "message",
    session = env$session
  )

  # Convert point selections
  # point_selections <- convertSelectedPoints(
  #   env$input$procrustes$selected_points,
  #   env$storage$map
  # )

  # Read in the procrustes map
  pcmap <- read.acmap(
    filename            = env$input$procrustesDataLoaded$datapath,
    optimization_number = as.numeric(env$input$procrustes$optimization)
  )

  # Calculate the procrustes data
  env$storage$map <- procrustesMap(
    map            = env$storage$map,
    comparison_map = pcmap,
    optimization_number = env$storage$opt_selected,
    comparison_optimization_number = 1,
    keep_optimizations = TRUE
  )

  # Reload the map data
  env$session$sendCustomMessage("addProcrustesData", I(ptProcrustes(env$storage$map, env$storage$opt_selected)))

  shiny::showNotification(
    ui = "Calculating procrustes... complete.",
    duration = 1,
    closeButton = FALSE,
    id = "procrustes",
    type = "message"
  )

}
