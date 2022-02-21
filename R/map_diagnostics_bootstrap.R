
#' Perform a bootstrap on a map
#'
#' This function takes the map and original titer table, and performs a version
#' of [bootstrapping](https://en.wikipedia.org/wiki/Bootstrapping_(statistics))
#' defined by the method argument. For each bootstrap run
#' this process is performed and a record of the coordinates of points in the
#' lowest stress solution is kept. See details for a description of the bootstrapping
#' methods you can apply.
#'
#' @param map The map object
#' @param method One of "resample", "bayesian" or "noisy" (see details)
#' @param bootstrap_repeats The number of bootstrap repeats to perform
#' @param bootstrap_ags For "resample" and "bayesian" methods, whether to apply bootstrapping across antigens
#' @param bootstrap_sr For "resample" and "bayesian" methods, whether to apply bootstrapping across sera
#' @param reoptimize Should the whole map be reoptimized with each bootstrap run. If FALSE,
#'   the map is simply relaxed from it's current optimization with each run.
#' @param optimizations_per_repeat When re-optimizing the map from scratch, the
#'   number of optimization runs to perform
#' @param ag_noise_sd The standard deviation (on the log titer scale) of measurement noise
#'   applied per antigen when using the "noisy" method
#' @param titer_noise_sd The standard deviation (on the log titer scale) of measurement noise
#'   applied per titer when using the "noisy" method
#' @param options Map optimizer options, see `RacOptimizer.options()`
#'
#' @details ## Bootstrapping methods
#'
#'   __"resample"__:
#'   The [resample boostrap](https://en.wikipedia.org/wiki/Bootstrapping_(statistics)#Case_resampling)
#'   is the most standard bootstrap method, a random resample of the titer table data is
#'   taken _with replacement_. Depending on your specification, resampling is applied across
#'   either individual antigens, individual sera or both antigens and sera.
#'   In essence this method tries to let you see how robust the map is to inclusion of
#'   particular titer measurements or antigens or sera. Like most bootstrapping techniques it
#'   will prove give more reliable results the more antigens and sera you have in your map. It
#'   won't work very well for a map of 5 sera and antigens for example, in this case a "noisy"
#'   bootstrap may be better.
#'
#'   __"bayesian"__:
#'   The [bayesian bootstrap](https://en.wikipedia.org/wiki/Bootstrapping_(statistics)#Bayesian_bootstrap)
#'   is akin to the resampling bootstrap, but rather than explicitly resampling data, weights are
#'   assigned to each part of the titer table data according to random draws from a dirichilet distribution.
#'   Under this scheme, every data point will play at least some role in making the map, even if only
#'   weighted slightly. Sometimes this is helpful, if you know for example that the points in your map
#'   are highly dependent upon the presence of a few antigens / sera / titers to achieve reasonable
#'   triangulation of point positions and you don't really want to risk removing them completely and
#'   ending up with bootstrap runs that are under-constrained, you might want to consider this approach.
#'   On the other hand this might be exactly what you don't want and you want to know uncertainty that
#'   can be generated when certain subsets of the data are excluded completely, in that case you probably
#'   want to stick with the "resample" method.
#'
#'   __"noisy"__:
#'  The noisy bootstrap, sometimes termed a
#'  [smooth bootstrap](https://en.wikipedia.org/wiki/Bootstrapping_(statistics)#Smooth_bootstrap)
#'  involved adding normally distributed noise to each observation. The distribution of this noise can
#'  be parametrised through the `ag_noise_sd` and `titer_noise_sd` arguments. `titer_noise_sd` refers to the
#'  standard deviation (on the log scale) of noise added to each individual titer measurement in the table,
#'  while `antigen_noise_sd` refers to the standard deviation of noise applied to titers for each antigen.
#'  The reason for this distinction is that we have noticed with repeat measurements of influenza data there
#'  is often both a random noise per titer and a random noise per antigen, i.e. in one repeat titers may all
#'  be around one 2-fold higher on average, in addition to unbiased additional titer noise. If you wish to only
#'  simulate additional noise per titer and not a per antigen effect, simply set `antigen_noise_sd` to 0. Note
#'  that in order to use this most effectively it is best to have an idea of the amount and type of measurement
#'  noise you may expect in your data and set these parameters accordingly.
#'
#' @return Returns the map object updated with bootstrap information
#' @family {map diagnostic functions}
#' @export
#'
bootstrapMap <- function(
  map,
  method,
  bootstrap_repeats        = 1000,
  bootstrap_ags            = TRUE,
  bootstrap_sr             = TRUE,
  reoptimize               = TRUE,
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

  # Check inputs
  if (!method %in% c("resample", "bayesian", "noisy")) {
    stop("'method' must be one of 'resample', 'bayesian', 'noisy'")
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
    bs_result <- ac_bootstrap_map(
      map = keepSingleOptimization(map),
      method = method,
      bootstrap_ags = bootstrap_ags,
      bootstrap_sr = bootstrap_sr,
      reoptimize = reoptimize,
      ag_noise_sd = ag_noise_sd,
      titer_noise_sd = titer_noise_sd,
      minimum_column_basis = minColBasis(map),
      fixed_column_bases = fixedColBases(map),
      ag_reactivity_adjustments = agReactivityAdjustments(map),
      num_optimizations = optimizations_per_repeat,
      num_dimensions = mapDimensions(map),
      options = options
    )

    # Align to the main map coordinates
    bs_result$coords <- ac_align_coords(
      bs_result$coords,
      ptBaseCoords(map)
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
#' @family {map diagnostic functions}
#'

# Underlying function to get base bootstrap coordinates
mapBootstrap_ptBaseCoords <- function(map) {

  # Get bootstrap data
  bootstrap <- map$optimizations[[1]]$bootstrap
  if (is.null(bootstrap)) stop(strwrap(
    "There are no bootstrap repeats associated with this map,
    create some first using 'bootstrapMap()'"
  ))
  lapply(bootstrap, function(x) x$coords)

}

# Underlying function to get ag bootstrap coordinates
mapBootstrap_agBaseCoords <- function(map) {

  num_antigens <- numAntigens(map)
  lapply(mapBootstrap_ptBaseCoords(map), function(x) {
    x[seq_len(num_antigens), , drop = F]
  })

}

# Underlying function to get sr bootstrap coordinates
mapBootstrap_srBaseCoords <- function(map) {

  # Return the data
  num_antigens <- numAntigens(map)
  lapply(mapBootstrap_ptBaseCoords(map), function(x) {
    x[-seq_len(num_antigens), , drop = F]
  })

}


# Underlying function to get bootstrap coordinates
mapBootstrap_ptCoords <- function(map) {

  # Get coordinates
  bootstrap <- mapBootstrap_ptBaseCoords(map)

  # Apply the map transformation to the bootstrap coordinates
  lapply(bootstrap, function(result) {
    applyMapTransform(
      coords = result,
      map = map
    )
  })

}


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
#' @param gridspacing grid spacing to use when calculating blobs, smaller values
#'   will produce more accurate blobs with smoother edges but will take longer
#'   to calculate.
#' @param method One of "MASS", the default, or "ks", specifying the algorithm to
#'   use when calculating blobs in 2D. 3D will always use ks::kde.
#'
#' @return Returns an acmap object that will then show the corresponding bootstrap
#'   blobs when viewed or plotted.
#'
#' @family {map diagnostic functions}
#' @export
#'
bootstrapBlobs <- function(
  map,
  conf.level = 0.68,
  smoothing = 6,
  gridspacing = 0.25,
  method = "ks"
  ) {

  # Get coordinates
  bootstrap_ag_coords <- mapBootstrap_agBaseCoords(map)
  bootstrap_sr_coords <- mapBootstrap_srBaseCoords(map)

  # Set progress bar
  message("Calculating bootstrap blobs")
  pb <- ac_progress_bar(numPoints(map))

  # Calculate for antigens
  for (agnum in seq_along(map$antigens)) {

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
  for (srnum in seq_along(map$sera)) {

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


transformMapBlob <- function(blobs, map) {
  lapply(blobs, function(blob) {
    coords <- applyMapTransform(
      coords = cbind(blob$x, blob$y),
      map = map,
      optimization_number = 1
    )
    blob$x <- coords[,1]
    blob$y <- coords[,2]
    blob
  })
}


#' Get antigen or serum bootstrap coordinates information
#'
#' @param map An acmap object
#' @param antigen The antigen to get the bootstrap coords
#' @param serum The serum from which to get the bootstrap coords
#' @param point The point from which to get the bootstrap coords (numbered
#'   antigens then sera)
#'
#' @return Returns a matrix of coordinates for the point in each of the
#'   bootstrap runs
#' @name ptBootstrapCoords
#'
#' @family {map diagnostic functions}
#'
#' @export
ptBootstrapCoords <- function(map, point) {
  check.acmap(map)
  if (!hasBootstrapBlobs(map)) stop("Map has no bootstrap blobs calculated yet")
  points <- do.call(
    rbind,
    lapply(map$optimizations[[1]]$bootstrap, function(bs) {
      bs$coords[point,]
    })
  )
  applyMapTransform(points, map)
}

#' @rdname ptBootstrapCoords
#' @export
agBootstrapCoords <- function(map, antigen) {
  ptBootstrapCoords(
    map,
    get_ag_indices(antigen, map)
  )
}

#' @rdname ptBootstrapCoords
#' @export
srBootstrapCoords <- function(map, serum) {
  ptBootstrapCoords(
    map,
    numAntigens(map) + get_sr_indices(serum, map)
  )
}


#' Get antigen or serum blob information
#'
#' Get antigen or serum blob information for plotting with the `blob()` function.
#'
#' @param map An acmap object
#' @param antigen The antigen to get the blob for
#' @param serum The serum to get the blob for
#'
#' @return Returns an object of class "blob" that can be plotted using the `blob()` funciton.
#' @name ptBootstrapBlob
#'
#' @family {map diagnostic functions}
#'

#' @rdname ptBootstrapBlob
#' @export
agBootstrapBlob <- function(map, antigen) {
  check.acmap(map)
  if (!hasBootstrapBlobs(map)) stop("Map has no bootstrap blobs calculated yet")
  ag <- get_ag_indices(antigen, map)
  blobs <- transformMapBlob(agBootstrapBlobs(map)[[ag]], map)
  attr(blobs, "fill") <- agFill(map)[ag]
  attr(blobs, "outline") <- agOutline(map)[ag]
  attr(blobs, "lwd") <- agOutlineWidth(map)[ag]
  class(blobs) <- "blob"
  blobs
}

#' @rdname ptBootstrapBlob
#' @export
srBootstrapBlob <- function(map, serum) {
  check.acmap(map)
  if (!hasBootstrapBlobs(map)) stop("Map has no bootstrap blobs calculated yet")
  sr <- get_sr_indices(serum, map)
  blobs <- transformMapBlob(srBootstrapBlobs(map)[[sr]], map)
  attr(blobs, "fill") <- agFill(map)[sr]
  attr(blobs, "outline") <- agOutline(map)[sr]
  attr(blobs, "lwd") <- agOutlineWidth(map)[sr]
  class(blobs) <- "blob"
  blobs
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
