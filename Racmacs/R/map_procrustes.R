

# Get distances between pairs of coordinates in a table
dist_coord_pairs <- function(coords1,
                             coords2){

  vapply(seq_len(nrow(coords1)), function(x){ euc_dist(coords1[x,], coords2[x,]) }, numeric(1))

}


#' Realign map to match another
#'
#' Realigns the coordinates of a map to match a target map as closely as possible.
#'
#' @param map The acmap to realign.
#' @param target_map The acmap to realign to.
#' @param antigens Antigens to include when calculating the closest realignment, specified either by name or index or FALSE for excluding all.
#' @param sera Sera to include when calculating the closest realignment, specified either by name or index or FALSE for excluding all.
#' @param optimization_number The optimization from the map to realign (default is the currently selected one)
#' @param target_optimization_number The optimization from the target map to realign to (default is the currently selected one)
#' @param passage_matching The type of passage matching to be performed.
#' @param alignTargetToMain Should the target map be realigned to match the main map (default is to
#'   realign main map to match target map) - this is sometimes useful if you want to
#'   match based on antigen and serum indices from the main map.
#'
#' @return Returns the map aligned to the target map (or the target map aligned to the main map if alignTargetToMain is TRUE)
#' @export
#'
realignMap <- function(map,
                        target_map,
                        antigens = TRUE,
                        sera     = TRUE,
                        translation = TRUE,
                        scaling     = FALSE,
                        optimization_number = NULL,
                        target_optimization_number = NULL,
                        passage_matching = "ignore",
                        alignTargetToMain = FALSE,
                        warnings = TRUE){

  # Convert antigens and sera into indices
  antigens <- get_ag_indices(antigens, map, warnings)
  sera     <- get_sr_indices(sera, map, warnings)

  # Get matching antigens from map 2
  matching_ags  <- match_mapAntigens(map, target_map, passage_matching, warnings)[antigens]
  matching_sera <- match_mapSera(map, target_map, passage_matching, warnings)[sera]

  # Get coords from map 1 and map 2
  coords1 <- rbind(agCoords(map, optimization_number)[antigens,,drop=FALSE],     srCoords(map, optimization_number)[sera,,drop=FALSE])
  coords2 <- rbind(agCoords(target_map, target_optimization_number)[matching_ags,,drop=FALSE], srCoords(target_map, target_optimization_number)[matching_sera,,drop=FALSE])

  if(alignTargetToMain){

    # Get transformation matrix for coords 2 to coords 1
    pc_object <- calc_procrustes(source_coords = coords2,
                                 target_coords = coords1,
                                 translation   = translation,
                                 scaling       = scaling)

    # Apply transformation to map 2
    agCoords(target_map, target_optimization_number) <- apply_procrustes(agCoords(target_map, target_optimization_number), pc_object)
    srCoords(target_map, target_optimization_number) <- apply_procrustes(srCoords(target_map, target_optimization_number), pc_object)

    # Return the transformed map 2
    return(target_map)

  } else {

    # Get transformation matrix for coords 1 to coords 2
    pc_object <- calc_procrustes(source_coords = coords1,
                                 target_coords = coords2)

    # Apply transformation to map 1
    agCoords(map, optimization_number) <- apply_procrustes(agCoords(map, optimization_number), pc_object)
    srCoords(map, optimization_number) <- apply_procrustes(srCoords(map, optimization_number), pc_object)

    # Return the transformed map 1
    return(map)

  }

}



#' Return procrustes information
#'
#' Returns information from one map procrusted to another.
#'
#' @param map The acmap data object
#' @param target_map The acmap data object to procrustes against
#' @param antigens Antigens to include in the procrustes, specified either by name or index or FALSE for excluding all.
#' @param sera Sera to include in the procrustes, specified either by name or index or FALSE for excluding all.
#' @param translation Should translation be performed?
#' @param scaling Should scaling be performed?
#' @param optimization_number The map optimization to use in the procrustes calculation (defaults to the currently selected optimization)
#' @param target_optimization_number The target map optimization to use in the procrustes calculation (defaults to the currently selected optimization)
#' @param passage_matching Should passage matching be performed
#'
#' @return Returns procrustes information from the map to the target.
#' @export
#'
procrustesMap <- function(map,
                          target_map,
                          antigens = TRUE,
                          sera     = TRUE,
                          translation = TRUE,
                          scaling     = FALSE,
                          optimization_number = NULL,
                          target_optimization_number = NULL,
                          passage_matching = "ignore",
                          description = NULL){

  # Process optimization numbers
  optimization_number        <- convertOptimizationNum(optimization_number, map)
  target_optimization_number <- convertOptimizationNum(target_optimization_number, target_map)

  # Convert antigen and sera to indices
  antigens <- get_ag_indices(antigens, map)
  sera     <- get_sr_indices(sera, map)

  # Clone map 2
  target_map <- cloneMap(target_map)

  # Realign map 2 to match map 1
  target_map <- realignMap(map,
                           target_map,
                           antigens = antigens,
                           sera     = sera,
                           translation = translation,
                           scaling     = scaling,
                           optimization_number = optimization_number,
                           target_optimization_number = target_optimization_number,
                           passage_matching = passage_matching,
                           alignTargetToMain = TRUE,
                           warnings = FALSE)


  # Get coordinates of map 1
  ag_coords1 <- agCoords(map, optimization_number)
  sr_coords1 <- srCoords(map, optimization_number)


  # Get coordinates from matched antigens in map2
  matching_ags <- match_mapAntigens(map, target_map, passage_matching)
  matching_sr  <- match_mapSera(map, target_map, passage_matching)

  ag_coords2 <- agCoords(target_map, target_optimization_number)[matching_ags,,drop=FALSE]
  sr_coords2 <- srCoords(target_map, target_optimization_number)[matching_sr,,drop=FALSE]

  # Name the coordinates
  rownames(ag_coords2) <- agNames(map)
  rownames(sr_coords2) <- srNames(map)

  # Coordinates of antigens and sera that weren't selected are set to NA
  if(is.null(antigens)){
    ag_coords1[] <- NA
    ag_coords2[] <- NA
  } else {
    ag_coords1[-antigens,] <- NA
    ag_coords2[-antigens,] <- NA
  }

  if(is.null(sera)){
    sr_coords1[] <- NA
    sr_coords2[] <- NA
  } else {
    sr_coords1[-sera,] <- NA
    sr_coords2[-sera,] <- NA
  }

  # Calculate distances
  ag_dists <- dist_coord_pairs(ag_coords1, ag_coords2)
  sr_dists <- dist_coord_pairs(sr_coords1, sr_coords2)

  # Return output
  object <- list(
    map                        = map,
    target_map                 = jsonlite::unbox(name(target_map)),
    optimization_number        = jsonlite::unbox(optimization_number),
    target_optimization_number = jsonlite::unbox(target_optimization_number),
    description                = jsonlite::unbox(description),
    translation                = jsonlite::unbox(translation),
    scaling                    = jsonlite::unbox(scaling),
    antigens                   = antigens,
    sera                       = sera,
    data                       = list(
      ag_dists   = ag_dists,
      sr_dists   = sr_dists,
      ag_rmsd    = jsonlite::unbox(sqrt(mean(ag_dists^2, na.rm = TRUE))),
      sr_rmsd    = jsonlite::unbox(sqrt(mean(sr_dists^2, na.rm = TRUE))),
      total_rmsd = jsonlite::unbox(sqrt(mean(c(ag_dists, sr_dists)^2, na.rm = TRUE))),
      pc_coords = list(
        ag = ag_coords2,
        sr = sr_coords2
      )
    )
  )

  class(object) <- c("racprocrustes", "list")
  object

}


#' Realigns optimizations in the map to the current optimization
#'
#' @param map The acmap data
#' @param antigens The antigens to include in the realignment, TRUE for all FALSE for none, or specified by name or index
#' @param sera The sera to include in the realignment, TRUE for all FALSE for none, or specified by name or index
#'
#' @return Returns the map with realigned optimizations
#' @export
#'
realignOptimizations <- function(map,
                                antigens = TRUE,
                                sera     = TRUE){

  UseMethod("realignOptimizations", map)

}

#' @export
realignOptimizations.racmap <- function(map,
                                       antigens = TRUE,
                                       sera     = TRUE){

  # Check input
  if(isFALSE(antigens) && isFALSE(sera)){
    stop("One or both of antigens and sera must be true")
  }

  # Convert antigens and sera into indices
  antigens <- get_ag_indices(antigens, map, warnings)
  sera     <- get_sr_indices(sera, map, warnings)

  # Get main optimization coordinates
  coords <- rbind(
    agCoords(map, name = FALSE)[antigens,,drop=FALSE],
    srCoords(map, name = FALSE)[sera,,drop=FALSE]
  )

  # Go through each optimization and realign the coordinates
  for(pnum in seq_len(numOptimizations(map))){

    # Get map optimization coordinates
    ag_coords1 <- agCoords(map, pnum, name = FALSE)
    sr_coords1 <- srCoords(map, pnum, name = FALSE)

    # Get subset for procrustes
    pag_coords <- ag_coords1[antigens,,drop=FALSE]
    psr_coords <- sr_coords1[sera,,drop=FALSE]
    pcoords <- rbind(pag_coords, psr_coords)

    # Calculate the procrustes
    pc_result <- calc_procrustes(pcoords, coords)

    # Realign antigens and sera
    agCoords(map, pnum) <- apply_procrustes(ag_coords1, pc_result)
    srCoords(map, pnum) <- apply_procrustes(sr_coords1, pc_result)

  }

  # Return the map
  map

}


#' @export
realignOptimizations.racchart <- function(map,
                                         antigens = TRUE,
                                         sera     = TRUE){

  # Check input
  if(isFALSE(antigens) && isFALSE(sera)){
    stop("One or both of antigens and sera must be true")
  }

  # Convert antigens and sera into indices
  antigens <- get_ag_indices(antigens, map, warnings)
  sera     <- get_sr_indices(sera, map, warnings)

  # Get main optimization coordinates
  num_antigens <- map$chart$number_of_antigens
  optimizations <- map$chart$projections
  coords <- optimizations[[selectedOptimization(map)]]$layout[c(antigens, sera+num_antigens),,drop=FALSE]

  # Go through each optimization and realign the coordinates
  for(pnum in seq_along(optimizations)){

    # Get map optimization coordinates
    optimization <- optimizations[[pnum]]
    ag_coords1 <- optimization$layout
    pcoords    <- ag_coords1[c(antigens, sera+num_antigens),,drop=FALSE]

    # Calculate the procrustes
    pc_result <- calc_procrustes(pcoords, coords)

    # Realign antigens and sera
    optimization$layout <- apply_procrustes(ag_coords1, pc_result)

  }

  # Return the map
  map

}


#' Add procrustes data to a map
#'
#' @param map The acmap data object
#' @param procrustes_data The procrustes data
#'
#' @return Returns the map data with additional diagnostic information on hemisphering points included.
#' @export
#'
add_procrustesData <- function(map,
                               procrustes_data){

  # Process optimizations
  optimization_number <- procrustes_data$optimization_number

  # Remove map
  procrustes_data$map <- NULL

  # Keep a record
  procrustes <- map$procrustes
  if(length(procrustes) < optimization_number) {
    procrustes[[optimization_number]] <- list()
  }
  procrustes[[optimization_number]] <- c(
    procrustes[[optimization_number]],
    list(procrustes_data)
  )

  # Return the updated map
  map$procrustes <- procrustes
  map

}



#' Viewing procrustes data
#'
#' View procrustes data in an interactive viewer.
#'
#' @param map The primary map
#' @param target_map The target map
#' @param ... Arguments to be passed to \code{\link{view_map}}
#'
#' @export
#'
view.racprocrustes <- function(object, ...){

  # Add the procrustes data to the map
  map <- add_procrustesData(
    map             = object$map,
    procrustes_data = object
  )

  view_map(map,
           show_procrustes = TRUE,
           ...)

}



