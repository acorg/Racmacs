
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
#' @returns Returns a map object aligned to the target map
#' @family functions to compare maps
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
#' @param antigens Antigens to include (specified by name or index or TRUE/FALSE
#'   for all/none)
#' @param sera Sera to include (specified by name or index or TRUE/FALSE for
#'   all/none)
#' @param translation Should translation be allowed
#' @param scaling Should scaling be allowed (generally not recommended unless
#'   comparing maps made with different assays)
#' @param keep_optimizations Should all optimization runs be kept or only the
#'   one to which the procrustes was applied.
#'
#' @returns Returns an acmap object with procrustes information added, which will
#'   be shown when the map is plotted. To avoid ambiguity about which
#'   optimization run the procrustes was applied to, only the optimization run
#'   specified by `optimization_number` is kept in the map returned.
#' @family functions to compare maps
#' @export
#'
procrustesMap <- function(
  map,
  comparison_map,
  optimization_number = 1,
  comparison_optimization_number = 1,
  antigens    = TRUE,
  sera        = TRUE,
  translation = TRUE,
  scaling     = FALSE,
  keep_optimizations = FALSE
  ) {

  # Check input
  check.acmap(map)
  check.acmap(comparison_map)
  check.logical(translation)
  check.logical(scaling)
  check.optnum(map, optimization_number)
  check.optnum(comparison_map, comparison_optimization_number)

  # Keep only the optimization number specified
  if (!keep_optimizations) {
    map <- keepSingleOptimization(map, optimization_number)
    optimization_number <- 1
  }

  # Check for duplicate names
  if (sum(duplicated(agMatchIDs(map))) > 0 || sum(duplicated(agMatchIDs(comparison_map))) > 0) stop("Duplicate antigen names/IDs found.", call. = F)
  if (sum(duplicated(srMatchIDs(map))) > 0 || sum(duplicated(srMatchIDs(comparison_map))) > 0) stop("Duplicate sera names/IDs found.", call. = F)

  # Get selected antigen and sera indices
  antigens_included <- rep(FALSE, numAntigens(map))
  sera_included <- rep(FALSE, numSera(map))
  antigens_included[get_ag_indices(antigens, map)] <- TRUE
  sera_included[get_sr_indices(sera, map)] <- TRUE

  # Throw error if no points match
  num_antigens_matching <- sum(agMatchIDs(map)[antigens_included] %in% agMatchIDs(comparison_map))
  num_sera_matching <- sum(srMatchIDs(map)[sera_included] %in% srMatchIDs(comparison_map))
  num_points_matching <- num_antigens_matching + num_sera_matching

  if (num_points_matching < mapDimensions(map) + 1) {
    stop(sprintf("Not enough matching points (%s)", num_points_matching), call. = FALSE)
  }

  # Set unselected point coords to NaN
  pc_map <- map
  agBaseCoords(pc_map)[!antigens_included, ] <- NaN
  srBaseCoords(pc_map)[!sera_included, ] <- NaN

  # Get the procrustes coords
  pc_coords <- ac_procrustes_map_coords(
    base_map = pc_map,
    procrustes_map = comparison_map,
    base_map_optimization_number = optimization_number - 1,
    procrustes_map_optimization_number = comparison_optimization_number - 1,
    translation = translation,
    scaling = scaling
  )

  # Add the data to the map
  map$optimizations[[optimization_number]]$procrustes <- pc_coords
  map$optimizations[[optimization_number]]$procrustes$ag_coords[!antigens_included, ] <- NaN
  map$optimizations[[optimization_number]]$procrustes$sr_coords[!sera_included, ] <- NaN
  map$optimizations[[optimization_number]]$procrustes$dim <- mapDimensions(comparison_map, comparison_optimization_number)

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
#' @param antigens Antigens to include (specified by name or index or TRUE/FALSE
#'   for all/none)
#' @param sera Sera to include (specified by name or index or TRUE/FALSE for
#'   all/none)
#' @param translation Should translation be allowed
#' @param scaling Should scaling be allowed (generally not recommended unless
#'   comparing maps made with different assays)
#'
#' @returns Returns a list with information on antigenic distances between the
#'   aligned maps, and the rmsd of the point differences split by antigen
#'   points, serum points and total, or all points. The distances are a vector
#'   matching the number of points in the main map, with NA in the position of
#'   any points not found in the comparison map.
#'
#' @family functions to compare maps
#' @export
procrustesData <- function(
  map,
  comparison_map,
  optimization_number = 1,
  comparison_optimization_number = 1,
  antigens    = TRUE,
  sera        = TRUE,
  translation = TRUE,
  scaling     = FALSE
  ) {

  # Perform the procrustes
  map <- procrustesMap(
    map = map,
    comparison_map = comparison_map,
    optimization_number = optimization_number,
    comparison_optimization_number = comparison_optimization_number,
    antigens    = antigens,
    sera        = sera,
    translation = translation,
    scaling = scaling
  )

  # Get the procrustes data
  ac_procrustes_map_data(
    map$optimizations[[1]],
    map$optimizations[[1]]$procrustes
  )

}

# Functions for fetching procrustes information
ptProcrustes <- function(map, optimization_number = 1) {
  map$optimizations[[optimization_number]]$procrustes
}

hasProcrustes <- function(map, optimization_number = 1) {
  !is.null(ptProcrustes(map, optimization_number))
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
#' @returns Returns the map with realigned optimizations
#' @family functions to compare maps
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

