
#' Realign map to match another
#'
#' Realigns the coordinates of a map to match a target map as closely as
#' possible, based on a
#' [procrustes analysis](https://en.wikipedia.org/wiki/Procrustes_analysis).
#' Note that all optimization runs will be separately aligned to match as
#' closely as possible the first optimization run of the target map.
#'
#' @param map The acmap to realign.
#' @param target_map The acmap to realign to.
#' @param translation Should translation be allowed
#' @param scaling Should scaling be allowed (generally not recommended unless
#'   comparing maps made with different assays)
#'
#' @return Returns the map aligned to the target map
#' @family {functions to compare maps}
#' @export
#'
realignMap <- function(
  map,
  target_map,
  translation = TRUE,
  scaling     = FALSE
  ) {

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
#' @param optimization_number The map optimization to use in the procrustes
#'   calculation (other optimization runs are discarded)
#' @param comparison_optimization_number The optimization run int the comparison
#'   map to compare against
#' @param translation Should translation be allowed
#' @param scaling Should scaling be allowed (generally not recommended unless
#'   comparing maps made with different assays)
#'
#' @return Returns an acmap object with procrustes information added, which will
#'   be shown when the map is plotted. To avoid ambiguity about which
#'   optimization run the procrustes was applied to, only the optimization run
#'   specified by `optimization_number` is kept in the map returned.
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
  ) {

  # Check input
  check.acmap(map)
  check.acmap(comparison_map)
  check.logical(translation)
  check.logical(scaling)
  check.optnum(map, optimization_number)
  check.optnum(comparison_map, comparison_optimization_number)

  # Get the procrustes coords
  pc_coords <- ac_procrustes_map_coords(
    base_map = map,
    procrustes_map = comparison_map,
    base_map_optimization_number = optimization_number - 1,
    procrustes_map_optimization_number = comparison_optimization_number - 1,
    translation = translation,
    scaling = scaling
  )

  # Add the data to the map
  map$optimizations[[optimization_number]]$procrustes <- pc_coords

  # Return the map
  map

}


#' Return procrustes data on a map comparison
#'
#' Returns information about how similar point positions are in two maps,
#' to get an idea of how similar antigenic positions are in for example
#' maps made from two different datasets.
#'
#' @param map The acmap data object
#' @param comparison_map The acmap data object to procrustes against
#' @param optimization_number The map optimization to use in the procrustes
#'   calculation (other optimization runs are discarded)
#' @param comparison_optimization_number The optimization run int the comparison
#'   map to compare against
#' @param translation Should translation be allowed
#' @param scaling Should scaling be allowed (generally not recommended unless
#'   comparing maps made with different assays)
#'
#' @return Returns a list with information on antigenic distances between the
#'   aligned maps, and the rmsd of the point differences split by antigen
#'   points, serum points and total, or all points. The distances are a vector
#'   matching the number of points in the main map, with NA in the position of
#'   any points not found in the comparison map.
#'
#' @export
#'
procrustesData <- function(
  map,
  comparison_map,
  optimization_number = 1,
  comparison_optimization_number = 1,
  translation = TRUE,
  scaling     = FALSE
  ) {

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

# Functions for fetching procrustes information
ptProcrustes <- function(map, optimization_number = 1) {
  map$optimizations[[optimization_number]]$procrustes
}


#' Realigns optimizations in the map
#'
#' Realigns all map optimizations through rotatation and translation to match
#' point positions as closely as possible to the first optimization run. This
#' is done by default when optimizing a map and makes comparing point positions
#' in each optimization run much easier to do by eye.
#'
#' @param map The acmap data object
#'
#' @return Returns the map with realigned optimizations
#' @family {functions to compare maps}
#' @export
#'
realignOptimizations <- function(
  map
  ) {

  check.acmap(map)

  # Align optimizations
  map$optimizations <- ac_align_optimizations(map$optimizations)

  # Return the map
  map

}


# This is a function to add a grid to a map indicating the original 2d plane,
# when comparing a 2d map to a 3d map with procrustes
add_procrustes_grid <- function(map) {

  # # Get the comparator coordinates
  # comp_coords <- rbind(
  #   map$procrustes$comparison_coords$ag,
  #   map$procrustes$comparison_coords$sr
  # )
  #
  # # Calculate grid limits and the grid points
  # plims <- plot_lims(comp_coords)
  # x <- seq(from = plims$xlim[1], to = plims$xlim[2])
  # y <- seq(from = plims$ylim[1], to = plims$ylim[2])
  # grid_coords <- as.matrix(expand.grid(x, y))
  # grid_coords <- cbind(grid_coords, 0)
  # grid_coords <- apply_procrustes(grid_coords, map$procrustes$pc_transform)
  #
  # # Add the surface to the map
  # r3js::surface3js(
  #   map,
  #   x = matrix(grid_coords[,1], length(x), length(y)),
  #   y = matrix(grid_coords[,2], length(x), length(y)),
  #   z = matrix(grid_coords[,3], length(x), length(y)),
  #   wireframe = TRUE,
  #   col = "#cccccc"
  # )
  map

}
