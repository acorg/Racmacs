
run.maptests <- function(expr, bothclasses = FALSE, loadlocally = FALSE){

  if(loadlocally){
    invisible(lapply(rev(list.files("R", full.names = T)), source))
    warning("Functions loaded locally")
  }

  if(bothclasses){
    for(maptype in c("racmap", "racmap.cpp")){

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


export.viewer.test <- function(widget, filename){

  maptype <- get0("maptype", parent.frame())
  if(!is.null(maptype)){ filename <- gsub("\\.html$", paste0("_", maptype, ".html"), filename) }
  testfile <- file.path("~/Dropbox/LabBook/packages/Racmacs/tests/testoutput", filename)

  htmlwidgets::saveWidget(
    widget,
    file          = testfile,
    selfcontained = FALSE,
    libdir        = ".lib"
  )

  unlink("tests/testoutput/.lib/RacViewer-1.0.0/")

  plotdata <- readLines(testfile)
  plotdata <- gsub(
    pattern     = ".lib/RacViewer-1.0.0/",
    replacement = "../../inst/htmlwidgets/RacViewer/lib/",
    x           = plotdata,
    fixed       = TRUE
  )
  writeLines(plotdata, testfile)

}


