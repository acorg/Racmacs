
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

    env$storage$map <- relaxMap(env$storage$map, env$storage$opt_selected)
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
