
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
      }
      if(maptype == "racmap.cpp") {
        read.map <- read.acmap.cpp
        make.map <- acmap.cpp
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

