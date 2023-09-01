
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
    if (length(grid_points[[1]]) == 0 || length(grid_points[[2]]) == 0) {
      blob <- list()
    } else {
      blob <- grDevices::contourLines(
        x = grid_points[[1]],
        y = grid_points[[2]],
        z = grid_values,
        levels = value_lim
      )
    }

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

    blob <- separate_meshes(
      list(
        vertices = contour_fit$vertices,
        faces    = contour_fit$triangles - 1,
        normals  = contour_fit$normals
      )
    )

  }

  ## Blob attributes
  attr(blob, "dims") <- ndims

  # Return the blob
  blob

}


#' Calculate a blob geometry representing bootstrap point position variation
#'
#' This function is used to create "blob" geometries, with the aim to visualise
#' how point positions vary amongst bootstrap repeats. The underlying approach
#' is to fit a kernel density estimate to the coordinates and then draw blobs
#' that capture the requested point density.
#'
#' @param coords matrix of a points coordinates across the bootstrap repeats
#' @param conf.level the confidence level, i.e. proportion of point variation
#'   the blob should capture
#' @param smoothing the amount of smoothing to perform when performing the
#'   kernel density estimate
#' @param gridspacing grid spacing to use when calculating blobs, smaller values
#'   will produce more accurate blobs with smoother edges but will take longer
#'   to calculate, the default is 0.05 for 2d maps and 0.25 for 2d maps
#' @param method One of "MASS", the default, or "ks", specifying the algorithm to
#'   use when calculating blobs in 2D. 3D will always use ks.
#'
#' @noRd
#'
coordDensityBlob <- function(
  coords,
  conf.level = 0.68,
  smoothing = 1,
  gridspacing = NULL,
  method = "ks"
) {

  # Check dimensions
  ndims <- ncol(coords)
  if (ndims != 2 && ndims != 3) {
    stop("Bootstrap blobs are only supported for 2 or 3 dimensions")
  }

  # Set default grid spacing
  if (is.null(gridspacing)) {
    if (ndims == 2) gridspacing <- 0.05
    else            gridspacing <- 0.25
  }

  # Check confidence level
  if (conf.level != round(conf.level, 2)) {
    stop("conf.level must be to the nearest percent")
  }

  # Use a quicker algorithm for 2 dimensions, 3d must use the slower ks::kde method
  if (ndims == 2 && method == "MASS") {

    # Perform a kernel density fit
    kd_fit <- MASS::kde2d(
      x = coords[,1],
      y = coords[,2],
      n = c(
        ceiling(diff(range(coords[,1])) / gridspacing),
        ceiling(diff(range(coords[,2])) / gridspacing)
      ),
      h = apply(coords, 2, MASS::bandwidth.nrd)*smoothing,
      lims = c(
        grDevices::extendrange(coords[,1], f = 1),
        grDevices::extendrange(coords[,2], f = 1)
      )
    )

    # Calculate the contour level for the appropriate confidence level
    fhat <- interp2d(x = coords, gpoints1 = kd_fit$x, gpoints2 = kd_fit$y, f = kd_fit$z)
    contour_level <- stats::quantile(fhat, 1 - conf.level)

    grid_values = -kd_fit$z
    grid_points = list(kd_fit$x, kd_fit$y)
    value_lim   = -contour_level

  } else {

    # Perform a kernel density fit
    kd_fit <- ks::kde(
      coords,
      gridsize = apply(coords, 2, function(x) ceiling(diff(range(x)) / gridspacing)),
      H = ks::Hpi(x = coords, nstage = 2, deriv.order = 0) * smoothing
    )

    # Calculate the contour level for the appropriate confidence level
    contour_level <- ks::contourLevels(kd_fit, prob = 1 - conf.level)

    # Calculate the contour blob
    # We have to negate things here so that 3d contours are calculated appropriately
    grid_values <- -kd_fit$estimate
    grid_points <- kd_fit$eval.points
    value_lim   <- -contour_level

  }

  # Calculate the blob
  contour_blob(
    grid_values = grid_values,
    grid_points = grid_points,
    value_lim   = value_lim
  )

}


transformMapBlob <- function(blob, map, optimization_number) {

  if (is.null(blob)) return(NULL)
  transformed_blob <- lapply(blob, function(b) {

    if (attr(blob, "dim") == 2) {
      coords <- applyMapTransform(
        coords = cbind(b$x, b$y),
        map = map,
        optimization_number = optimization_number
      )
      b$x <- coords[,1]
      b$y <- coords[,2]
      b
    } else {
      b$vertices <- applyMapTransform(
        coords = b$vertices,
        map = map,
        optimization_number = optimization_number
      )
      b$normals <- applyMapTransform(
        coords = b$normals,
        map = map,
        optimization_number = optimization_number
      )
      b
    }

  })

  attributes(transformed_blob) <- attributes(blob)
  transformed_blob

}

#' Calculate size of a blob object
#'
#' Returns either the area (for 2D blobs) or volume (for 3D blobs)
#'
#' @param blob The blob object
#'
#' @returns A numeric vector
#'
#' @family additional plotting functions
#' @export
#'
blobsize <- function(blob) {

  if (attr(blob, "dims") == 3) {
    blob_volume(blob)
  } else {
    blob_area(blob)
  }

}

blob_area <- function(blob) {
  sum(vapply(blob, function(b) polygon_area(b$x, b$y), numeric(1)))
}

blob_volume <- function(blob) {
  sum(vapply(blob, function(b) mesh_volume(b$faces, b$vertices), numeric(1)))
}
