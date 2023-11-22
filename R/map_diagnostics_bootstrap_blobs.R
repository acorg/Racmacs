
#' Calculate bootstrap blob data for an antigenic map
#'
#' This function takes a map for which the function `bootstrapMap()` has already
#' been applied and draws contour blobs for each point illustrating how point
#' position varies in each bootstrap repeat. The blobs are calculated using
#' kernal density estimates according to these point distribution and drawn
#' so as to encompass a given proportion of this variation according to the
#' parameter `conf.level`. A `conf.level` set at 0.95 for example will draw
#' blobs that are calculated to encompass 95% of the positional variation seen
#' in the bootstrap repeats. Note however that the accuracy of these estimates
#' will depend on the number of bootstrap repeats performed, for example whether
#' 100 or 1000 repeats were performed in the initial calculations using
#' `bootstrapMap()`.
#'
#' @param map The acmap data object
#' @param conf.level The proportion of positional variation captured by each blob
#' @param smoothing The amount of smoothing to perform when performing the
#'   kernel density estimate, larger equates to more smoothing
#' @param gridspacing grid spacing to use when calculating blobs, smaller values
#'   will produce more accurate blobs with smoother edges but will take longer
#'   to calculate.
#' @param antigens Should blobs be calculated for antigens
#' @param sera Should blobs be calculated for sera
#' @param method One of "MASS", the default, or "ks", specifying the algorithm to
#'   use when calculating blobs in 2D. 3D will always use ks::kde.
#'
#' @returns Returns an acmap object that will then show the corresponding bootstrap
#'   blobs when viewed or plotted.
#'
#' @family map diagnostic functions
#' @export
#'
bootstrapBlobs <- function(
  map,
  conf.level = 0.68,
  smoothing = 6,
  gridspacing = 0.25,
  antigens = TRUE,
  sera = TRUE,
  method = "ks"
) {

  # Check the map has bootstrap data
  if (!hasBootstrapData(map, 1)) {
    stop("First run bootstrap repeats on this map object using the bootstrapMap() function", call. = FALSE)
  }

  # Set antigens and sera
  antigens <- get_ag_indices(antigens, map)
  sera <- get_sr_indices(sera, map)

  # Get coordinates
  bootstrap_ag_coords <- mapBootstrap_agBaseCoords(map)
  bootstrap_sr_coords <- mapBootstrap_srBaseCoords(map)

  # Set progress bar
  message("Calculating bootstrap blobs")
  pb <- ac_progress_bar(length(c(antigens, sera)))

  # Calculate for antigens
  for (agnum in antigens) {

    # Fetch coords, removing nas found in the resample method
    coords <- t(sapply(bootstrap_ag_coords, function(x) x[agnum, ]))
    coords <- coords[!is.na(coords[,1]), , drop=F]

    agDiagnostics(map, 1)[[agnum]]$bootstrap_blob <- coordDensityBlob(
      coords = coords,
      conf.level = conf.level,
      smoothing = smoothing,
      gridspacing = gridspacing,
      method = method
    )
    ac_update_progress(pb, agnum)

  }

  # Calculate for sera
  for (srnum in sera) {

    # Fetch coords, removing nas found in the resample method
    coords <- t(sapply(bootstrap_sr_coords, function(x) x[srnum, ]))
    coords <- coords[!is.na(coords[,1]), , drop=F]

    srDiagnostics(map, 1)[[srnum]]$bootstrap_blob <- coordDensityBlob(
      coords = coords,
      conf.level = conf.level,
      smoothing = smoothing,
      gridspacing = gridspacing
    )
    ac_update_progress(pb, srnum + numAntigens(map))

  }

  # Return the updated map
  map

}





