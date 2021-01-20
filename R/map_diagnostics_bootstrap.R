
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

# Underlying function to get bootstrap coordinates
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


#' Calculate a blob geometry representing bootstrap point position variation
#'
#' This function is used to create "blob" geometries, with the aim to visualise
#' how point positions vary amongst bootstrap repeats. The underlying approach
#' is to fit a kernel density estimate to the coordinates and then draw blobs
#' that capture the requested point density.
#'
#' @param coords matrix of a points coordinates across the bootstrap repeats
#' @param conf.level the confidence level, i.e. proportion of point variation the blob should capture
#' @param smoothing the amount of smoothing to perform when performing the kernel density estimate
#'
#' @noRd
#'
coordDensityBlob <- function(
  coords,
  conf.level = 0.68,
  smoothing = 6
  ){

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






