
# Function to generate the noise matrices
make_noise_matrix <- function(
  dims,
  ag_noise_sd,
  titer_noise_sd,
  ...
){

  # Make noise matrix
  noise_matrix <- matrix(0, dims[1], dims[2])

  # Generate noise
  titer_noise <- rnorm(length(noise_matrix), sd = titer_noise_sd)
  ag_noise    <- rnorm(nrow(noise_matrix),   sd = ag_noise_sd)

  # Return the matrix
  list(
    noise_matrix = noise_matrix + titer_noise + ag_noise,
    ag_noise     = ag_noise
  )

}


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
  column_bases_from_original_table = FALSE,
  method = "L-BFGS-B",
  maxit = 1000,
  dim_annealing = FALSE
){

  # Check there are already some map optimizations
  if(numOptimizations(map) == 0){
    stop("First run some optimizations on this map with 'optimizeMap()'", call. = FALSE)
  }

  # Run the bootstrap
  map$bootstrap <- plapply(
    progress_msg = paste("Performing", bootstrap_repeats, "noisy bootstrap repeats..."),
    seq_len(bootstrap_repeats), function(x){

    # Do a bootstrap run
    bs_result <- ac_noisy_bootstrap_map(
      titer_table = titerTable(map),
      ag_noise_sd = ag_noise_sd,
      titer_noise_sd = titer_noise_sd,
      minimum_column_basis = minColBasis(map),
      column_bases_from_full_table = column_bases_from_original_table,
      num_optimizations = optimizations_per_repeat,
      num_dimensions = mapDimensions(map),
      method = method,
      maxit = maxit,
      dim_annealing = dim_annealing
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




bootstrapFromJsonlist <- function(jsonlist){

  lapply(jsonlist, function(result){
    list(
      ag_noise = unlist(result$ag_noise),
      coords = matrix(
        data  = unlist(result$coords),
        ncol  = length(result$coords[[1]][[1]]),
        byrow = TRUE
      )
    )
  })

}

bootstrapToJsonList <- function(bootstrap){

  I(bootstrap)

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

plotBootstrapBlob <- function(
  map,
  pointnum,
  conf.level = 0.68,
  smoothing = 6,
  ...
) {

  # Get the blob data
  bootstrapBlob(map, pointnum, conf.level, smoothing)

  # Plot the blobs
  lapply(blob, function(b){ lines(b$x, b$y, ...) })

}


bootstrapBlob <- function(
  map,
  pointnum,
  conf.level = 0.68,
  smoothing = 6
){

  # Get bootstrap coords
  coords <- do.call(rbind, lapply(mapBootstrap_ptCoords(map), function(x) x[pointnum,]))

  # Calculate the blob
  coordDensityBlob(
    coords     = coords,
    conf.level = conf.level,
    smoothing  = smoothing
  )

}

#' @export
#' @family bootstrapping maps
bootstrapBlobs <- function(
  map,
  conf.level = 0.68,
  smoothing = 6
){

  lapply(
    seq_len(numPoints(map)),
    bootstrapBlob,
    map        = map,
    conf.level = conf.level,
    smoothing  = smoothing
  )

}


plotBootstrapPoints <- function(
  map,
  pointnum,
  ...
) {

  # Get bootstrap coords
  coords <- do.call(rbind, lapply(mapBootstrap_ptCoords(map), function(x) x[pointnum,]))

  # Calculate the blob
  points(coords, ...)

}




