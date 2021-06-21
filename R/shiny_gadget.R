
mapGadget <- function(map) {

  ui <- mapGUI_ui()
  server <- mapGUI_server(map)
  shiny::runGadget(ui, server)

}
