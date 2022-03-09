
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
#' @return Returns the acmap data object with triangulation blob information added,
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
#' @family {map diagnostic functions}
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
        tabledists = numeric_min_tabledists(tableDistances(map, optimization_number))[agnum, ],
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
        tabledists = numeric_min_tabledists(tableDistances(map, optimization_number))[, srnum],
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

# Functions for fetching blob information
agTriangulationBlobs <- function(map, optimization_number = 1) {
  lapply(agDiagnostics(map, optimization_number), function(ag) ag$stress_blob)
}
srTriangulationBlobs <- function(map, optimization_number = 1) {
  lapply(srDiagnostics(map, optimization_number), function(sr) sr$stress_blob)
}
ptTriangulationBlobs <- function(map, optimization_number = 1) {
  c(agTriangulationBlobs(map, optimization_number), srTriangulationBlobs(map, optimization_number))
}
hasTriangulationBlobs <- function(map, optimization_number = 1) {
  sum(vapply(ptTriangulationBlobs(map, optimization_number), function(x) length(x) > 0, logical(1))) > 0
}

#' Fit a contour blob
#' @noRd
contour_blob <- function(
  grid_values,
  grid_points,
  value_lim
  ) {

  # Collapse 3d arrays into 2d if 3rd dimension is length 1
  if (length(dim(grid_values)) == 3 && dim(grid_values)[3] == 1) {
    grid_values <- grid_values[, , 1]
  }

  if (length(dim(grid_values)) == 2) {

    ## 2D
    ndims <- 2
    blob <- grDevices::contourLines(
      x = grid_points[[1]],
      y = grid_points[[2]],
      z = grid_values,
      levels = value_lim
    )

  } else {

    ## 3D
    ndims <- 3
    contour_fit <- rmarchingcubes::contour3d(
      griddata = grid_values,
      level  = value_lim,
      x      = grid_points[[1]],
      y      = grid_points[[2]],
      z      = grid_points[[3]]
    )

    blob <- list(
      vertices = contour_fit$vertices,
      faces    = contour_fit$triangles - 1,
      normals  = contour_fit$normals
    )

  }

  ## Blob volumes
  gridsize    <- abs(diff(grid_points[[1]][1:2]))
  attr(blob, "volume") <- sum(grid_values <= value_lim) * gridsize ^ ndims
  attr(blob, "dims") <- ndims

  # Return the blob
  blob

}


#' Fetch information on triangulation blob size
#'
#' Returns a vector of triangulation blob sizes for each point, helpful for
#' programatically finding the points with the most uncertainty.
#'
#' @param map acmap with triangulation blob information added
#' @param optimization_number optimization number for which to calculate blob size
#'
#' @name ptTriangulationBlobsize
#' @family {map diagnostic functions}
#'

#' @rdname ptTriangulationBlobsize
#' @export
agTriangulationBlobSize <- function(map, optimization_number = 1) {
  check.acmap(map)
  check.optnum(map, optimization_number)
  vapply(agDiagnostics(map, optimization_number), function(ag) {
    calcBlobSize(ag$stress_blob)
  }, numeric(1))
}

#' @rdname ptTriangulationBlobsize
#' @export
srTriangulationBlobSize <- function(map, optimization_number = 1) {
  check.acmap(map)
  check.optnum(map, optimization_number)
  vapply(srDiagnostics(map, optimization_number), function(sr) {
    calcBlobSize(sr$stress_blob)
  }, numeric(1))
}


calcBlobSize <- function(blob) {

  if (is.null(blob)) {
    return(NA)
  }
  if (attr(blob, "dims") == 2) {
    calcBlobArea(blob)
  } else {
    calcBlobVolume(blob)
  }

}

calcBlobArea <- function(blob) {

  # Check geometry package installed
  package_required("geometry")

  sum(
    vapply(blob, function(b) {
      geometry::polyarea(
        x = b$x,
        y = b$y
      )
    }, numeric(1))
  )

}

calcBlobVolume <- function(blob) {

  attr(blob, "volume")

}


# Deprecated functions
deprecated_fn <- function(fn) {
  fn_name <- as.character(match.call())[2]
  function(...) {
    warning(sprintf("This function has been deprecated in favor of %s()", fn_name))
    fn(...)
  }
}


#' Deprecated functions
#'
#' These functions still work but have been deprecated in favour of another function. Arguments will be passed onto the new function with a warning.
#'
#' @param ... Arguments to pass to the new function
#'
#' @name deprecated_fn
#'

#' @rdname deprecated_functions
#' @export
stressBlobs <- deprecated_fn(triangulationBlobs)

#' @rdname deprecated_functions
#' @export
agStressBlobSize <- deprecated_fn(agTriangulationBlobSize)

#' @rdname deprecated_functions
#' @export
srStressBlobSize <- deprecated_fn(srTriangulationBlobSize)

