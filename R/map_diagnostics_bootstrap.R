
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
#'   The [resample bootstrap](https://en.wikipedia.org/wiki/Bootstrapping_(statistics)#Case_resampling)
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
#'  be parameterised through the `ag_noise_sd` and `titer_noise_sd` arguments. `titer_noise_sd` refers to the
#'  standard deviation (on the log scale) of noise added to each individual titer measurement in the table,
#'  while `antigen_noise_sd` refers to the standard deviation of noise applied to titers for each antigen.
#'  The reason for this distinction is that we have noticed with repeat measurements of influenza data there
#'  is often both a random noise per titer and a random noise per antigen, i.e. in one repeat titers may all
#'  be around one 2-fold higher on average, in addition to unbiased additional titer noise. If you wish to only
#'  simulate additional noise per titer and not a per antigen effect, simply set `antigen_noise_sd` to 0. Note
#'  that in order to use this most effectively it is best to have an idea of the amount and type of measurement
#'  noise you may expect in your data and set these parameters accordingly.
#'
#' @returns Returns the map object updated with bootstrap information
#' @family map diagnostic functions
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

  map$optimizations[[optimization_number]]$bootstrap

}

# Utility function to check if map has bootstrap data
hasBootstrapData <- function(map, optimization_number) {

  length(bootstrapData(map, optimization_number)) > 0

}


#' Get bootstrap coordinates associated with a map
#'
#' This can be used to get information about the bootstrap run results
#' after `bootstrapMap()` has been run.
#'
#' @param map The map object
#'
#' @returns Returns a list of coordinate matrices for the points in each of
#'   the bootstrap runs
#'
#' @name mapBootstrapCoords
#' @family map diagnostic functions
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


#' Get antigen or serum bootstrap coordinates information
#'
#' @param map An acmap object
#' @param antigen The antigen to get the bootstrap coords
#' @param serum The serum from which to get the bootstrap coords
#' @param point The point from which to get the bootstrap coords (numbered
#'   antigens then sera)
#'
#' @returns Returns a matrix of coordinates for the point in each of the
#'   bootstrap runs
#' @name ptBootstrapCoords
#'
#' @family map diagnostic functions
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
