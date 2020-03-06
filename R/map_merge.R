
#' Merging maps
#'
#' Functions to merge together two tables or maps.
#'
#' @param ... Antigenic map objects to merge
#' @param method The merging method to use (see below)
#' @param passage_matching Passage matching
#' @param minimum_column_basis The minimum column basis to assume when creating new maps after a merge
#' @param number_of_optimizations The number of optimization runs to perform when doing an 'incremental-merge' or 'reoptimized-merge'
#' @param number_of_dimensions The number of dimensions when doing an 'incremental-merge' or 'reoptimized-merge'
#'
#' @details Maps can be merged in a number of ways depending upon the desired result.
#'
#' \subsection{Method 'table'}{
#' As you would expect, this merges the tables of the two maps but does not attempt to create any new optimizations and any
#' existing optimizations are lost.
#' }
#'
#' \subsection{Method 'reoptimized-merge'}{
#' This merges the tables and then does a specified number of fresh optimizations from random
#' starting coordinates, ignoring any pre-existing optimization runs. It's exactly the same as doing a 'table' merge
#' and running `optimizeMap()` on the merged table.
#' }
#'
#' \subsection{Method 'incremental-merge'}{
#' This takes the currently selected optimization in the first map and then merges in the additional
#' maps in turn. Each time any points not already found in the first map (or the last map in the incremental
#' merge chain) are randomised and everything is relaxed, this is repeated the specified number of times and
#' the process is repeated.
#' }
#'
#' \subsection{Method 'frozen-overlay'}{
#' This fixes the positions of points in each map and tries to best match them simply through re-orientation.
#' Once the best re-orientation is found, points that are in common between the maps are moved to the average
#' position.
#' }
#'
#' \subsection{Method 'relaxed-overlay'}{
#' This is the same as the frozen-overlay but points in the resulting map are then allowed to relax.
#' }
#'
#' \subsection{Method 'frozen-merge'}{
#' In this version, positions of all points in the first map are fixed and remain fixed, so the original map
#' does not change. The second map is then realigned to the first as closely as possible and then all the new
#' points appearing in the second map are allowed to relax into their new positions. This is a way to merge in
#' new antigens and sera into a map without affecting the first one at all (and was first implemented in lisp).
#' }
#'
#' @return Returns the merged map object
#'
#' @family merging_maps
#' @export
mergeMaps <- function(...,
                      method                  = "table",
                      passage_matching        = "auto",
                      minimum_column_basis    = "none",
                      number_of_optimizations = 100,
                      number_of_dimensions){

  # Check that optimizations isn't specified with one of the other methods
  if(!missing(number_of_optimizations) && !method %in% c("incremental-merge", "reoptimized-merge")){
    stop("Number of optimizations is only relevant for the merging method 'incremental-merge' or 'reoptimized-merge'.")
  }

  # Create a list of maps
  maps <- list(...)
  lapply(maps, function(map){
    if(!"rac" %in% class(map)){
      stop("Only acmap objects should be supplied as additional arguments to the mergeMaps function")
    }
  })

  # Keep a record of the main map class
  map1_class <- class(maps[[1]])

  # Clone the maps
  maps <- lapply(maps, cloneMap)

  # Keep only the required optimizations
  if(method %in% c("table", "reoptimized-merge")) {
    maps <- lapply(maps, removeOptimizations)
  } else if(method == "incremental-merge") {
    maps[[1]]            <- keepSingleOptimization(maps[[1]])
    maps[2:length(maps)] <- lapply(maps[2:length(maps)], removeOptimizations)
  } else {
    maps <- lapply(maps, function(map){
      if(numOptimizations(map) > 1) keepSingleOptimization(map)
      else                          map
    })
  }

  # Convert the maps to cpp
  maps <- lapply(maps, as.cpp)

  # Merge the charts
  merged_chart <- maps[[1]]$chart

  if(method == "table"){

    # Table merging
    for(x in 2:length(maps)){
      merged_chart <- acmacs.r::acmacs.merge(
        chart1 = merged_chart,
        chart2 = maps[[x]]$chart,
        match  = passage_matching,
        merge  = 1
      )
    }

  } else if(method == "reoptimized-merge"){

    # Reoptimized merging
    for(x in 2:length(maps)){
      merged_chart <- acmacs.r::acmacs.merge(
        chart1 = merged_chart,
        chart2 = maps[[x]]$chart,
        match  = passage_matching,
        merge  = 1
      )
    }

    merged_chart$relax_many(
      minimum_column_basis,
      number_of_dimensions,
      number_of_optimizations,
      FALSE
    )

  } else if(method == "incremental-merge"){

    # Incremental merging
    for(x in 2:length(maps)){
      merged_chart <- acmacs.r::acmacs.merge(
        chart1 = merged_chart,
        chart2 = maps[[x]]$chart,
        match  = passage_matching,
        merge  = 2
      )
      merged_chart$relax_incremetal(number_of_optimizations, FALSE)
    }

  } else if(method == "frozen-overlay"
            || method == "relaxed-overlay"){

    # Frozen overlay
    if(length(maps) > 2){
      stop("A maximum of 2 maps can be merged with the frozen-overlay method at a time")
    }

    for(x in 2:length(maps)){
      if(numOptimizations(maps[[x]]) == 0){
        stop("Cannot perform a overlay merge because the second map does not have any optimizations")
      }
      merged_chart <- acmacs.r::acmacs.merge(
        chart1 = merged_chart,
        chart2 = maps[[x]]$chart,
        match  = passage_matching,
        merge  = 3
      )
    }

    # Frozen overlay with relaxation
    if(method == "relaxed-overlay"){
      merged_chart$projections[[1]]$relax()
    }

  } else if(method == "frozen-merge"){

    # Frozen merge
    if(length(maps) > 2){
      stop("A maximum of 2 maps can be merged with the frozen-merge method at a time")
    }

    for(x in 2:length(maps)){
      # if(maps[[x]]$chart$number_of_projections  == 0){
      #   maps[[x]]$chart$relax_many(
      #     merged_chart$projections[[1]]$minimum_column_basis,
      #     merged_chart$projections[[1]]$number_of_dimensions,
      #     number_of_optimizations,
      #     FALSE
      #   )
      # }
      merged_chart <- acmacs.r::acmacs.merge(
        chart1 = merged_chart,
        chart2 = maps[[x]]$chart,
        match  = passage_matching,
        merge  = 5
      )
    }

  } else {

    stop("'merge' must be one of 'table', 'reoptimized-merge', 'incremental-merge', 'frozen-overlay', 'relaxed-overlay', 'frozen-merge'.")

  }

  # Return a new map
  merged_map <- racchart.new(chart = merged_chart)
  if(method != "table")      selectedOptimization(merged_map) <- 1
  if("racmap" %in% map1_class) merged_map <- as.list(merged_map)
  merged_map

}


#' Return a merge report
#'
#' Prints a raw text merge report from merging two map tables.
#'
#' @family merging_maps
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
