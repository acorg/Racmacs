
mapGUI_server <- function(map = NULL){
  function(input, output, session) {

    # Set application environment
    env <- environment()

    # General setup
    ## Create a reactive values object for storing data that will change
    ## during the user session
    storage <- shiny::reactiveValues(
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
    shiny::observeEvent(
      input$mapDataLoaded,
      server_loadMapData(env)
    )

    ## Loading a table file
    shiny::observeEvent(
      input$tableDataLoaded,
      server_loadTableData(env)
    )

    ## Save a map file
    shiny::observeEvent(
      input$mapDataSaved,
      server_saveMapData(env)
    )

    ## Save a table file
    shiny::observeEvent(
      input$tableDataSaved,
      server_saveTableData(env)
    )

    ## Save a coords file
    shiny::observeEvent(
      input$coordsDataSaved,
      server_saveCoordsData(env)
    )

    ## Switching to a new optimization
    shiny::observeEvent(
      input$optimizationChanged,
      server_optimizationChanged(env)
    )

    ## Reflecting the map
    shiny::observeEvent(
      input$reflectMap,
      server_reflectMap(env)
    )

    ## Running new optimisations
    shiny::observeEvent(
      input$runOptimizations,
      server_runOptimizations(env)
    )

    ## Updating coordinates
    shiny::observeEvent(
      input$coordsChanged,
      server_coordsChanged(env)
    )

    ## Map relaxed
    shiny::observeEvent(
      input$relaxMap,
      server_relaxMap(env)
    )

    ## Relax map one step
    shiny::observeEvent(
      input$relaxMapOneStep,
      server_relaxMapOneStep(env)
    )

    ## Randomize map coordinates
    shiny::observeEvent(
      input$randomizeMap,
      server_randomizeMap(env)
    )

    ## Add stress blobs
    shiny::observeEvent(
      input$triangulationBlobs,
      server_triangulationBlobs(env)
    )

    ## Add hemisphering data
    shiny::observeEvent(
      input$checkHemisphering,
      server_checkHemisphering(env)
    )

    ## Move trapped points
    shiny::observeEvent(
      input$moveTrappedPoints,
      server_moveTrappedPoints(env)
    )

    ## Procrustes
    shiny::observeEvent(
      input$procrustesDataLoaded,
      server_procrustesMap(env)
    )

    ## Orient optimizations
    shiny::observeEvent(
      input$alignOptimizations,
      server_alignOptimizations(env)
    )

    ## Remove optimizations
    shiny::observeEvent(
      input$removeOptimizations,
      server_removeOptimizations(env)
    )

    ## Load point styles
    shiny::observeEvent(
      input$pointStyleDataLoaded,
      server_loadPointStyleData(env)
    )

  }
}
