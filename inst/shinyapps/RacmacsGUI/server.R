
# Racmacs shiny web application
options(shiny.maxRequestSize = 30*1024^2)

# This is the server function which controls how the input data is processed
server <- mapGUI_server()
