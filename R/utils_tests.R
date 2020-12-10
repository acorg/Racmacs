
export.viewer.test <- function(widget, filename, widgetname = "RacViewer"){

  rootdir <- test_path("../testoutput/viewer")
  testfile <- file.path(normalizePath(rootdir), filename)

  htmlwidgets::saveWidget(
    widget,
    file          = testfile,
    selfcontained = FALSE,
    libdir        = ".lib"
  )

  unlink(file.path(rootdir, paste0(".lib/", widgetname,"-1.0.0")), recursive = T)

  plotdata <- readLines(testfile)
  if(widgetname == "RacViewer"){
    plotdata <- gsub(
      pattern     = paste0(".lib/", widgetname, "-1.0.0/"),
      replacement = paste0("../../../../inst/htmlwidgets/", widgetname, "/lib/"),
      x           = plotdata,
      fixed       = TRUE
    )
  } else {
    plotdata <- gsub(
      pattern     = paste0(".lib/", widgetname, "-1.0.0/"),
      replacement = paste0("../../../../inst/htmlwidgets/"),
      x           = plotdata,
      fixed       = TRUE
    )
  }
  writeLines(plotdata, testfile)

  # Add a test to check plot was outputted correctly
  expect_true(file.exists(testfile))

}



