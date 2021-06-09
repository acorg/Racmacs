
ui <- shiny::fillPage(
  bootstrap = TRUE,
  shiny::includeScript("www/racmacs.js"),
  RacViewerOutput("racViewer"),
  div(
    shiny::fileInput(inputId = "mapDataLoaded", label = "mapDataLoaded", accept = ".ace"),
    shiny::fileInput(inputId = "tableDataLoaded", label = "tableDataLoaded", accept = ".csv,.txt"),
    shiny::fileInput(inputId = "procrustesDataLoaded", label = "procrustesDataLoaded", accept = ".ace"),
    shiny::fileInput(inputId = "pointStyleDataLoaded", label = "pointStyleDataLoaded", accept = ".ace"),
    shinyFiles::shinySaveButton(id = "mapDataSaved",    label = "", title = "", filename = "acmap",  list(ace = ".ace")),
    shinyFiles::shinySaveButton(id = "tableDataSaved",  label = "", title = "", filename = "table",  list(csv = ".csv")),
    shinyFiles::shinySaveButton(id = "coordsDataSaved", label = "", title = "", filename = "coords", list(csv = ".csv")),
    style = "display: none;"
  )
)
