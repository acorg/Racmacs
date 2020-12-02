
racchart.new <- function(chart){

  # The racchart is fundamentally an environment
  acchart <- new.env(parent = emptyenv())
  class(acchart) <- c("racchart", "rac", "environment")
  acchart$chart <- chart

  # Return the chart
  acchart

}


#' @rdname convertingMaps
#' @family {functions for working with map data}
#' @export
as.cpp <- function(map){

  if("racchart" %in% class(map)) return(map)
  json <- as.json(map)
  tmp <- tempfile(fileext = ".ace")
  write(json, tmp)

  chart <- suppressMessages({ new(acmacs.r::acmacs.Chart, tmp) })
  map.cpp <- racchart.new(chart = chart)

  selectedOptimization(map.cpp) <- selectedOptimization(map)
  map.cpp

}
