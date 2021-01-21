
## Racmacs shiny web application

# Load the required packages
library(shiny)
library(shinyFiles)
library(shinyjs)
library(Racmacs)


# This is the server function which controls how the input data is processed
server <- function(input, output, session) {

  # Set save volumes
  save_volumes <- c("home" = path.expand("~/"))

  # General setup
  ## Create a reactive values object for storing data that will change
  ## during the user session
  storage <- reactiveValues(
    map = NULL # The map object of a loaded map
  )

  ## Populate the racViewer UI with a blank RacViewer
  output$racViewer <- renderRacViewer({
    RacViewer(
      map      = NULL,
      controls = "shown"
    )
  })

  ## Setup for save listeners
  shinyFileSave(input, "mapDataSaved",
                session = session,
                roots = save_volumes)
  shinyFileSave(input, "tableDataSaved",
                session = session,
                roots = save_volumes)
  shinyFileSave(input, "coordsDataSaved",
                session = session,
                roots = save_volumes)


  # Event listeners
  ## Loading a map file
  observeEvent(input$mapDataLoaded, {

    shiny::showNotification(
      ui = "Loading map data...",
      duration = NULL,
      closeButton = FALSE,
      id = "loadmap",
      type = "message"
    )

    storage$map <- read.acmap(input$mapDataLoaded$datapath)
    session$sendCustomMessage("loadMapData", as.json(storage$map))
    message("Map loaded.")

    shiny::showNotification(
      ui = "Loading map data... complete.",
      duration = 1,
      closeButton = FALSE,
      id = "loadmap",
      type = "message"
    )

  })

  ## Loading a table file
  observeEvent(input$tableDataLoaded, {

    shiny::showNotification(
      ui = "Loading table data...",
      duration = NULL,
      closeButton = FALSE,
      id = "loadtable",
      type = "message"
    )

    hitable <- read.titerTable(input$tableDataLoaded$datapath)
    storage$map <- acmap.cpp(table = hitable)
    session$sendCustomMessage("loadMapData", as.json(storage$map))
    message("Table loaded.")

    shiny::showNotification(
      ui = "Loading table data... complete.",
      duration = 1,
      closeButton = FALSE,
      id = "loadtable",
      type = "message"
    )

  })

  ## Save a map file
  observeEvent(input$mapDataSaved, {

    savepath <- shinyFiles::parseSavePath(save_volumes, input$mapDataSaved)$datapath
    req(savepath)

    message("Saving map...", appendLF = F)

    # Convert point selections
    selections <- convertSelectedPoints(
      input$selectedPoints,
      storage$map
    )

    # Clone and subset map
    if(!isTRUE(selections$antigens) || !isTRUE(selections$sera)){
      map <- cloneMap(storage$map)
      map <- subsetMap(map, antigens = selections$antigens, sera = selections$sera)
    } else {
      map <- storage$map
    }

    # Save table
    save.acmap(map, savepath)
    message("done.")

  })

  ## Save a table file
  observeEvent(input$tableDataSaved, {

    savepath <- shinyFiles::parseSavePath(save_volumes, input$tableDataSaved)$datapath
    req(savepath)

    message("Saving table...", appendLF = F)

    # Convert point selections
    selections <- convertSelectedPoints(
      input$selectedPoints,
      storage$map
    )

    # Save table
    save.titerTable(storage$map, savepath, antigens = selections$antigens, sera = selections$sera)
    message("done.")

  })

  ## Save a coords file
  observeEvent(input$coordsDataSaved, {

    savepath <- shinyFiles::parseSavePath(save_volumes, input$coordsDataSaved)$datapath
    req(savepath)

    message("Saving coords...", appendLF = F)

    # Convert point selections
    selections <- convertSelectedPoints(
      input$selectedPoints,
      storage$map
    )

    # Save table
    save.coords(storage$map, savepath, antigens = selections$antigens, sera = selections$sera)
    message("done.")

  })

  ## Switching to a new optimization
  observeEvent(input$optimizationChanged, {
    stop()
  })

  ## Reflecting the map
  observeEvent(input$reflectMap, {
    message("Map reflected.")
    storage$map <- reflectMap(storage$map, axis = input$reflectMap)
    session$sendCustomMessage("setCoords", list(
      antigens = agCoords(storage$map),
      sera     = srCoords(storage$map)
    ))
  })

  ## Running new optimisations
  observeEvent(input$runOptimizations, {

    shiny::showNotification(
      ui = "Optimizing map...",
      duration = NULL,
      closeButton = FALSE,
      id = "optimizing",
      type = "message"
    )

    # Optimise the map
    storage$map <- optimizeMap(
      map = storage$map,
      number_of_dimensions    = as.numeric(input$runOptimizations$numdims),
      number_of_optimizations = as.numeric(input$runOptimizations$numruns),
      minimum_column_basis    = input$runOptimizations$mincolbasis,
      sort_optimizations        = TRUE,
      discard_previous_optimizations = FALSE,
      realign_optimizations    = TRUE
    )

    shiny::showNotification(
      ui = "Optimizing map... complete.",
      duration = 1,
      closeButton = FALSE,
      id = "optimizing",
      type = "message"
    )

    # Reload the map
    session$sendCustomMessage("loadMapData", as.json(storage$map))

  })

  ## Updating coordinates
  observeEvent(input$coordsChanged, {
    agCoords(storage$map) <- list2matrix(input$coordsChanged$antigens)
    srCoords(storage$map) <- list2matrix(input$coordsChanged$sera)
    message("Coordinates updated.")
  })

  ## Map relaxed
  observeEvent(input$relaxMap, {
    if(mapRelaxed(storage$map)){
      shiny::showNotification("Map fully relaxed", closeButton = FALSE, duration = 1, type = "message")
    } else {
      shiny::showNotification("Relaxing map...", closeButton = FALSE, duration = NULL, type = "message", id = "relax")
      storage$map <- relaxMap(storage$map)
      session$sendCustomMessage("animateCoords", list(
        antigens = agCoords(storage$map),
        sera     = srCoords(storage$map)
      ))
      message("Map relaxed, new stress = ", round(mapStress(storage$map), 2), ".")
      shiny::showNotification("Relaxing map... complete", closeButton = FALSE, duration = 1, type = "message", id = "relax")
    }
  })

  ## Relax map one step
  observeEvent(input$relaxMapOneStep, {
    if(mapRelaxed(storage$map)){
      shiny::showNotification("Map fully relaxed", closeButton = FALSE, duration = 1, type = "message")
    } else {
      storage$map <- relaxMapOneStep(storage$map)
      session$sendCustomMessage("animateCoords", list(
        antigens = agCoords(storage$map),
        sera     = srCoords(storage$map)
      ))
      message("Map relaxed one step, new stress = ", round(mapStress(storage$map), 2), ".")
    }
  })

  ## Randomize map coordinates
  observeEvent(input$randomizeMap, {

    storage$map <- randomizeCoords(storage$map)
    session$sendCustomMessage("setCoords", list(
      antigens = agCoords(storage$map),
      sera     = srCoords(storage$map)
    ))

  })

  ## Add stress blobs
  observeEvent(input$stressBlobs, {

    # shiny::showNotification(
    #   ui = "Calculating blobs...",
    #   duration = NULL,
    #   closeButton = FALSE,
    #   id = "blobs",
    #   type = "message"
    # )

    # Convert point selections
    point_selections <- convertSelectedPoints(
      input$stressBlobs$selected_points,
      storage$map
    )

    # Calculate blob data
    withProgress(
      message = 'Calculating stress blobs',
      value = 0, {
        blob_data <- calculate_stressBlob(
          map          = storage$map,
          stress_lim   = as.numeric(input$stressBlobs$stresslim),
          grid_spacing = as.numeric(input$stressBlobs$gridspacing),
          grid_margin  = as.numeric(input$stressBlobs$gridmargin),
          antigens     = point_selections$antigens,
          sera         = point_selections$sera,
          progress_fn  = setProgress
        )
      }
    )


    # Add to the map
    storage$map <- add_stressBlobData(
      map = storage$map,
      data = blob_data
    )

    # shiny::showNotification(
    #   ui = "Calculating blobs... complete.",
    #   duration = 1,
    #   closeButton = FALSE,
    #   id = "blobs",
    #   type = "message"
    # )

    # Reload the map
    session$sendCustomMessage("reloadMapData", as.json(storage$map))

  })

  ## Add hemisphering data
  observeEvent(input$checkHemisphering, {

    shiny::showNotification(
      ui = "Checking for hemisphering points...",
      duration = NULL,
      closeButton = FALSE,
      id = "hemisphering",
      type = "message"
    )

    message("Checking for hemisphering points...")

    execute({

      hemispheringData <- checkHemisphering(storage$map)
      storage$map <- add_hemispheringData(storage$map, hemispheringData)
      # session$sendCustomMessage("addHemispheringData", data2json(hemispheringData))
      session$sendCustomMessage("reloadMapData", as.json(storage$map))
      print(hemispheringData)

    })

    shiny::showNotification(
      ui = "Checking for hemisphering points... complete.",
      duration = 1,
      closeButton = FALSE,
      id = "hemisphering",
      type = "message"
    )

  })

  ## Move trapped points
  observeEvent(input$moveTrappedPoints, {

    shiny::showNotification(
      ui = "Moving trapped points...",
      duration = NULL,
      closeButton = FALSE,
      id = "moving",
      type = "message"
    )

    message("Moving trapped points...", appendLF = FALSE)
    storage$map <- moveTrappedPoints(storage$map)
    session$sendCustomMessage("animateCoords", list(
      antigens = agCoords(storage$map),
      sera     = srCoords(storage$map)
    ))
    message("done.")

    shiny::showNotification(
      ui = "Moving trapped points... complete.",
      duration = 1,
      closeButton = FALSE,
      id = "moving",
      type = "message"
    )

  })

  ## Procrustes
  observeEvent(input$procrustesDataLoaded, {

    shiny::showNotification(
      ui = "Calculating procrustes... ",
      duration = NULL,
      closeButton = FALSE,
      id = "procrustes",
      type = "message"
    )

    # Convert point selections
    point_selections <- convertSelectedPoints(
      input$procrustes$selected_points,
      storage$map
    )

    # Read in the procrustes map
    pcmap <- read.acmap(
      filename            = input$procrustesDataLoaded$datapath,
      optimization_number = as.numeric(input$procrustes$optimization)
    )

    # Calculate the procrustes data
    storage$map <- add_procrustesData(
      map        = storage$map,
      target_map = pcmap,
      antigens = point_selections$antigens,
      sera     = point_selections$sera
    )

    # Reload the map data
    session$sendCustomMessage("reloadMapData", as.json(storage$map))

    shiny::showNotification(
      ui = "Calculating procrustes... complete.",
      duration = 1,
      closeButton = FALSE,
      id = "procrustes",
      type = "message"
    )

  })

  ## Orient optimizations
  observeEvent(input$alignOptimizations, {

    shiny::showNotification(
      ui = "Aligning optimizations... ",
      duration = NULL,
      closeButton = FALSE,
      id = "orienting",
      type = "message"
    )

    message("Orienting optimizations...", appendLF = F)

    # Realign the optimizations
    storage$map <- realignOptimizations(storage$map)

    # Reload the map data
    session$sendCustomMessage("reloadMapData", as.json(storage$map))

    message("done.")

    shiny::showNotification(
      ui = "Aligning optimizations... complete.",
      duration = 1,
      closeButton = FALSE,
      id = "orienting",
      type = "message"
    )

  })



  ## Remove optimizations
  observeEvent(input$removeOptimizations, {

    shiny::showNotification(
      ui = "Removing optimizations... ",
      duration = NULL,
      closeButton = FALSE,
      id = "removing",
      type = "message"
    )

    message("Removing optimizations...", appendLF = F)

    # Realign the optimizations
    storage$map <- removeOptimizations(storage$map)

    # Reload the map data
    session$sendCustomMessage("reloadMapData", as.json(storage$map))

    message("done.")

    shiny::showNotification(
      ui = "Removing optimizations... complete.",
      duration = 1,
      closeButton = FALSE,
      id = "removing",
      type = "message"
    )

  })


  ## Load point styles
  observeEvent(input$pointStyleDataLoaded, {

    shiny::showNotification(
      ui = "Loading point styles... ",
      duration = NULL,
      closeButton = FALSE,
      id = "pointstyle",
      type = "message"
    )

    message("Loading point styles...", appendLF = F)

    # Realign the optimizations
    plotspec_map <- read.acmap(input$pointStyleDataLoaded$datapath)
    execute({
      storage$map <- applyPlotspec(storage$map, plotspec_map)
    })

    # Reload the map data
    session$sendCustomMessage("reloadMapData", as.json(storage$map))

    message("done.")

    shiny::showNotification(
      ui = "Loading point styles... complete.",
      duration = 1,
      closeButton = FALSE,
      id = "pointstyle",
      type = "message"
    )

  })

}













