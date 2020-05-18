
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
  progress_fn              = message
){

  # Get map optimization details
  num_dimensions <- mapDimensions(map)
  colbases       <- colBases(map)

  # Clone map and remove transformation
  map <- cloneMap(map)
  map <- clearTransformation(map)

  # Get map and sera name details
  agnames <- agNames(map)
  srnames <- srNames(map)

  # Get titer table details
  titertable      <- titerTable(map)
  lessthans       <- substr(titertable, 1, 1) == "<"
  morethans       <- substr(titertable, 1, 1) == ">"
  natiters        <- titertable == "*"

  # Get log titers
  logtitertable            <- matrix(nrow = nrow(titertable), ncol = ncol(titertable))
  logtitertable[!natiters] <- log2(as.numeric(gsub("(<|>)", "", titertable[!natiters]))/10)

  # Generate noise matrices
  bootstrap_noise <- lapply(
    seq_len(bootstrap_repeats),
    make_noise_matrix,
    dims = dim(logtitertable),
    ag_noise_sd = ag_noise_sd,
    titer_noise_sd = titer_noise_sd
  )

  # Generate the noisy HI tables
  noisy_tables <- lapply(
    bootstrap_noise,
    function(noise){

      noisylogtiters <- logtitertable + noise$noise_matrix
      noisylessthans <- noisylogtiters < 0
      noisylogtiters[noisylessthans] <- 0
      noisytiters    <- round(2^noisylogtiters*10)
      noisytiters[lessthans] <- paste0("<", noisytiters[lessthans])
      noisytiters[morethans] <- paste0(">", noisytiters[morethans])
      noisytiters[natiters]  <- "*"
      noisytiters[noisylessthans] <- paste("<", noisytiters[noisylessthans])
      noisytiters

    }
  )

  # Get the map coords for each bootstrap run
  bootstrap_coords <- lapply(
    seq_along(noisy_tables),
    function(x){

      progress_fn(x/length(noisy_tables))
      noisy_table <- noisy_tables[[x]]

      bootmap <- acmap.cpp(
        table = noisy_table
      )

      bootmap$chart$set_column_bases(colbases)
      tryCatch({
        bootmap$chart$relax_many(
          "none",
          num_dimensions,
          optimizations_per_repeat,
          TRUE
        )
      }, error = function(e){ browser() })
      bootmap$chart$sort_projections()
      selectedOptimization(bootmap) <- 1

      agNames(bootmap) <- agnames
      srNames(bootmap) <- srnames

      bootmap <- realignMap(bootmap, map)
      rbind(agCoords(bootmap, .name = FALSE), srCoords(bootmap, .name = FALSE))

    }
  )

  # Store the results
  setMapAttribute(
    map,
    "bootstrap",
    list(
      ag_noise = lapply(bootstrap_noise, function(x) x$ag_noise ),
      coords   = bootstrap_coords
    )
  )

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

  # Get bootstrap data
  bootstrap <- getMapAttribute(map, "bootstrap")
  if(is.null(bootstrap)) stop("There are no bootstrap repeats associated with this map, create some first using 'bootstrapMap()'")

  # Return the data
  num_antigens <- numAntigens(map)
  lapply(mapBootstrap_ptCoords(map), function(x){ x[-seq_len(num_antigens),,drop=F] })

}


mapBootstrap_ptCoords <- function(map){

  # Get bootstrap data
  bootstrap <- getMapAttribute(map, "bootstrap")
  if(is.null(bootstrap)) stop("There are no bootstrap repeats associated with this map, create some first using 'bootstrapMap()'")

  # Apply the map transformation to the bootstrap coordinates
  lapply(bootstrap$coords, applyMapTransform, map = map)

}




bootstrapFromJsonlist <- function(jsonlist){

  bootstrap          <- jsonlist
  bootstrap$ag_noise <- lapply(bootstrap$ag_noise, unlist)
  bootstrap$coords   <- lapply(bootstrap$coords, unlist)
  bootstrap$coords   <- lapply(bootstrap$coords, matrix, ncol = length(jsonlist$coords[[1]][[1]]), byrow = TRUE)
  bootstrap

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




