
#' Perform a noisy bootstrap
#'
#' Perform a noisy bootstrap on a map, adding random noise and reoptimizing from scratch.
#'
#' @param map The map object
#' @param bootstrap_repeats The number of bootstrap repeats to perform
#' @param optimizations_per_repeat When reoptimizing the map from scratch, the number of optimization runs to perform
#' @param ag_noise_sd The standard deviation to use when applying noise per antigen
#' @param titer_noise_sd The standard deviation to use when applying noise per titer
#'
#' @return Returns the updated map object
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
){

  # Check there are already some map optimizations
  if(numOptimizations(map) == 0){
    stop("First run some optimizations on this map with 'optimizeMap()'", call. = FALSE)
  }

  # Set options
  options <- do.call(RacOptimizer.options, options)

  # Run the bootstrap
  map$bootstrap <- lapply(seq_len(bootstrap_repeats), function(x){

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

    # Return the result
    bs_result

  })

  # Return the map
  map

}



#' Get bootstrap coordinates associated with a map
#'
#' @param map The map object
#'
#' @name mapBootstrapCoords
#' @family bootstrapping maps
#'

#' @rdname mapBootstrapCoords
#' @export
mapBootstrap_agCoords <- function(map){

  # Return the data
  num_antigens <- numAntigens(map)
  lapply(mapBootstrap_ptCoords(map), function(x){ x[seq_len(num_antigens),,drop=F] })

}

#' @rdname mapBootstrapCoords
#' @export
mapBootstrap_srCoords <- function(map){

  # Return the data
  num_antigens <- numAntigens(map)
  lapply(mapBootstrap_ptCoords(map), function(x){ x[-seq_len(num_antigens),,drop=F] })

}


mapBootstrap_ptCoords <- function(map){

  # Get bootstrap data
  bootstrap <- map$bootstrap
  if(is.null(bootstrap)) stop("There are no bootstrap repeats associated with this map, create some first using 'bootstrapMap()'")

  # Apply the map transformation to the bootstrap coordinates
  lapply(bootstrap, function(result){
    applyMapTransform(
      coords = result$coords,
      map = map
    )
  })

}


coordDensityBlob <- function(coords, conf.level = 0.68, smoothing = 6){

  # Check dimensions
  if(ncol(coords) != 2) stop("Bootstrap blobs are only supported for 2 dimensions")

  # Check confidence level
  if(conf.level != round(conf.level, 2)) stop("Confidence level must be to the nearest percent")

  # Perform a kernal density fit
  kd_fit <- ks::kde(coords, gridsize = 50, H = ks::Hpi(x = coords, nstage = 2, deriv.order = 0)*smoothing)

  # Calculate the contour blob
  contour_blob(
    grid_values = kd_fit$estimate,
    grid_points = kd_fit$eval.points,
    value_lim   = ks::contourLevels(kd_fit, prob = 1 - conf.level)
  )

}






