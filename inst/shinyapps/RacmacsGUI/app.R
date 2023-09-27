
# Racmacs shiny web application
old <- options()
on.exit(options(old))
options(shiny.maxRequestSize = 30*1024^2)

# This is the user interface function which controls user interface setup
ui <- Racmacs:::mapGUI_ui()

# This is the server function which controls how the input data is processed
server <- Racmacs:::mapGUI_server()

# This creates the actual app that will run
shinyApp(ui, server)
