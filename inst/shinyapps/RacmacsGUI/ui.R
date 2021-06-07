
ui <- shiny::fillPage(
  bootstrap = TRUE,
  shiny::includeScript("www/racmacs.js"),
  RacViewerOutput("racViewer"),
  div(
    shiny::fileInput(inputId = "mapDataLoaded", label = "mapDataLoaded", accept = ".ace"),
    shiny::tags$input(id = "tableDataLoaded",      name = "tableDataLoaded",      type = "file", accept = ".csv,.txt"),
    shiny::tags$input(id = "procrustesDataLoaded", name = "procrustesDataLoaded", type = "file", accept = ".ace"),
    shiny::tags$input(id = "pointStyleDataLoaded", name = "pointStyleDataLoaded", type = "file", accept = ".ace"),
    shinyFiles::shinySaveButton(id = "mapDataSaved",    label = "", title = "", filename = "acmap",  list(ace = ".ace")),
    shinyFiles::shinySaveButton(id = "tableDataSaved",  label = "", title = "", filename = "table",  list(csv = ".csv")),
    shinyFiles::shinySaveButton(id = "coordsDataSaved", label = "", title = "", filename = "coords", list(csv = ".csv")),
    style = "display: none;"
  )
)
