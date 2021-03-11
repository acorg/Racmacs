
#' Perform a noisy bootstrap on a map
#'
#' This function takes the map and original titer table, converts the titers to
#' the log scale and reoptimizes the map from scratch. For each bootstrap run
#' this process is performed and a record of the coordinates of points in the
#' lowest stress solution is kept. This can only be performed on a map that
#' has already been optimized, the intention is that you can use this function
#' to see how robust point positions are in that map when additional noise is
#' simulated.
#'
#' @param map The map object
#' @param bootstrap_repeats The number of bootstrap repeats to perform
#' @param optimizations_per_repeat When reoptimizing the map from scratch, the
#'   number of optimization runs to perform
#' @param ag_noise_sd The standard deviation (on the log titer scale) to use
#'   when applying noise per antigen
#' @param titer_noise_sd The standard deviation (on the log titer scale) to use
#'   when applying noise per titer
#' @param options Map optimizer options, see `RacOptimizer.options()`
#'
#' @return Returns the map object updated with bootstrap information
#' @family {map diagnostic functions}
#' @export
#'
bootstrapMap <- function(
  map,
  bootstrap_repeats        = 1000,
  optimizations_per_repeat = 100,
  ag_noise_sd              = 0.7,
  titer_noise_sd           = 0.7,
  options                  = list()
) {

  # Check there are already some map optimizations
  if (numOptimizations(map) == 0) {
    stop(
      "First run some optimizations on this map with 'optimizeMap()'",
      call. = FALSE
    )
  }

  # Set options
  options <- do.call(RacOptimizer.options, options)
  options$report_progress <- FALSE

  # Set progress bar
  message("Running bootstrap repeats")
  pb <- ac_progress_bar(bootstrap_repeats)

  # Run the bootstrap
  map$optimizations[[1]]$bootstrap <- lapply(seq_len(bootstrap_repeats), function(x) {

    # Do a bootstrap run
    bs_result <- ac_noisy_bootstrap_map(
      titer_table = titerTable(map),
      ag_noise_sd = ag_noise_sd,
      titer_noise_sd = titer_noise_sd,
      minimum_column_basis = minColBasis(map),
      fixed_column_bases = fixedColBases(map),
      num_optimizations = optimizations_per_repeat,
      num_dimensions = mapDimensions(map),
      options = options
    )

    # Align to the main map coordinates
    bs_result$coords <- ac_align_coords(
      bs_result$coords,
      ptCoords(map)
    )

    # Update progress
    ac_update_progress(pb, x)

    # Return the result
    bs_result

  })

  # Return the map
  map

}

# Utility function to get bootstrap data
bootstrapData <- function(map, optimization_number) {

  map$optimization[[optimization_number]]$bootstrap

}

# Utility function to check if map has bootstrap data
hasBootstrapData <- function(map, optimization_number) {

  !is.null(bootstrapData(map, optimization_number))

}


#' Get bootstrap coordinates associated with a map
#'
#' This can be used to get information about the bootstrap run results
#' after `boostrapMap()` has been run.
#'
#' @param map The map object
#'
#' @name mapBootstrapCoords
#' @family bootstrapping maps
#'

#' @rdname mapBootstrapCoords
#' @export
mapBootstrap_agCoords <- function(map) {

  # Return the data
  num_antigens <- numAntigens(map)
  lapply(mapBootstrap_ptCoords(map), function(x) {
    x[seq_len(num_antigens), , drop = F]
  })

}

#' @rdname mapBootstrapCoords
#' @export
mapBootstrap_srCoords <- function(map) {

  # Return the data
  num_antigens <- numAntigens(map)
  lapply(mapBootstrap_ptCoords(map), function(x) {
    x[-seq_len(num_antigens), , drop = F]
  })

}

# Underlying function to get bootstrap coordinates
mapBootstrap_ptCoords <- function(map) {

  # Get bootstrap data
  bootstrap <- map$optimizations[[1]]$bootstrap
  if (is.null(bootstrap)) stop(strwrap(
    "There are no bootstrap repeats associated with this map,
    create some first using 'bootstrapMap()'"
  ))

  # Apply the map transformation to the bootstrap coordinates
  lapply(bootstrap, function(result) {
    applyMapTransform(
      coords = result$coords,
      map = map
    )
  })

}


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
#' `boostrapMap()`.
#'
#' @param map The acmap data object
#' @param conf.level The proportion of positional variation captured by each blob
#' @param smoothing The amount of smoothing to perform when performing the
#'   kernel density estimate, larger equates to more smoothing
#'
#' @return Returns an acmap object that will then show the corresponding bootstrap
#'   blobs when viewed or plotted.
#'
bootstrapBlobs <- function(
  map,
  conf.level = 0.68,
  smoothing = 6
  ) {

  # Get coordinates
  bootstrap_ag_coords <- mapBootstrap_agCoords(map)
  bootstrap_sr_coords <- mapBootstrap_srCoords(map)

  # Set progress bar
  message("Calculating bootstrap blobs")
  pb <- ac_progress_bar(numPoints(map))

  # Calculate for antigens
  for (agnum in seq_along(map$antigens)) {

    agDiagnostics(map, 1)[[agnum]]$bootstrap_blob <- coordDensityBlob(
      coords = t(sapply(bootstrap_ag_coords, function(x) x[agnum, ])),
      conf.level = conf.level,
      smoothing = smoothing
    )
    ac_update_progress(pb, agnum)

  }

  # Calculate for sera
  for (srnum in seq_along(map$sera)) {

    srDiagnostics(map, 1)[[srnum]]$bootstrap_blob <- coordDensityBlob(
      coords = t(sapply(bootstrap_sr_coords, function(x) x[srnum, ])),
      conf.level = conf.level,
      smoothing = smoothing
    )
    ac_update_progress(pb, srnum + numAntigens(map))

  }

  # Return the updated map
  map

}


# Functions for fetching bootstrap blob information
agBootstrapBlobs <- function(map, optimization_number = 1) {
  lapply(agDiagnostics(map, optimization_number), function(ag) ag$bootstrap_blob)
}
srBootstrapBlobs <- function(map, optimization_number = 1) {
  lapply(srDiagnostics(map, optimization_number), function(sr) sr$bootstrap_blob)
}
ptBootstrapBlobs <- function(map, optimization_number = 1) {
  c(agBootstrapBlobs(map, optimization_number), srBootstrapBlobs(map, optimization_number))
}
hasBootstrapBlobs <- function(map, optimization_number = 1) {
  sum(vapply(ptBootstrapBlobs(map, optimization_number), function(x) length(x) > 0, logical(1))) > 0
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
#'
#' @noRd
#'
coordDensityBlob <- function(
  coords,
  conf.level = 0.68,
  smoothing = 1
  ) {

  # Check dimensions
  ndims <- ncol(coords)
  if (ndims != 2 && ndims != 3) {
    stop("Bootstrap blobs are only supported for 2 or 3 dimensions")
  }

  # Check confidence level
  if (conf.level != round(conf.level, 2)) {
    stop("conf.level must be to the nearest percent")
  }

  # Perform a kernal density fit
  kd_fit <- ks::kde(
    coords,
    gridsize = apply(coords, 2, function(x) ceiling(diff(range(x)) / 0.25)),
    H = ks::Hpi(x = coords, nstage = 2, deriv.order = 0) * smoothing
  )

  # Calculate the contour blob
  # We have to negate things here so that 3d contours are calculated appropriately
  contour_blob(
    grid_values = -kd_fit$estimate,
    grid_points = kd_fit$eval.points,
    value_lim   = -ks::contourLevels(kd_fit, prob = 1 - conf.level)
  )

}
