
# Relax map
server_relaxMap <- function(env) {

  if (mapRelaxed(env$storage$map, env$storage$opt_selected)) {

    shiny::showNotification(
      "Map fully relaxed",
      closeButton = FALSE,
      duration = 1,
      type = "message",
      session = env$session
    )

  } else {

    shiny::showNotification(
      "Relaxing map...",
      closeButton = FALSE,
      duration = NULL,
      type = "message",
      id = "relax",
      session = env$session
    )

    # Convert point selections
    selections <- convertSelectedPoints(
      env$input$selectedPoints,
      env$storage$map
    )

    # Define fixed points
    fixed_ags <- rep(TRUE, numAntigens(env$storage$map))
    fixed_sr  <- rep(TRUE, numSera(env$storage$map))
    fixed_ags[selections$antigens] <- FALSE
    fixed_sr[selections$sera] <- FALSE

    # Relax map
    env$storage$map <- relaxMap(
      map = env$storage$map,
      optimization_number = env$storage$opt_selected,
      fixed_antigens = fixed_ags,
      fixed_sera = fixed_sr
    )

    # Get new stress
    newstress <- mapStress(
      env$storage$map,
      env$storage$opt_selected
    )

    # Animate coordinates to new optima
    env$session$sendCustomMessage("animateCoords", list(
      antigens = agCoords(env$storage$map, env$storage$opt_selected),
      sera     = srCoords(env$storage$map, env$storage$opt_selected),
      stress   = newstress
    ))
    env$session$sendCustomMessage("updateMapData", as.json(env$storage$map))

    # Notify on completion
    message(sprintf(
      "Map relaxed, new stress = %s",
      round(newstress, 2)
    ))

    shiny::showNotification(
      "Relaxing map... complete",
      closeButton = FALSE,
      duration = 1,
      type = "message",
      id = "relax",
      session = env$session
    )

  }

}

# Relax map on step
server_relaxMapOneStep <- function(env) {

  if (mapRelaxed(env$storage$map, env$storage$opt_selected)) {

    shiny::showNotification(
      "Map fully relaxed",
      closeButton = FALSE,
      duration = 1,
      type = "message",
      session = env$session
    )

  } else {

    env$storage$map <- relaxMapOneStep(env$storage$map, env$storage$opt_selected)
    newstress <- mapStress(env$storage$map, env$storage$opt_selected)

    env$session$sendCustomMessage("animateCoords", list(
      antigens = agCoords(env$storage$map, env$storage$opt_selected),
      sera     = srCoords(env$storage$map, env$storage$opt_selected),
      stress   = newstress
    ))
    env$session$sendCustomMessage("updateMapData", as.json(env$storage$map))

    message(sprintf(
      "Map relaxed, new stress = %s",
      round(newstress, 2)
    ))

  }

}

# Randomizing coords
server_randomizeMap <- function(env) {

  env$storage$map <- randomizeCoords(env$storage$map, env$storage$opt_selected)
  env$session$sendCustomMessage("reloadMapData", as.json(env$storage$map))

}
