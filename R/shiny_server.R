
mapGUI_server <- function(map = NULL){
  function(input, output, session) {

    # Set application environment
    env <- environment()

    # General setup
    ## Create a reactive values object for storing data that will change
    ## during the user session
    storage <- reactiveValues(
      map = map,       # The map object of a loaded map
      opt_selected = 1 # The optimization number currently selected
    )

    ## Populate the racViewer UI with a blank RacViewer
    output$racViewer <- renderRacViewer({
      RacViewer(
        map = map,
        options = list(
          viewer.controls = "shown"
        )
      )
    })

    ## Set save volumes
    save_volumes <- c(
      "home" = path.expand("~/")
    )

    ## Setup for save listeners
    shinyFiles::shinyFileSave(
      input, "mapDataSaved",
      session = session,
      roots = save_volumes
    )
    shinyFiles::shinyFileSave(
      input, "tableDataSaved",
      session = session,
      roots = save_volumes
    )
    shinyFiles::shinyFileSave(
      input, "coordsDataSaved",
      session = session,
      roots = save_volumes
    )


    # Event listeners
    ## Loading a map file
    observeEvent(
      input$mapDataLoaded,
      server_loadMapData(env)
    )

    ## Loading a table file
    observeEvent(
      input$tableDataLoaded,
      server_loadTableData(env)
    )

    ## Save a map file
    observeEvent(
      input$mapDataSaved,
      server_saveMapData(env)
    )

    ## Save a table file
    observeEvent(
      input$tableDataSaved,
      server_saveTableData(env)
    )

    ## Save a coords file
    observeEvent(
      input$coordsDataSaved,
      server_saveCoordsData(env)
    )

    ## Switching to a new optimization
    observeEvent(
      input$optimizationChanged,
      server_optimizationChanged(env)
    )

    ## Reflecting the map
    observeEvent(
      input$reflectMap,
      server_reflectMap(env)
    )

    ## Running new optimisations
    observeEvent(
      input$runOptimizations,
      server_runOptimizations(env)
    )

    ## Updating coordinates
    observeEvent(
      input$coordsChanged,
      server_coordsChanged(env)
    )

    ## Map relaxed
    observeEvent(
      input$relaxMap,
      server_relaxMap(env)
    )

    ## Relax map one step
    observeEvent(
      input$relaxMapOneStep,
      server_relaxMapOneStep(env)
    )

    ## Randomize map coordinates
    observeEvent(
      input$randomizeMap,
      server_randomizeMap(env)
    )

    ## Add stress blobs
    observeEvent(
      input$triangulationBlobs,
      server_triangulationBlobs(env)
    )

    ## Add hemisphering data
    observeEvent(
      input$checkHemisphering,
      server_checkHemisphering(env)
    )

    ## Move trapped points
    observeEvent(
      input$moveTrappedPoints,
      server_moveTrappedPoints(env)
    )

    ## Procrustes
    observeEvent(
      input$procrustesDataLoaded,
      server_procrustesMap(env)
    )

    ## Orient optimizations
    observeEvent(
      input$alignOptimizations,
      server_alignOptimizations(env)
    )

    ## Remove optimizations
    observeEvent(
      input$removeOptimizations,
      server_removeOptimizations(env)
    )

    ## Load point styles
    observeEvent(
      input$pointStyleDataLoaded,
      server_loadPointStyleData(env)
    )

  }
}
