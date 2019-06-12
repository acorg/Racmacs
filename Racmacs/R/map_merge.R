
#' Merging maps
#'
#' Functions to merge together two tables or maps.
#'
#' @param map1 The first map
#' @param map2 The second map
#' @param passage_matching Passage matching
#' @param optimization_number_map1 Optimization number from the first map to merge
#' @param optimization_number_map2 Optimization number from the second map to merge
#' @param method Merging method
#' @param optimizations Number of optimization runs to perform (for 'incremental method')
#'
#' @details Maps can be merged in a number of ways depending upon the desired result.
#'
#' \subsection{Method 'table'}{
#' This merges the tables of the two maps but does not attempt to create any new optimizations.
#' }
#'
#' \subsection{Method 'incremental'}{
#' The default or specified optimization of the first map is copied to the resulting
#' map, optimizations of the second (merged in) map are ignored. Positions of
#' points that are in the merged-in map and not in the first map are
#' randomized and resulting layout relaxed.
#' }
#'
#' \subsection{Method 'frozen'}{
#' This takes the default or specified optimization from the second map and
#' realigns it to the default or specifed optimization of the first map using
#' procrustes, then points that are found just in the second map receive
#' coordinates from that realigned optimization. Points that are common for the
#' first and the second map placed to their middle positions between the first
#' map layout and realigned second map layout.
#' }
#'
#' \subsection{Method 'overlay'}{
#' Frozen merge followed by relaxation of the resulting optimization.
#' }
#'
#' @return Returns the merged map data or merge report.
#'
#' @name merging_maps
#'
NULL

#' @rdname merging_maps
#' @export
mergeReport <- function(map1,
                        map2,
                        passage_matching = "auto"){

  # Convert the maps
  if(class(map1)[1] == "racmap") map1 <- as.cpp(map1)
  if(class(map2)[1] == "racmap") map2 <- as.cpp(map2)

  report <- acmacs.r::acmacs.merge_report(map1$chart, map2$chart)
  message(report)
  invisible(report)

}


#' @rdname merging_maps
#' @export
mergeMaps <- function(map1,
                      map2,
                      method = "table",
                      passage_matching = "auto",
                      optimization_number_map1 = NULL,
                      optimization_number_map2 = NULL,
                      optimizations = 100){

  # Check that optimizations isn't specified with one of the other methods
  if(!missing(optimizations) && method != "incremental"){
    stop("Number of optimizations is only relevant for the merging method 'incremental'.")
  }

  # Keep a record of the map class
  map1_class <- class(map1)[1]

  # Convert or clone the maps
  if(class(map1)[1] == "racmap") map1 <- as.cpp(map1)
  else                           map1 <- cloneMap(map1)
  if(class(map2)[1] == "racmap") map2 <- as.cpp(map2)
  else                           map2 <- cloneMap(map2)

  # Keep only the required optimizations
  if(method != "none" && method != "table"){
    if(is.null(optimization_number_map1)) optimization_number_map1 <- selectedOptimization(map1)
    map1 <- keepSingleOptimization(map1, optimization_number_map1)
    if(method != "incremental"){
      if(is.null(optimization_number_map2)) optimization_number_map2 <- selectedOptimization(map2)
      map2 <- keepSingleOptimization(map2, optimization_number_map2)
    }
  }

  # Merge the charts
  if(method == "incremental"){

    if(isTRUE(getOption("Racmacs.parallel"))) threads <- 0
    else                                      threads <- 1

    if(passage_matching != "auto") stop("Only automatic passage matching is supported for incremental merges.")

    merged_chart <- acmacs.r::acmacs.merge_incremental(
      chart1        = map1$chart,
      chart2        = map2$chart,
      optimizations = optimizations,
      threads       = threads
    )

  } else if(method == "frozen"){

    merged_chart <- acmacs.r::acmacs.merge(
      chart1 = map1$chart,
      chart2 = map2$chart,
      match  = passage_matching,
      merge  = "overlay"
    )

  } else if(method == "overlay"){

    merged_chart <- acmacs.r::acmacs.merge(
      chart1 = map1$chart,
      chart2 = map2$chart,
      match  = passage_matching,
      merge  = "overlay"
    )
    merged_chart$projections[[1]]$relax()

  } else if(method == "table"){

    merged_chart <- acmacs.r::acmacs.merge(
      chart1 = map1$chart,
      chart2 = map2$chart,
      match  = passage_matching,
      merge  = "none"
    )

  } else {

    stop("'merge' must be one of 'table', 'incremental', 'frozen', 'overlay'.")

  }

  # Return a new map
  merged_map <- acmap.new(chart = merged_chart)
  if(method != "table")      selectedOptimization(merged_map) <- 1
  if(map1_class == "racmap") merged_map <- as.list(merged_map)
  merged_map

}



