
#' Optimize an acmap
#'
#' Take an acmap object with a table of titer data and perform optimization runs
#' to try and find the best arrangement of antigens and sera to represent their
#' antigenic similarity. Optimizations generated from each run with different random
#' starting conditions will be added to the acmap object.
#'
#' @param map The acmap data object
#' @param number_of_dimensions The number of dimensions for the new map
#' @param number_of_optimizations The number of optimization runs to perform
#' @param minimum_column_basis The minimum column basis to use (see details)
#' @param move_trapped_points Should trapped points be searched for and removed, one of 'none', 'best' or 'all' (see details)
#' @param discard_previous_optimizations Should previous optimizations associated with this map be discarded?
#' @param sort_optimizations Should optimizations be sorted by stress afterwards?
#' @param realign_optimizations Should optimizations be realigned to align as closely as possible with each other?
#' @param verbose Should progress be reported?
#'
#' @details This is the core function to run map optimizations. In essence, for each optimization run, points are randomly distributed in
#' 5-dimensional space, the L-BFGS gradient-based optimization algorithm is applied to move points into an optimal position and then
#' principal component analysis is used to reduce the number of dimensions and the process repeated until the desired number of dimensions is
#' reached. Depending on the map, this may not be a trivial optimization process and results will depend upon the starting conditions.
#'
#' \subsection{Trapped points}{
#' Each optimization run can be checked for trapped points which involves taking each point in turn and testing it in different alternative
#' locations in the map. If a more optimal position is found, the point is moved and the process repeated.
#'
#' Although effective this is computationally quite expensive and so the default setting is to apply this only the 'best' (lowest stress) map.
#' This step can alternatively be skipped by setting 'none' or applied to all optimization runs by specifying 'all'.
#' }
#'
#' \subsection{Minimum column basis}{
#' }
#'
#' @return Returns the acmap object updated with new optimizations.
#'
#' @seealso See \code{\link{relaxMap}} for optimizing a given optimization starting from its current coordinates.
#'
#' @export
#'
optimizeMap <- function(map,
                        number_of_dimensions,
                        number_of_optimizations,
                        minimum_column_basis,
                        move_trapped_points = NULL,
                        discard_previous_optimizations = TRUE,
                        sort_optimizations = TRUE,
                        realign_optimizations = TRUE,
                        verbose         = TRUE,
                        use_random_seed = FALSE) {

  # Set default for moving trapped points
  if(is.null(move_trapped_points)){
    if(number_of_dimensions <= 2){
      move_trapped_points <- "best"
    } else {
      move_trapped_points <- "none"
    }
  }

  # Discard previous optimizations
  if(discard_previous_optimizations){
    if(numOptimizations(map) > 0) vmessage(verbose, "Discarding previous optimization runs.")
    map <- removeOptimizations(map)
  }

  # Record new optimization numbers
  new_optimizations  <- numOptimizations(map) + seq_len(number_of_optimizations)

  vmessage(verbose, "Performing ", number_of_optimizations, " optimization runs...", appendLF = F)
  map <- runOptimization(map,
                         number_of_dimensions,
                         number_of_optimizations,
                         minimum_column_basis,
                         use_random_seed)
  vmessage(verbose, "done.")

  # Set selected optimization to 1
  if(!is.null(selectedOptimization(map)) && selectedOptimization(map) != 1){
    warning("Selected optimization reset to 1")
  }
  selectedOptimization(map) <- 1

  # Record new optimization stresses
  new_optimization_stresses <- allMapStresses(map)[new_optimizations]

  if(move_trapped_points == "all"){
    # If trapped points must be hunted for in all optimizations
    vmessage(verbose, "Moving trapped points in each optimization...", appendLF = F)
    for(optimization_num in new_optimizations) {
      map <- moveTrappedPoints(map,
                               optimization_number = optimization_num)
    }
    vmessage(verbose, "done.")
  }

  if(move_trapped_points == "best"){
    # If trapped points must be hunted for in the best optimization
    vmessage(verbose, "Moving trapped points in the lowest stress optimization...", appendLF = F)
    best_optimization <- new_optimizations[which.min(new_optimization_stresses)]
    map <- moveTrappedPoints(map,
                             optimization_number = best_optimization)
    vmessage(verbose, "done.")
  }


  # Sort optimizations
  if(sort_optimizations) {
    vmessage(verbose, "Sorting optimizations by stress...", appendLF = F)
    map <- sortOptimizations(map)
    vmessage(verbose, "done.")
  }

  # Realign optimizations
  if(realign_optimizations) {
    vmessage(verbose, "Realigning optimizations...", appendLF = F)
    map <- realignOptimizations(map)
    vmessage(verbose, "done.")
  }

  # Return the optimised map
  map

}


# Run a map optimization
runOptimization <- function(map,
                            number_of_dimensions,
                            number_of_optimizations,
                            minimum_column_basis,
                            use_random_seed = FALSE) {
  UseMethod("runOptimization", map)
}



#' Relax a map
#'
#' Optimize antigen and serum positions starting from their current coordinates
#' in the selected or specified optimization.
#'
#' @param map The acmap object
#' @param optimization_number The optimization to relax (defaults to the currently selected optimization)
#'
#' @return Returns an acmap object with the newly relaxed point coordinates.
#'
#' @seealso See \code{\link{optimizeMap}} for performing new optimization runs from random starting coordinates.
#'
#' @export
#'
relaxMap <- function(map,
                     optimization_number = NULL) {
  UseMethod("relaxMap")
}

#' Relax a map one step in the optimiser
#'
#' @param map The acmap data object
#' @param optimization_number The map optimization number (defaults to the currently selected optimization)
#'
#' @return Returns an updated map object
#'
#' @export
#'
relaxMapOneStep <- function(map,
                            optimization_number = NULL) {
  UseMethod("relaxMapOneStep")
}

#' Randomize map coordinates
#'
#' Moves map coordinates back into random starting conditions, as performed
#' before each optimization run.
#'
#' @param map The acmap data object
#' @param optimization_number The map optimization number (defaults to the currently selected optimization)
#'
#' @return Returns an updated map object
#'
#' @export
#'
randomizeCoords <- function(map,
                            optimization_number = NULL) {
  UseMethod("randomizeCoords")
}


#' Check if a map has been fully relaxed
#'
#' @param map The acmap data object
#' @param optimization_number The map optimization number (defaults to the currently selected optimization)
#'
#' @return Returns TRUE or FALSE
#' @export
#'
mapRelaxed <- function(map,
                       optimization_number = NULL){

  # Clone the map to avoid affecting main map object
  map            <- cloneMap(map)

  # Check stress
  stress         <- mapStress(map, optimization_number)

  # Relax map
  relaxed_map    <- relaxMap(map, optimization_number)
  relaxed_stress <- mapStress(relaxed_map, optimization_number)

  # Compare stress
  isTRUE(all.equal(relaxed_stress, stress))

}



#' Check for hemisphering or trapped points
#'
#' @param map The acmap data object
#' @param optimization_number The map optimization number (defaults to the currently selected optimization)
#'
#' @return Returns a data frame with information on any points that were found
#'   to be hemisphering or trapped.
#' @export
#'
checkHemisphering <- function(map, optimization_number = NULL){
  UseMethod("checkHemisphering")
}


#' Remove trapped points
#'
#' Iteratively searches for and moves points that are found to be trapped in a
#' optimization, stopping when no more trapped points are found.
#'
#' @param map The acmap data object
#' @param optimization_number The map optimization number (defaults to the currently selected optimization)
#'
#' @return Returns the acmap object with updated coordinates
#' @export
#'
moveTrappedPoints <- function(map, optimization_number = NULL){
  UseMethod("moveTrappedPoints")
}


#' Add data on hemisphering diagnostics to a map
#'
#' @param map The acmap data object
#' @param optimization_number The map optimization number (defaults to the currently selected optimization)
#'
#' @return Returns the map data with additional diagnostic information on hemisphering points included.
#' @export
#'
add_hemispheringData <- function(map, data = NULL, optimization_number = NULL){

  # Process optimization
  optimization_number <- convertOptimizationNum(optimization_number, map)

  # Calculate blob data
  if(is.null(data)){
    data <- checkHemisphering(map = map,
                              optimization = optimization_number)
  }

  # Keep a record
  if(length(map$diagnostics) < optimization_number) {
    map$diagnostics[[optimization_number]] <- list()
  }
  map$diagnostics[[optimization_number]]$hemisphering <- data

  # Return the update map
  map

}


