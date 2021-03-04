
# Load map data
server_loadMapData <- function(env) {

  shiny::showNotification(
    ui = "Loading map data...",
    duration = NULL,
    closeButton = FALSE,
    id = "loadmap",
    type = "message",
    session = env$session
  )

  env$storage$map <- read.acmap(env$input$mapDataLoaded$datapath)
  env$session$sendCustomMessage("loadMapData", as.json(env$storage$map))
  message("Map loaded.")

  shiny::showNotification(
    ui = "Loading map data... complete.",
    duration = 1,
    closeButton = FALSE,
    id = "loadmap",
    type = "message",
    session = env$session
  )

}

# Load table data
server_loadTableData <- function(env) {

  shiny::showNotification(
    ui = "Loading table data...",
    duration = NULL,
    closeButton = FALSE,
    id = "loadtable",
    type = "message",
    session = env$session
  )

  hitable <- read.titerTable(env$input$tableDataLoaded$datapath)
  env$storage$map <- acmap(titer_table = hitable)
  env$session$sendCustomMessage("loadMapData", as.json(env$storage$map))
  message("Table loaded.")

  shiny::showNotification(
    ui = "Loading table data... complete.",
    duration = 1,
    closeButton = FALSE,
    id = "loadtable",
    type = "message",
    session = env$session
  )

}


# Load point style data
server_loadPointStyleData <- function(env) {

  shiny::showNotification(
    ui = "Loading point styles... ",
    duration = NULL,
    closeButton = FALSE,
    id = "pointstyle",
    type = "message",
    session = env$session
  )

  message("Loading point styles...", appendLF = F)

  # Realign the optimizations
  plotspec_map <- read.acmap(env$input$pointStyleDataLoaded$datapath)
  env$storage$map <- applyPlotspec(env$storage$map, plotspec_map)

  # Reload the map data
  env$session$sendCustomMessage("reloadMapData", as.json(env$storage$map))

  message("done.")

  shiny::showNotification(
    ui = "Loading point styles... complete.",
    duration = 1,
    closeButton = FALSE,
    id = "pointstyle",
    type = "message",
    session = env$session
  )

}
