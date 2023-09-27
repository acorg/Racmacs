
#' Calculate triangulation blobs data for an antigenic map
#'
#' This function is to help give an idea of how well coordinated each point is
#' in a map, and to give some idea of uncertainty in it's position. It works
#' by moving each point in a grid search and seeing how the total map stress
#' changes, see details.
#'
#' @param map The acmap data object
#' @param optimization_number The optimization number to check
#' @param stress_lim The blob stress limit
#' @param grid_spacing Grid spacing to use when searching map space and
#'   inferring the blob
#' @param antigens Should triangulation blobs be calculated for antigens
#' @param sera Should triangulation blobs be calculated for sera
#' @param .check_relaxation Should a check be performed that the map is fully
#'   relaxed (all points in a local optima) before the search is performed
#' @param .options List of named optimizer options to use when checking map
#'   relaxation, see `RacOptimizer.options()`
#'
#' @returns Returns the acmap data object with triangulation blob information added,
#'   which will be shown when the map is plotted
#'
#' @details The region or regions of the plot where total map stress is not
#'   increased above a certain threshold (`stress_lim`) are shown when the map
#'   is plotted. This function is really to check whether point positions are
#'   clearly very uncertain, for example the underlying titers may support an
#'   antigen being a certain distance away from a group of other points but due
#'   to the positions of the sera against which it was titrated the direction
#'   would be unclear, and you might see a blob that forms an arc or "banana"
#'   that represents this. Note that it is not really a confidence interval
#'   since a point may be well coordinated in terms of the optimization but
#'   it's position may still be defined by perhaps only one particular titer
#'   which is itself uncertain. For something more akin to confidence intervals
#'   you can use other diagnostic functions like `bootstrapMap()`.
#'
#' @family map diagnostic functions
#' @export
#'
triangulationBlobs <- function(
  map,
  optimization_number = 1,
  stress_lim          = 1,
  grid_spacing        = 0.25,
  antigens            = TRUE,
  sera                = TRUE,
  .check_relaxation   = TRUE,
  .options            = list()
) {

  # Check dimensions
  if (!mapDimensions(map) %in% c(2, 3)) {
    stop("Stress blobs can only be calculated for maps with 2 or 3 dimensions")
  }

  # Check map has been fully relaxed
  if (.check_relaxation && !mapRelaxed(map, optimization_number)) {
    stop("Map is not fully relaxed, please relax the map first.")
  }

  # Calculate blob data for antigens
  if (antigens) {
    for (agnum in seq_along(map$antigens)) {

      blobgrid <- ac_stress_blob_grid(
        testcoords = agBaseCoords(map, optimization_number)[agnum, ],
        coords     = srBaseCoords(map, optimization_number),
        tabledists = numeric_min_tabledists(
          tabledists = tableDistances(map, optimization_number),
          dilution_stepsize = dilutionStepsize(map)
        )[agnum, ],
        titertypes = titertypesTable(map)[agnum, ],
        stress_lim = stress_lim,
        grid_spacing = grid_spacing,
        dilution_stepsize = dilutionStepsize(map)
      )

      agDiagnostics(
        map,
        optimization_number
      )[[agnum]]$stress_blob <- contour_blob(
        grid_values = blobgrid$grid,
        grid_points = blobgrid$coords,
        value_lim   = blobgrid$stress_lim
      )

    }
  }

  # Calculate blob data for sera
  if (sera) {
    for (srnum in seq_along(map$sera)) {

      blobgrid <- ac_stress_blob_grid(
        testcoords = srBaseCoords(map, optimization_number)[srnum, ],
        coords     = agBaseCoords(map, optimization_number),
        tabledists = numeric_min_tabledists(
          tabledists = tableDistances(map, optimization_number),
          dilution_stepsize = dilutionStepsize(map)
        )[, srnum],
        titertypes = titertypesTable(map)[, srnum],
        stress_lim = stress_lim,
        grid_spacing = grid_spacing,
        dilution_stepsize = dilutionStepsize(map)
      )

      srDiagnostics(
        map,
        optimization_number
      )[[srnum]]$stress_blob <- contour_blob(
        grid_values = blobgrid$grid,
        grid_points = blobgrid$coords,
        value_lim   = blobgrid$stress_lim
      )

    }
  }

  # Return the map with blob data
  map

}


