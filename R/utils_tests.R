
run.maptests <- function(expr, bothclasses = FALSE, loadlocally = FALSE){

  if(loadlocally){
    invisible(lapply(rev(list.files("R", full.names = T)), source))
    warning("Functions loaded locally")
  }

  if(bothclasses){
    for(maptype in c("racmap", "racmap.cpp")){

      set.seed(100)

      if(maptype == "racmap")     {
        read.map <- read.acmap
        make.map <- acmap
        make.newmap <- make.acmap
      }
      if(maptype == "racmap.cpp") {
        read.map <- read.acmap.cpp
        make.map <- acmap.cpp
        make.newmap <- make.acmap.cpp
      }

      test_that <- function(desc, code){
        testthat::test_that(
          desc = paste0(maptype, ": ", desc),
          code = code
        )
      }

      eval(substitute(expr))

    }
  } else {
    eval(substitute(expr))
  }

}


export.viewer.test <- function(widget, filename, widgetname = "RacViewer"){

  maptype <- get0("maptype", parent.frame())
  if(is.null(maptype) || maptype == "racmap"){
    rootdir <- test_path("../testoutput/viewer/racmap")
  } else {
    rootdir <- test_path("../testoutput/viewer/racmap.cpp")
  }
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


