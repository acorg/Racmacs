
# Save map
server_saveMapData <- function(env) {

  savepath <- shinyFiles::parseSavePath(
    env$save_volumes,
    env$input$mapDataSaved
  )$datapath
  shiny::req(savepath)

  message("Saving map...", appendLF = F)

  # Convert point selections
  selections <- convertSelectedPoints(
    env$input$selectedPoints,
    env$storage$map
  )

  # Clone and subset map
  if (!isTRUE(selections$antigens) || !isTRUE(selections$sera)) {
    map <- subsetMap(env$storage$map, antigens = selections$antigens, sera = selections$sera)
  } else {
    map <- env$storage$map
  }

  # Save table
  save.acmap(map, savepath)
  message("done.")

}


# Save table
server_saveTableData <- function(env) {

  savepath <- shinyFiles::parseSavePath(env$save_volumes, env$input$tableDataSaved)$datapath
  shiny::req(savepath)

  message("Saving table...", appendLF = F)

  # Convert point selections
  selections <- convertSelectedPoints(
    env$input$selectedPoints,
    env$storage$map
  )

  # Save table
  save.titerTable(env$storage$map, savepath, antigens = selections$antigens, sera = selections$sera)
  message("done.")

}


# Save coords
server_saveCoordsData <- function(env) {

  savepath <- shinyFiles::parseSavePath(
    env$save_volumes,
    env$input$coordsDataSaved
  )$datapath
  shiny::req(savepath)

  message("Saving coords...", appendLF = F)

  # Convert point selections
  selections <- convertSelectedPoints(
    env$input$selectedPoints,
    env$storage$map
  )

  # Save coords
  save.coords(
    map = env$storage$map,
    filename = savepath,
    optimization_number = env$storage$opt_selected,
    antigens = selections$antigens,
    sera = selections$sera
  )
  message("done.")

}
