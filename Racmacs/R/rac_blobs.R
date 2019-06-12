
#' Calculate stress blob information
#'
#' @param map The acmap data object
#' @param optimization_number The optimization number (defaults to the currently selected one)
#' @param stress_lim The blob stress limit
#' @param antigens Antigens to calculate blobs for (TRUE for all FALSE for none, or specified by name or index)
#' @param sera Sera to calculate blobs for (TRUE for all FALSE for none, or specified by name or index)
#' @param grid_spacing Grid spacing to use when calculating the blob
#' @param grid_margin Grid margin to use when calculating the blob
#' @param progress_fn Function to use for progress reporting
#'
#' @return Returns stress blob information
#' @export
#'
calculate_stressBlob <- function(
  map,
  optimization_number   = NULL,
  stress_lim   = 1,
  antigens     = TRUE,
  sera         = TRUE,
  grid_spacing = 0.1,
  grid_margin  = 4,
  progress_fn  = message
){

  # Get the optimization number
  if(is.null(optimization_number)) optimization_number <- selectedOptimization(map)

  # Convert antigens and sera to indices
  oantigens <- antigens
  osera     <- sera

  antigens <- get_ag_indices(antigens, map)
  sera     <- get_sr_indices(sera, map)

  # Get necessary values
  ag_coords <- agCoords(map, optimization_number, name = FALSE)
  sr_coords <- srCoords(map, optimization_number, name = FALSE)
  pt_coords <- rbind(ag_coords, sr_coords)
  titer_table  <- titerTable(map, name = FALSE)
  colbases  <- colBases(map, name = FALSE)
  num_antigens <- nrow(ag_coords)
  num_sera     <- nrow(sr_coords)
  num_dimensions <- ncol(ag_coords)

  # Calculate the map distances
  map_dist   <- ac_mapDists(ag_coords = ag_coords,
                            sr_coords = sr_coords)

  # Calculate the table distances
  table_dist <- ac_tableDists(titer_table = titer_table,
                              colbases = colbases)

  # Create the prediction grid
  grid_margin <- 4
  grid_points <- lapply(as.data.frame(pt_coords), function(x){
    seq(from = floor(min(x, na.rm = TRUE))   - grid_margin,
        to   = ceiling(max(x, na.rm = TRUE)) + grid_margin,
        by   = grid_spacing)
  })
  coord_grid <- as.matrix(expand.grid(grid_points))

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
      ag_blobs[[ag_num]] <- contour_blob(grid_stresses - start_stress,
                                         grid_points,
                                         stress_lim)

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
    if(!is.null(progress_fn)){ progress_fn(progress/(length(antigens) + length(sera))) }

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

      # Get start stress
      start_stress <- grid_search(test_coords = test_sr_coords,
                                  pair_coords = map$ag_coords[!na_coords,,drop=FALSE],
                                  table_dist  = table_dist$distances[!na_coords,sr_num],
                                  lessthans   = table_dist$lessthans[!na_coords,sr_num],
                                  morethans   = table_dist$morethans[!na_coords,sr_num],
                                  na_vals     = is.na(table_dist$distances)[!na_coords,sr_num])

      # Define the function for testing if a point falls in or out of the blob
      grid_stresses <- grid_search(test_coords = coord_grid,
                                   pair_coords = map$ag_coords[!na_coords,,drop=FALSE],
                                   table_dist  = table_dist$distances[!na_coords,sr_num],
                                   lessthans   = table_dist$lessthans[!na_coords,sr_num],
                                   morethans   = table_dist$morethans[!na_coords,sr_num],
                                   na_vals     = is.na(table_dist$distances)[!na_coords,sr_num])

      # Fit the contour
      sr_blobs[[sr_num]] <- contour_blob(grid_stresses - start_stress,
                                         grid_points,
                                         stress_lim)

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
    if(!is.null(progress_fn)){ progress_fn(progress/(length(antigens) + length(sera))) }

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
    sera         = osera
  )

}


#' Fit a contour blob
#'
contour_blob <- function(grid_values,
                         grid_points,
                         value_lim) {

  grid_values <- array(grid_values, dim = sapply(grid_points, length))

  ## 2D
  if(length(grid_points) == 2){

    blob <- contourLines(x = grid_points[[1]],
                         y = grid_points[[2]],
                         z = grid_values,
                         levels = value_lim)

  }

  ## 3D
  if(length(grid_points) == 3){

    contour_fit <- misc3d::computeContour3d(vol    = grid_values,
                                            x      = grid_points[[1]],
                                            y      = grid_points[[2]],
                                            z      = grid_points[[3]],
                                            level  = value_lim)

    blob <- list(vertices = contour_fit,
                 faces    = matrix(seq_len(nrow(contour_fit)), ncol = 3, byrow = TRUE))

  }

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
#' @param grid_margin Grid margin to use when calculating the blob
#' @param progress_fn Function to use for progress reporting
#'
#' @return Returns the acmap data object with stress blob information added
#' @export
#'
add_stressBlobData <- function(map,
                               data         = NULL,
                               optimization_number   = NULL,
                               stress_lim   = 1,
                               antigens     = TRUE,
                               sera         = TRUE,
                               grid_spacing = 0.25,
                               grid_margin  = 4,
                               progress_fn  = message){

  # Process optimization
  optimization_number <- convertOptimizationNum(optimization_number, map)

  # Calculate blob data
  if(is.null(data)){
    data <- calculate_stressBlob(map,
                                 optimization_number = optimization_number,
                                 stress_lim   = stress_lim,
                                 antigens     = antigens,
                                 sera         = sera,
                                 grid_spacing = grid_spacing,
                                 grid_margin  = grid_margin,
                                 progress_fn  = progress_fn)
  }

  # Keep a record
  if(length(map$diagnostics) < optimization_number) {
    map$diagnostics[[optimization_number]] <- list()
  }
  map$diagnostics[[optimization_number]]$stress_blobs <- c(
    map$diagnostics[[optimization_number]]$stress_blobs,
    list(data)
  )

  # Return the updated map
  map

}












