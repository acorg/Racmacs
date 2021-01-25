
#' Calculate stress blobs data for an antigenic map
#'
#' This function is to help give an idea of how well coordinated each point is
#' in a map, and to give some idea of uncertainty in it's position. It works
#' by moving each point in a grid search and seeing how the total map stress
#' changes, see details.
#'
#' @param map The acmap data object
#' @param stress_lim The blob stress limit
#' @param grid_spacing Grid spacing to use when searching map space and
#'   inferring the blob
#' @param antigens Should stress blobs be calculated for antigens
#' @param sera Should stress blobs be calculated for sera
#' @param .check_relaxation Should a check be performed that the map is fully
#'   relaxed (all points in a local optima) before the search is performed
#' @param .options List of named optimizer options to use when checking map
#'   relaxation, see `RacOptimizer.options()`
#'
#' @return Returns the acmap data object with stress blob information added,
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
#' @export
#'
stressBlobs <- function(
  map,
  stress_lim        = 1,
  grid_spacing      = 0.25,
  antigens          = TRUE,
  sera              = TRUE,
  .check_relaxation = TRUE,
  .options          = list()
  ) {

  # Only run on current optimization
  optimization_number <- 1

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
    map$antigens <- lapply(
      seq_along(map$antigens), function(agnum) {

      blobgrid <- ac_stress_blob_grid(
        testcoords = agBaseCoords(map)[agnum, ],
        coords     = srBaseCoords(map),
        tabledists = tableDistances(map)[agnum, ],
        titertypes = titertypesTable(map)[agnum, ],
        stress_lim = stress_lim,
        grid_spacing = grid_spacing
      )

      antigen <- map$antigens[[agnum]]
      antigen$stress_blob <- contour_blob(
        grid_values = blobgrid$grid,
        grid_points = blobgrid$coords,
        value_lim   = blobgrid$stress_lim
      )
      antigen

    })
  }

  # Calculate blob data for sera
  if (sera) {
    map$sera <- lapply(
      seq_along(map$sera), function(srnum) {

      blobgrid <- ac_stress_blob_grid(
        testcoords = srBaseCoords(map)[srnum, ],
        coords     = agBaseCoords(map),
        tabledists = tableDistances(map)[, srnum],
        titertypes = titertypesTable(map)[, srnum],
        stress_lim = stress_lim,
        grid_spacing = grid_spacing
      )

      serum <- map$sera[[srnum]]
      serum$stress_blob <- contour_blob(
        grid_values = blobgrid$grid,
        grid_points = blobgrid$coords,
        value_lim   = blobgrid$stress_lim
      )
      serum

    })
  }

  # Return the map with blob data
  map

}

# Functions for fetching blob information
agStressBlobs <- function(map) {
  lapply(map$antigens, function(ag) ag$stress_blob)
}
srStressBlobs <- function(map) {
  lapply(map$sera, function(sr) sr$stress_blob)
}
ptStressBlobs <- function(map) {
  c(agStressBlobs(map), srStressBlobs(map))
}

#' Fit a contour blob
#' @noRd
contour_blob <- function(
  grid_values,
  grid_points,
  value_lim
  ) {

  if (dim(grid_values)[3] == 1) {

    ## 2D
    ndims <- 2
    blob <- grDevices::contourLines(
      x = grid_points[[1]],
      y = grid_points[[2]],
      z = grid_values[, , 1],
      levels = value_lim
    )

  } else {

    ## 3D
    ndims <- 3
    # contour_fit <- contourShape(
    #   vol    = grid_values,
    #   maxvol = max(grid_values[!is.nan(grid_values) & grid_values != Inf]),
    #   x      = grid_points[[1]],
    #   y      = grid_points[[2]],
    #   z      = grid_points[[3]],
    #   level  = value_lim
    # )
    #
    # blob <- list(
    #   vertices = contour_fit,
    #   faces    = matrix(seq_len(nrow(contour_fit)), ncol = 3, byrow = TRUE)
    # )

    contour_fit <- rmarchingcubes::contour3d(
      griddata = grid_values,
      level  = value_lim,
      x      = grid_points[[1]],
      y      = grid_points[[2]],
      z      = grid_points[[3]]
    )

    blob <- list(
      vertices = contour_fit$vertices,
      faces    = contour_fit$triangles,
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

# Function to convert to the RacViewer stress blob data
viewer_stressblobdata <- function(map) {
  list(
    antigens = lapply(map$antigens, function(ag) ag$stress_blob),
    sera = lapply(map$sera, function(sr) sr$stress_blob)
  )
}

#' Fetch information on stress blob size
#'
#' Returns a vector of stress blob sizes for each point, helpful for
#' programatically finding the points with the most uncertainty.
#'
#' @param map acmap with stress blob information added
#'
#' @name ptStressBlobSize
#'

#' @rdname ptStressBlobSize
#' @export
agStressBlobSize <- function(map) {
  check.acmap(map)
  vapply(map$antigens, function(ag) {
    calcBlobSize(ag$stress_blob)
  }, numeric(1))
}

#' @rdname ptStressBlobSize
#' @export
srStressBlobSize <- function(map) {
  check.acmap(map)
  vapply(map$sera, function(sr) {
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


contourShape <- function(
  vol,
  maxvol,
  x,
  y,
  z,
  level
) {

  misc3d::computeContour3d(
    vol    = vol,
    maxvol = maxvol,
    x      = x,
    y      = y,
    z      = z,
    level  = level
  )

}
