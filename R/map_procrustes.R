
#' Realign map to match another
#'
#' Realigns the coordinates of a map to match a target map as closely as possible.
#'
#' @param map The acmap to realign.
#' @param target_map The acmap to realign to.
#' @param antigens Antigens to include when calculating the closest realignment, specified either by name or index or FALSE for excluding all.
#' @param sera Sera to include when calculating the closest realignment, specified either by name or index or FALSE for excluding all.
#' @param optimization_number The optimization from the map to realign (default is the currently selected one)
#' @param target_optimization_number The optimization from the target map to realign to (default is the currently selected one)
#' @param passage_matching The type of passage matching to be performed.
#' @param alignTargetToMain Should the target map be realigned to match the main map (default is to
#'   realign main map to match target map) - this is sometimes useful if you want to
#'   match based on antigen and serum indices from the main map.
#'
#' @return Returns the map aligned to the target map (or the target map aligned to the main map if alignTargetToMain is TRUE)
#' @family {functions to compare maps}
#' @export
#'
realignMap <- function(
  map,
  target_map,
  translation = TRUE,
  scaling     = FALSE
  ){

  # Check input
  check.acmap(map)
  check.acmap(target_map)

  ac_align_map(
    source_map = map,
    target_map = target_map,
    translation = translation,
    scaling = scaling
  )

}


#' Return procrustes information
#'
#' Returns information from one map procrusted to another.
#'
#' @param map The acmap data object
#' @param comparison_map The acmap data object to procrustes against
#' @param antigens Antigens to include in the procrustes, specified either by name or index or FALSE for excluding all.
#' @param sera Sera to include in the procrustes, specified either by name or index or FALSE for excluding all.
#' @param translation Should translation be performed?
#' @param scaling Should scaling be performed?
#' @param optimization_number The map optimization to use in the procrustes calculation (defaults to the currently selected optimization)
#' @param target_optimization_number The target map optimization to use in the procrustes calculation (defaults to the currently selected optimization)
#' @param passage_matching Should passage matching be performed (not currently implemented)
#'
#' @return Returns procrustes information from the map to the target.
#' @family {functions to compare maps}
#' @export
#'
procrustesMap <- function(
  map,
  comparison_map,
  optimization_number = 1,
  comparison_optimization_number = 1,
  translation = TRUE,
  scaling     = FALSE
  ){

  # Get the procrustes coords
  pc_coords <- ac_procrustes_map_coords(
    base_map = map,
    procrustes_map = comparison_map,
    base_map_optimization_number = optimization_number - 1,
    procrustes_map_optimization_number = comparison_optimization_number - 1,
    translation = translation,
    scaling = scaling
  )

  # Keep only the optimization number used
  map <- keepSingleOptimization(map)

  # Add the data to the map
  map$procrustes <- pc_coords

  # Return the map
  map

}


#' @export
procrustesData <- function(
  map,
  comparison_map,
  optimization_number = 1,
  comparison_optimization_number = 1,
  translation = TRUE,
  scaling     = FALSE
){

  # Perform the procrustes
  map <- procrustesMap(
    map = map,
    comparison_map = comparison_map,
    optimization_number = optimization_number,
    comparison_optimization_number = comparison_optimization_number,
    translation = translation,
    scaling = scaling
  )

  # Get the procrustes data
  ac_procrustes_map_data(
    map$optimizations[[optimization_number]],
    map$optimizations[[optimization_number]]$procrustes
  )

}


#' Realigns optimizations in the map to the current optimization
#'
#' @param map The acmap data
#' @param antigens The antigens to include in the realignment, TRUE for all FALSE for none, or specified by name or index
#' @param sera The sera to include in the realignment, TRUE for all FALSE for none, or specified by name or index
#'
#' @return Returns the map with realigned optimizations
#' @family {functions to compare maps}
#' @export
#'
realignOptimizations <- function(
  map,
  antigens = TRUE,
  sera     = TRUE,
  optimization_number = NULL
  ){

  check.acmap(map)

  # Align optimizations
  map$optimizations <- ac_align_optimizations(map$optimizations)

  # Return the map
  map

}


add_procrustes_grid <- function(map){

  # Get the comparator coordinates
  comp_coords <- rbind(
    map$procrustes$comparison_coords$ag,
    map$procrustes$comparison_coords$sr
  )

  # Calculate grid limits and the grid points
  plims <- plot_lims(comp_coords)
  x <- seq(from = plims$xlim[1], to = plims$xlim[2])
  y <- seq(from = plims$ylim[1], to = plims$ylim[2])
  grid_coords <- as.matrix(expand.grid(x, y))
  grid_coords <- cbind(grid_coords, 0)
  grid_coords <- apply_procrustes(grid_coords, map$procrustes$pc_transform)

  # Add the surface to the map
  r3js::surface3js(
    map,
    x = matrix(grid_coords[,1], length(x), length(y)),
    y = matrix(grid_coords[,2], length(x), length(y)),
    z = matrix(grid_coords[,3], length(x), length(y)),
    wireframe = TRUE,
    col = "#cccccc"
  )

}



#' Realign map to match another
#'
#' Realigns the coordinates of a map to match a target map as closely as possible.
#'
#' @param map The acmap to realign.
#' @param target_map The acmap to realign to.
#' @param antigens Antigens to include when calculating the closest realignment, specified either by name or index or FALSE for excluding all.
#' @param sera Sera to include when calculating the closest realignment, specified either by name or index or FALSE for excluding all.
#' @param optimization_number The optimization from the map to realign (default is the currently selected one)
#' @param target_optimization_number The optimization from the target map to realign to (default is the currently selected one)
#' @param passage_matching The type of passage matching to be performed.
#' @param alignTargetToMain Should the target map be realigned to match the main map (default is to
#'   realign main map to match target map) - this is sometimes useful if you want to
#'   match based on antigen and serum indices from the main map.
#'
#' @return Returns the map aligned to the target map (or the target map aligned to the main map if alignTargetToMain is TRUE)
#' @family {functions to compare maps}
#' @export
#'
realignMap <- function(
  map,
  target_map,
  translation = TRUE,
  scaling     = FALSE
  ){

  # Check input
  check.acmap(map)
  check.acmap(target_map)

  ac_align_map(
    source_map = map,
    target_map = target_map,
    translation = translation,
    scaling = scaling
  )

}


#' Return procrustes information
#'
#' Returns information from one map procrusted to another.
#'
#' @param map The acmap data object
#' @param comparison_map The acmap data object to procrustes against
#' @param antigens Antigens to include in the procrustes, specified either by name or index or FALSE for excluding all.
#' @param sera Sera to include in the procrustes, specified either by name or index or FALSE for excluding all.
#' @param translation Should translation be performed?
#' @param scaling Should scaling be performed?
#' @param optimization_number The map optimization to use in the procrustes calculation (defaults to the currently selected optimization)
#' @param target_optimization_number The target map optimization to use in the procrustes calculation (defaults to the currently selected optimization)
#' @param passage_matching Should passage matching be performed (not currently implemented)
#'
#' @return Returns procrustes information from the map to the target.
#' @family {functions to compare maps}
#' @export
#'
procrustesMap <- function(
  map,
  comparison_map,
  optimization_number = 1,
  comparison_optimization_number = 1,
  translation = TRUE,
  scaling     = FALSE
  ){

  # Get the procrustes coords
  pc_coords <- ac_procrustes_map_coords(
    base_map = map,
    procrustes_map = comparison_map,
    base_map_optimization_number = optimization_number - 1,
    procrustes_map_optimization_number = comparison_optimization_number - 1,
    translation = translation,
    scaling = scaling
  )

  # Keep only the optimization number used
  map <- keepSingleOptimization(map, optimization_number)

  # Add the data to the map
  map$procrustes <- pc_coords

  # Return the map
  map

}


#' Not yet implemented
procrustesData <- function(
  map,
  comparison_map,
  optimization_number = 1,
  comparison_optimization_number = 1,
  translation = TRUE,
  scaling     = FALSE
){

  # Perform the procrustes
  map <- procrustesMap(
    map = map,
    comparison_map = comparison_map,
    optimization_number = optimization_number,
    comparison_optimization_number = comparison_optimization_number,
    translation = translation,
    scaling = scaling
  )

  # Get the procrustes data
  ac_procrustes_map_data(
    map$optimizations[[1]],
    map$procrustes
  )

}


#' Realigns optimizations in the map to the current optimization
#'
#' @param map The acmap data
#' @param antigens The antigens to include in the realignment, TRUE for all FALSE for none, or specified by name or index
#' @param sera The sera to include in the realignment, TRUE for all FALSE for none, or specified by name or index
#'
#' @return Returns the map with realigned optimizations
#' @family {functions to compare maps}
#' @export
#'
realignOptimizations <- function(
  map,
  antigens = TRUE,
  sera     = TRUE,
  optimization_number = NULL
  ){

  check.acmap(map)

  # Align optimizations
  map$optimizations <- ac_align_optimizations(map$optimizations)

  # Return the map
  map

}


add_procrustes_grid <- function(map){

  # Get the comparator coordinates
  comp_coords <- rbind(
    map$procrustes$comparison_coords$ag,
    map$procrustes$comparison_coords$sr
  )

  # Calculate grid limits and the grid points
  plims <- plot_lims(comp_coords)
  x <- seq(from = plims$xlim[1], to = plims$xlim[2])
  y <- seq(from = plims$ylim[1], to = plims$ylim[2])
  grid_coords <- as.matrix(expand.grid(x, y))
  grid_coords <- cbind(grid_coords, 0)
  grid_coords <- apply_procrustes(grid_coords, map$procrustes$pc_transform)

  # Add the surface to the map
  r3js::surface3js(
    map,
    x = matrix(grid_coords[,1], length(x), length(y)),
    y = matrix(grid_coords[,2], length(x), length(y)),
    z = matrix(grid_coords[,3], length(x), length(y)),
    wireframe = TRUE,
    col = "#cccccc"
  )

}


