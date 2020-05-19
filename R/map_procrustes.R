
# Apply procrustes to a map object
apply_procrustes_to_map <- function(
  map,
  optimization_number,
  pc_object
){

  attr(map, "pc_transform") <- pc_object
  map <- scaleMap(map, pc_object$scaling, optimization_number)
  map <- transformMap(map, pc_object$rotation, optimization_number)
  map <- translateMap(map, pc_object$translation, optimization_number)
  map

}

# Get distances between pairs of coordinates in a table
dist_coord_pairs <- function(coords1,
                             coords2){

  # Match dimensions
  while(ncol(coords1) < ncol(coords2)) coords1 <- cbind(coords1, 0)
  while(ncol(coords2) < ncol(coords1)) coords2 <- cbind(coords2, 0)

  vapply(seq_len(nrow(coords1)), function(x){ euc_dist(coords1[x,], coords2[x,]) }, numeric(1))

}

# Calculate the alignment between 2 maps
calculate_map_alignment <- function(
  map,
  target_map,
  antigens                   = TRUE,
  sera                       = TRUE,
  translation                = TRUE,
  scaling                    = FALSE,
  optimization_number        = NULL,
  target_optimization_number = NULL,
  passage_matching           = "ignore",
  warnings                   = TRUE,
  .alignToBaseCoords         = FALSE,
  .alignFromBaseCoords       = FALSE
){

  # Check input
  if(isFALSE(antigens) && isFALSE(sera)){
    stop("One or both of antigens and sera must be true")
  }

  # Convert antigens and sera into indices
  antigens_map <- get_ag_indices(antigens, map, warnings)
  sera_map     <- get_sr_indices(sera, map, warnings)

  # Get matching antigens from map 2
  antigens_target <- match_mapAntigens(map, target_map, passage_matching, warnings)[antigens_map]
  sera_target     <- match_mapSera(map, target_map, passage_matching, warnings)[sera_map]

  # Get coords from map 1 and map 2
  if(.alignFromBaseCoords){
    coords1 <- rbind(agBaseCoords(map, optimization_number, .name = FALSE)[antigens_map,,drop=FALSE],
                     srBaseCoords(map, optimization_number, .name = FALSE)[sera_map,,drop=FALSE])
  } else {
    coords1 <- rbind(agCoords(map, optimization_number, .name = FALSE)[antigens_map,,drop=FALSE],
                     srCoords(map, optimization_number, .name = FALSE)[sera_map,,drop=FALSE])
  }

  if(.alignToBaseCoords){
    coords2 <- rbind(agBaseCoords(target_map, target_optimization_number, .name = FALSE)[antigens_target,,drop=FALSE],
                     srBaseCoords(target_map, target_optimization_number, .name = FALSE)[sera_target,,drop=FALSE])
  } else {
    coords2 <- rbind(agCoords(target_map, target_optimization_number, .name = FALSE)[antigens_target,,drop=FALSE],
                     srCoords(target_map, target_optimization_number, .name = FALSE)[sera_target,,drop=FALSE])
  }

  # Get transformation matrix for coords 1 to coords 2
  calc_procrustes(source_coords = coords1,
                  target_coords = coords2,
                  translation   = translation,
                  scaling       = scaling)

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
#' @family {functions to compare maps}
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
                       warnings = TRUE,
                       .alignToBaseCoords = FALSE){

  # Calculate the map alignment
  pc_object <- calculate_map_alignment(
    map                        = map,
    target_map                 = target_map,
    antigens                   = antigens,
    sera                       = sera,
    translation                = translation,
    scaling                    = scaling,
    optimization_number        = optimization_number,
    target_optimization_number = target_optimization_number,
    passage_matching           = passage_matching,
    warnings                   = warnings,
    .alignToBaseCoords         = .alignToBaseCoords
  )

  # Apply transformation to map 1
  map <- apply_procrustes_to_map(map, optimization_number, pc_object)

  # Return the transformed map 1
  return(map)

}



#' Return procrustes information
#'
#' Returns information from one map procrusted to another.
#'
#' @param map The acmap data object
#' @param comparison_map The acmap data object to procrustes against
#' @param antigens Antigens to include in the procrustes, specified either by name or index or FALSE for excluding all.
#' @param sera Sera to include in the procrustes, specified either by name or index or FALSE for excluding all.
#' @param translation Should translation be performed?
#' @param scaling Should scaling be performed?
#' @param optimization_number The map optimization to use in the procrustes calculation (defaults to the currently selected optimization)
#' @param target_optimization_number The target map optimization to use in the procrustes calculation (defaults to the currently selected optimization)
#' @param passage_matching Should passage matching be performed (not currently implemented)
#'
#' @return Returns procrustes information from the map to the target.
#' @family {functions to compare maps}
#' @export
#'
procrustesMap <- function(map,
                          comparison_map,
                          antigens = TRUE,
                          sera     = TRUE,
                          translation = TRUE,
                          scaling     = FALSE,
                          optimization_number = NULL,
                          comparison_optimization_number = NULL,
                          passage_matching = "ignore",
                          description = NULL){

  # Process optimization numbers
  optimization_number            <- convertOptimizationNum(optimization_number, map)
  comparison_optimization_number <- convertOptimizationNum(comparison_optimization_number, comparison_map)

  # Get dimension of comparison map
  comparison_map_dim <- mapDimensions(comparison_map, comparison_optimization_number)

  # Convert antigens and sera into indices
  antigens <- get_ag_indices(antigens, map, warnings)
  sera     <- get_sr_indices(sera, map, warnings)

  # Get matching antigens from map 2
  antigens_comparison <- match_mapAntigens(map, comparison_map, passage_matching)[antigens]
  sera_comparison     <- match_mapSera(map, comparison_map, passage_matching)[sera]


  # Realign map 2 to match map 1
  pc_transform <- calculate_map_alignment(
    cloneMap(comparison_map),
    cloneMap(map),
    antigens                   = antigens_comparison[!is.na(antigens_comparison)],
    sera                       = sera_comparison[!is.na(sera_comparison)],
    translation                = translation,
    scaling                    = scaling,
    optimization_number        = comparison_optimization_number,
    target_optimization_number = optimization_number,
    passage_matching           = passage_matching,
    .alignToBaseCoords         = TRUE,
    .alignFromBaseCoords       = TRUE
  )


  # Get coordinates of map 1
  ag_coords1 <- agBaseCoords(map, optimization_number)
  sr_coords1 <- srBaseCoords(map, optimization_number)

  # Get coordinates from matched antigens in map2
  matching_ags <- match_mapAntigens(map, comparison_map, passage_matching)
  matching_sr  <- match_mapSera(map, comparison_map, passage_matching)

  ag_coords2 <- agBaseCoords(comparison_map, comparison_optimization_number)[matching_ags,,drop=FALSE]
  sr_coords2 <- srBaseCoords(comparison_map, comparison_optimization_number)[matching_sr,,drop=FALSE]

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

  # Apply the transformation
  ag_coords2_realigned <- apply_procrustes(ag_coords2, pc_transform, dim_match = TRUE, rotate2Dto3D = TRUE)
  sr_coords2_realigned <- apply_procrustes(sr_coords2, pc_transform, dim_match = TRUE, rotate2Dto3D = TRUE)

  # Calculate distances
  ag_dists <- dist_coord_pairs(ag_coords1, ag_coords2_realigned)
  sr_dists <- dist_coord_pairs(sr_coords1, sr_coords2_realigned)

  # Return output
  map <- cloneMap(map)
  map$procrustes <- list(
    comparison_map             = name(comparison_map),
    optimization_number        = optimization_number,
    target_optimization_number = comparison_optimization_number,
    description                = description,
    translation                = translation,
    scaling                    = scaling,
    antigens                   = antigens,
    sera                       = sera,
    ag_dists                   = ag_dists,
    sr_dists                   = sr_dists,
    ag_rmsd                    = sqrt(mean(ag_dists^2, na.rm = TRUE)),
    sr_rmsd                    = sqrt(mean(sr_dists^2, na.rm = TRUE)),
    total_rmsd                 = sqrt(mean(c(ag_dists, sr_dists)^2, na.rm = TRUE)),
    pc_transform               = pc_transform,
    comparison_coords          = list(
      ag = unname(ag_coords2),
      sr = unname(sr_coords2)
    ),
    pc_coords                  = list(
      ag  = unname(ag_coords2_realigned),
      sr  = unname(sr_coords2_realigned),
      dim = comparison_map_dim
    )
  )

  # Return the map
  map

}


#' Realigns optimizations in the map to the current optimization
#'
#' @param map The acmap data
#' @param antigens The antigens to include in the realignment, TRUE for all FALSE for none, or specified by name or index
#' @param sera The sera to include in the realignment, TRUE for all FALSE for none, or specified by name or index
#'
#' @return Returns the map with realigned optimizations
#' @family {functions to compare maps}
#' @export
#'
realignOptimizations <- function(map,
                                 antigens = TRUE,
                                 sera     = TRUE,
                                 optimization_number = NULL){

  UseMethod("realignOptimizations", map)

}

#' @export
realignOptimizations.racchart <- function(map,
                                          antigens = TRUE,
                                          sera     = TRUE,
                                          optimization_number = NULL){

  map <- as.list(map)
  map <- realignOptimizations(
    map                 = map,
    antigens            = antigens,
    sera                = sera,
    optimization_number = optimization_number
  )
  as.cpp(map)

}


#' @export
realignOptimizations.racmap <- function(map,
                                        antigens = TRUE,
                                        sera     = TRUE,
                                        optimization_number = NULL){

  # Process optimization numbers
  optimization_number <- convertOptimizationNum(optimization_number, map)

  # Skip if 1 or no optimizations
  if(numOptimizations(map) < 2) return(map)

  # Go through each optimization and realign the coordinates
  for(noptimization in seq_len(numOptimizations(map))){

    if(noptimization == optimization_number) next
    map <- realignMap(
      map         = map,
      target_map  = map,
      antigens    = antigens,
      sera        = sera,
      translation = TRUE,
      scaling     = FALSE,
      optimization_number        = noptimization,
      target_optimization_number = optimization_number
    )

  }

  # Return the map
  map

}


add_procrustes_grid <- function(map){

  # Get the comparator coordinates
  comp_coords <- rbind(
    map$procrustes$comparison_coords$ag,
    map$procrustes$comparison_coords$sr
  )

  # Calculate grid limits and the grid points
  plims <- plot_lims(comp_coords)
  x <- seq(from = plims$xlim[1], to = plims$xlim[2])
  y <- seq(from = plims$ylim[1], to = plims$ylim[2])
  grid_coords <- as.matrix(expand.grid(x, y))
  grid_coords <- cbind(grid_coords, 0)
  grid_coords <- apply_procrustes(grid_coords, map$procrustes$pc_transform)

  # Add the surface to the map
  r3js::surface3js(
    map,
    x = matrix(grid_coords[,1], length(x), length(y)),
    y = matrix(grid_coords[,2], length(x), length(y)),
    z = matrix(grid_coords[,3], length(x), length(y)),
    wireframe = TRUE,
    col = "#cccccc"
  )

}


