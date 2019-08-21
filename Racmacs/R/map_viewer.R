

#' View map in the interactive viewer
#'
#' @param map The acmap data object
#'
#' @export
#'
view_map <- function(map,
                     ...) {

  # View the map data in the viewer
  widget <- RacViewer(map = map,
                      hide_control_panel = TRUE,
                      ...)

  # Return the widget as an output
  widget

}


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
                          selfcontained = TRUE,
                          ...){

  # Check file has .html extension
  if(!grepl("\\.html$", file)){
    stop("File extension must be '.html'")
  }

  # Export the widget to a temporary file first
  tmp_file <- tempfile(fileext = ".html")
  widget <- view_map(map, ...)

  htmlwidgets::saveWidget(widget        = widget,
                          file          = tmp_file,
                          selfcontained = selfcontained)

  # Move the file to the proper location
  file.copy(from = tmp_file,
            to   = file,
            overwrite = TRUE)

  # Remove the temporary file
  unlink(tmp_file)

  # Return NULL
  invisible(NULL)

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
write2viewer_debug <- function(mapData){

  mapData <- process_mapViewerData(mapData)
  write(x    = paste0("json_data = '", jsonlite::toJSON(mapData), "';\n\nvar plotData = JSON.parse(json_data);"),
        file = "~/Dropbox/LabBook/R-acmacs/Racmacs/inst/htmlwidgets/RacViewer/tests/data/bug.js")

}


#' Write map data to the viewer test file
#'
write2viewer_tests <- function(mapData, filename){

  mapData <- process_mapViewerData(mapData)
  write(x    = paste0("json_data = '", jsonlite::toJSON(mapData), "';\n\nvar plotData = JSON.parse(json_data);"),
        file = file.path("~/Dropbox/LabBook/R-acmacs/Racmacs/inst/htmlwidgets/RacViewer/tests/data/", filename))

}



