
#' Calculate stress blob information
#'
#' @param map The acmap data object
#' @param optimization_number The optimization number (defaults to the currently selected one)
#' @param stress_lim The blob stress limit
#' @param antigens Antigens to calculate blobs for (TRUE for all FALSE for none, or specified by name or index)
#' @param sera Sera to calculate blobs for (TRUE for all FALSE for none, or specified by name or index)
#' @param grid_spacing Grid spacing to use when calculating the blob
#' @param progress_fn Function to use for progress reporting
#'
#' @return Returns stress blob information
#' @noRd
#'
calculate_stressBlob <- function(
  map,
  optimization_number   = NULL,
  stress_lim   = 1,
  antigens     = TRUE,
  sera         = TRUE,
  grid_spacing = 0.1,
  .progress    = NULL
){

  # Set a default progress function
  if(is.null(.progress)){
    .progress <- list(
      init   = function()      { txtProgressBar(min = 0, max = 1, style = 3) },
      update = function(x, pb) { setTxtProgressBar(pb, x) },
      end    = function(pb)    { close(pb) }
    )
  }

  # Initiate progress bar
  if(!isFALSE(.progress)){
    message("Calculating blobs")
    progressbar <- .progress$init()
  }

  # Get the optimization number
  if(is.null(optimization_number)) optimization_number <- selectedOptimization(map)

  # Convert antigens and sera to indices
  oantigens <- antigens
  osera     <- sera

  antigens <- get_ag_indices(antigens, map)
  sera     <- get_sr_indices(sera, map)

  # Get necessary values
  ag_coords <- agBaseCoords(map, optimization_number, .name = FALSE)
  sr_coords <- srBaseCoords(map, optimization_number, .name = FALSE)
  pt_coords <- rbind(ag_coords, sr_coords)
  titer_table  <- titerTable(map, .name = FALSE)
  colbases     <- colBases(map, .name = FALSE)
  num_antigens <- nrow(ag_coords)
  num_sera     <- nrow(sr_coords)
  num_dimensions <- ncol(ag_coords)

  # Calculate the map distances
  map_dist   <- ac_mapDists(ag_coords = ag_coords,
                            sr_coords = sr_coords)

  # Calculate the table distances
  table_dist <- ac_tableDists(titer_table = titer_table,
                              colbases = colbases)


  # Store progress
  progress <- 0

  # Store stress blobs
  ag_blobs <- list()
  ag_min_stress <- rep(NA, num_antigens)
  ag_best_coords <- matrix(nrow = num_antigens,
                           ncol = num_dimensions)

  for(ag_num in antigens){


    # Get test coords
    test_ag_coords <- ag_coords[ag_num,,drop=F]
    na_coords <- apply(is.na(sr_coords), 1, sum) > 0

    # Check there are no na coordinates
    if(sum(is.na(test_ag_coords)) == 0){

      # Create the prediction grid
      tabledists <- table_dist$distances[ag_num,]
      gridlims <- lapply(seq_len(num_dimensions), function(n){
        c(
          min(sr_coords[,n] - tabledists - stress_lim, na.rm = T),
          max(sr_coords[,n] + tabledists + stress_lim, na.rm = T)
        )
      })
      grid_points <- lapply(gridlims, function(x){
        seq(from = x[1],
            to   = x[2],
            by   = grid_spacing)
      })
      coord_grid <- as.matrix(expand.grid(grid_points))

      # Get start stress
      start_stress <- grid_search(test_coords = test_ag_coords,
                                  pair_coords = sr_coords[!na_coords,,drop=FALSE],
                                  table_dist  = table_dist$distances[ag_num,!na_coords],
                                  lessthans   = table_dist$lessthans[ag_num,!na_coords],
                                  morethans   = table_dist$morethans[ag_num,!na_coords],
                                  na_vals     = is.na(table_dist$distances)[ag_num,!na_coords])

      # Define the function for testing if a point falls in or out of the blob
      grid_stresses <- grid_search(test_coords = coord_grid,
                                   pair_coords = sr_coords[!na_coords,,drop=FALSE],
                                   table_dist  = table_dist$distances[ag_num,!na_coords],
                                   lessthans   = table_dist$lessthans[ag_num,!na_coords],
                                   morethans   = table_dist$morethans[ag_num,!na_coords],
                                   na_vals     = is.na(table_dist$distances)[ag_num,!na_coords])

      # Create the blob data
      blob <- contour_blob(grid_stresses - start_stress,
                           grid_points,
                           stress_lim)
      ag_blobs[[ag_num]]     <- blob

      # Keep a record of the best coordinates
      min_grid_stress_num <- which.min(grid_stresses)
      min_grid_stress     <- grid_stresses[min_grid_stress_num]
      if(start_stress < min_grid_stress){
        ag_min_stress[ag_num]  <- start_stress
        ag_best_coords[ag_num,] <- test_ag_coords
      } else {
        ag_min_stress[ag_num]  <- min_grid_stress
        ag_best_coords[ag_num,] <- coord_grid[min_grid_stress_num,]
      }

    }

    # Update the progress function
    progress <- progress + 1
    if(!isFALSE(.progress)){
      .progress$update(progress/(length(antigens) + length(sera)), progressbar)
    }

  }

  sr_blobs <- list()
  sr_min_stress <- rep(NA, num_sera)
  sr_best_coords <- matrix(nrow = num_sera,
                           ncol = num_dimensions)

  for(sr_num in sera){

    # Get test coords
    test_sr_coords <- sr_coords[sr_num,,drop=F]
    na_coords <- apply(is.na(ag_coords), 1, sum) > 0

    # Check there are no na coordinates
    if(sum(is.na(test_sr_coords)) == 0){

      # Create the prediction grid
      tabledists <- table_dist$distances[,sr_num]
      gridlims <- lapply(seq_len(num_dimensions), function(n){
        c(
          min(ag_coords[,n] - tabledists - stress_lim, na.rm = T),
          max(ag_coords[,n] + tabledists + stress_lim, na.rm = T)
        )
      })
      grid_points <- lapply(gridlims, function(x){
        seq(from = x[1],
            to   = x[2],
            by   = grid_spacing)
      })
      coord_grid <- as.matrix(expand.grid(grid_points))

      # Get start stress
      start_stress <- grid_search(test_coords = test_sr_coords,
                                  pair_coords = agBaseCoords(map)[!na_coords,,drop=FALSE],
                                  table_dist  = table_dist$distances[!na_coords,sr_num],
                                  lessthans   = table_dist$lessthans[!na_coords,sr_num],
                                  morethans   = table_dist$morethans[!na_coords,sr_num],
                                  na_vals     = is.na(table_dist$distances)[!na_coords,sr_num])

      # Define the function for testing if a point falls in or out of the blob
      grid_stresses <- grid_search(test_coords = coord_grid,
                                   pair_coords = agBaseCoords(map)[!na_coords,,drop=FALSE],
                                   table_dist  = table_dist$distances[!na_coords,sr_num],
                                   lessthans   = table_dist$lessthans[!na_coords,sr_num],
                                   morethans   = table_dist$morethans[!na_coords,sr_num],
                                   na_vals     = is.na(table_dist$distances)[!na_coords,sr_num])

      # Fit the contour
      blob <- contour_blob(grid_stresses - start_stress,
                           grid_points,
                           stress_lim)
      sr_blobs[[sr_num]]     <- blob

      # Keep a record of the best coordinates
      min_grid_stress_num <- which.min(grid_stresses)
      min_grid_stress     <- grid_stresses[min_grid_stress_num]
      if(start_stress < min_grid_stress){
        sr_min_stress[sr_num]   <- start_stress
        sr_best_coords[sr_num,] <- test_sr_coords
      } else {
        sr_min_stress[sr_num]   <- min_grid_stress
        sr_best_coords[sr_num,] <- coord_grid[min_grid_stress_num,]
      }

    }

    # Update the progress function
    progress <- progress + 1
    if(!isFALSE(.progress)){
      .progress$update(progress/(length(antigens) + length(sera)), progressbar)
    }

  }

  # Close progress bar
  if(!isFALSE(.progress)){
     .progress$end(progressbar)
  }

  # Return the stress blobs
  blob_data <- list(
    antigens = ag_blobs,
    sera     = sr_blobs,
    ag_min_stress = ag_min_stress,
    sr_min_stress = sr_min_stress,
    ag_best_coords = ag_best_coords,
    sr_best_coords = sr_best_coords
  )

  list(
    stress_lim   = stress_lim,
    grid_spacing = grid_spacing,
    blob_data    = blob_data,
    antigens     = oantigens,
    sera         = osera,
    ndim         = mapDimensions(map, optimization_number)
  )

}


#' Fit a contour blob
#' @noRd
contour_blob <- function(grid_values,
                         grid_points,
                         value_lim) {

  grid_values <- array(grid_values, dim = sapply(grid_points, length))
  ndims       <- length(grid_points)

  ## 2D
  if(ndims == 2){

    blob <- grDevices::contourLines(x = grid_points[[1]],
                                    y = grid_points[[2]],
                                    z = grid_values,
                                    levels = value_lim)

  }

  ## 3D
  if(ndims == 3){

    contour_fit <- contourShape(vol    = grid_values,
                                maxvol = max(grid_values[!is.nan(grid_values) & grid_values != Inf]),
                                x      = grid_points[[1]],
                                y      = grid_points[[2]],
                                z      = grid_points[[3]],
                                level  = value_lim)

    blob <- list(vertices = contour_fit,
                 faces    = matrix(seq_len(nrow(contour_fit)), ncol = 3, byrow = TRUE))

  }

  ## Blob volumes
  gridsize    <- abs(diff(grid_points[[1]][1:2]))
  attr(blob, "volume") <- sum(grid_values <= value_lim)*gridsize^ndims

  # Return the blob
  blob

}



#' Add stress blob data to a map object
#'
#' @param map The acmap data object
#' @param data The stress data to add (calculated if not provided)
#' @param optimization_number The optimization number (defaults to the currently selected one)
#' @param stress_lim The blob stress limit
#' @param antigens Antigens to calculate blobs for (TRUE for all FALSE for none, or specified by name or index)
#' @param sera Sera to calculate blobs for (TRUE for all FALSE for none, or specified by name or index)
#' @param grid_spacing Grid spacing to use when calculating the blob
#' @param progress_fn Function to use for progress reporting
#'
#' @return Returns the acmap data object with stress blob information added
#' @export
#'
stressBlobs <- function(map,
                        stress_lim            = 1,
                        antigens              = TRUE,
                        sera                  = TRUE,
                        grid_spacing          = 0.25,
                        .progress             = NULL,
                        .check_relaxation     = TRUE){

  # Only run on current optimization
  optimization_number <- NULL

  # Check map has been fully relaxed
  if(.check_relaxation && !mapRelaxed(map, optimization_number)){
    stop("Map is not fully relaxed, please relax the map first.")
  }

  # Calculate blob data
  map$stressblobs <- calculate_stressBlob(
    map,
    optimization_number = optimization_number,
    stress_lim          = stress_lim,
    antigens            = antigens,
    sera                = sera,
    grid_spacing        = grid_spacing,
    .progress           = .progress
  )

  # Return the map with blob data
  map

}

hasStressBlobs <- function(map){
  !is.null(map$stressblobs)
}

stressBlobGeometries <- function(map){

  if(!hasStressBlobs(map)){
    stop("Map does not have stress blob data, use the stressBlobs() function to calculate it.")
  }

  list(
    antigens = map$stressblobs$blob_data$antigens,
    sera     = map$stressblobs$blob_data$sera
  )

}

stressBlobSize <- function(map){

  if(!hasStressBlobs(map)){
    stop("Map does not have stress blob data, use the stressBlobs() function to calculate it.")
  }

  if(map$stressblobs$ndim == 2){
    calcBlobSize <- calcBlobArea
  } else {
    warning("Blob volumes are approximate")
    calcBlobSize <- calcBlobVolume
  }

  list(
    antigens = calcBlobSize(map$stressblobs$blob_data$antigens),
    sera     = calcBlobSize(map$stressblobs$blob_data$sera)
  )

}

agStressBlobSize <- function(map){ stressBlobSize(map)$antigens }
srStressBlobSize <- function(map){ stressBlobSize(map)$sera     }

calcBlobArea <- function(blob){

  vapply(
    blob,
    function(b){
      vapply(b, function(b0){
        geometry::polyarea(
          x = b0$x,
          y = b0$y
        )
      }, numeric(1))
    },
    numeric(1)
  )

}

calcBlobVolume <- function(blob){

  vapply(
    blob,
    function(b){
      attr(b, "volume")
    },
    numeric(1)
  )

}

contourShape <- function(
  vol,
  maxvol,
  x,
  y,
  z,
  level
){

  misc3d::computeContour3d(
    vol    = vol,
    maxvol = maxvol,
    x      = x,
    y      = y,
    z      = z,
    level  = level
  )

}



