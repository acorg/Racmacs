

# @export view_map
# view_map <- view.rac


#' Export the map viewer
#'
#' Export a map in a standalone html viewer
#'
#' @param map The acmap object
#' @param file html file to output to
#' @param selfcontained Self-contained html file
#'
#' @export
#'
export_viewer <- function(map,
                          file,
                          selfcontained,
                          ...){

  # Check file has .html extension
  if(!grepl("\\.html$", file)){
    stop("File extension must be '.html'")
  }

  # Export the widget to a temporary file first
  tmp_file <- tempfile(fileext = ".html")
  widget <- view_map(map, ...)

  widget <- htmlwidgets::saveWidget(widget        = widget,
                                    file          = tmp_file,
                                    selfcontained = selfcontained)

  # Move the file to the proper location
  file.copy(from = tmp_file,
            to   = file,
            overwrite = TRUE)

  # Remove the temporary file
  unlink(tmp_file)

  # Return the widget
  widget

}

encode_base64 <- function(img){

  suppressWarnings({
    img_data <- RCurl::base64Encode(readBin(img, "raw", file.info(img)[1, "size"], "txt"))
  })
  paste0("data:image/png;base64,", img_data)

}


#' Write map data to the viewer debug file
#'
#' For usage debugging problems with the viewer.
#'
write2viewer_debug <- function(map, snapshot = FALSE){

  if(snapshot){
    snaphottxt <- sprintf("var placeholder = '%s';", snapshotMap(map))
  } else {
    snaphottxt <- "var placeholder = false;"
  }

  # # Create a placeholder image file
  # tmp <- tempfile()
  # png(tmp, 400, 400)
  #   par(mar = c(0,0,0,0))
  #   plot(map)
  # dev.off()
  # placeholder <- encode_base64(tmp)

  # Read the yaml file
  yaml    <- yaml::read_yaml("inst/htmlwidgets/RacViewer.yaml")
  src     <- "../../lib"
  styles  <- file.path(src, yaml$dependencies[[1]]$stylesheet)
  scripts <- file.path(src, yaml$dependencies[[1]]$script)

  # Setup the html file
  html <- c(
    "<html>",
      "<head>",
        paste0('<link rel="stylesheet" type="text/css" href="', styles, '">'),
        paste0('<script src="', scripts, '"></script>'),
        '<script src="../../tests/tests.js"></script>',
        '<script>',
          'window.onload = function() {',
            'var container   = document.getElementById("rac-viewer");',
            snaphottxt,
            paste0('var mapData = JSON.parse(`', as.json(map),'`);'),
            paste0('mapData.procrustes = ', jsonlite::toJSON(map$procrustes)),
            paste0('var plotdata = ', jsonlite::toJSON(map$plot)),
            #'var viewer = new Racmacs.Viewer(container, { placeholder: placeholder });',
            'var viewer = new Racmacs.Viewer(container);',
            'viewer.load(mapData, { hide_control_panel:true }, plotdata, placeholder);',
            #'viewertest(viewer)',
          '};',
        '</script>',
      "</head>",
      "<body>",
        '<div id="rac-viewer" style="width: 1000px; height: 800px;"></div>',
        #'<div id="rac-viewer" style="position:absolute; top:0; left:0; right:0; bottom:0;"></div>',
      "</body>",
    "</html>"
  )

  # Write the file
  writeLines(html, "inst/htmlwidgets/RacViewer/tests/pages/bug.html")

}


#' Write map data to the viewer test file
#'
write2viewer_tests <- function(map, filename){

  # Read the yaml file
  yaml    <- yaml::read_yaml("inst/htmlwidgets/RacViewer.yaml")
  src     <- "../../lib"
  styles  <- file.path(src, yaml$dependencies[[1]]$stylesheet)
  scripts <- file.path(src, yaml$dependencies[[1]]$script)

  # Setup the html file
  html <- c(
    "<html>",
    "<head>",
    paste0('<link rel="stylesheet" type="text/css" href="', styles, '">'),
    paste0('<script src="', scripts, '"></script>'),
    '<script src="../../tests/tests.js"></script>',
    '<script>',
    'window.onload = function() {',
    'var container   = document.getElementById("rac-viewer");',
    paste0('var mapData = JSON.parse(`', as.json(map),'`);'),
    'var viewer = new Racmacs.Viewer(container);',
    'viewer.load(mapData, { hide_control_panel:true });',
    '};',
    '</script>',
    "</head>",
    "<body>",
    # '<div id="rac-viewer" style="width: 1000px; height: 800px;"></div>',
    '<div id="rac-viewer" style="position:absolute; top:0; left:0; right:0; bottom:0;"></div>',
    "</body>",
    "</html>"
  )

  # Write the file
  writeLines(html, file.path("inst/htmlwidgets/RacViewer/tests/pages", filename))

}

write2testdata <- function(variable, data, filename){

  html <- sprintf("var %s = JSON.parse(`%s`);", variable, data)
  writeLines(html, file.path("inst/htmlwidgets/RacViewer/tests/data", filename))

}



