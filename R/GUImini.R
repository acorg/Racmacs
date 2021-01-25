
mapGUI <- function(
  map,
  jsinit = NULL,
  serverfn = NULL,
  height = NULL,
  width = NULL,
  ...) {

  # Check RStudio is running
  if (!rstudioapi::isAvailable()) {
    stop("This code must be run from within RStudio.")
  }

  # Prepare UI elements
  ui_elements <- list()
  ui_elements[[1]] <- RacViewerOutput("racViewer", height = "100%")

  # If javascript provided, include it with extendShinyjs
  if (!is.null(jsinit)) {
    ui_elements[[2]] <- shinyjs::useShinyjs()
    ui_elements[[3]] <- shinyjs::extendShinyjs(text = jsinit)
  }

  # Generate UI
  ui <- do.call(shiny::fillPage, ui_elements)

  # Make server
  server <- function(input, output, session, ...) {

    # Render the map in the viewer
    output$racViewer <- renderRacViewer({
      RacViewer(map)
    })

    # Run any additional server functions provided
    if (!is.null(serverfn)) {
      serverfn(input, output, ...)
    }

  }

  # Decide where to open the viewer
  if (is.null(height) && is.null(width)) {
    viewer <- shiny::paneViewer()
  } else if (!is.null(height) && !is.null(width)) {
    viewer <- shiny::dialogViewer("Mini viewer", width, height)
  } else {
    stop("Either neither or both of 'height' and 'width' must be provided.")
  }

  # Open the viewer
  suppressMessages({
    shiny::runGadget(
      app = ui,
      server = server,
      viewer = viewer
    )
  })

}
