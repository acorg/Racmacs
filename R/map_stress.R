
# Titer conversion to a character matrix
convert_titers <- function(titers){
  titers[is.na(titers)] <- "*"
  mode(titers) <- "character"
  titers
}

# Get a matrix of integer types representing the titer types
# 0: unmeasured, 1: measurable, 2: lessthan, 3: morethan
titerTypesInt <- function(titers){

  matrix(
    titer_types_int(titers),
    nrow(titers), ncol(titers)
  )

}

#' @export
tableColbases <- function(
  titer_table,
  min_col_basis,
  fixed_col_bases = rep(NA, ncol(titer_table))
  ){

  ac_table_colbases(
    titer_table     = convert_titers(titer_table),
    min_col_basis   = min_col_basis,
    fixed_col_bases = fixed_col_bases
  )

}

#' Return calculated table distances for an acmap
#'
#' Takes the acmap object and, assuming the column bases associated with the
#' currently selected or specifed optimization, returns the table distances
#' calculated from the titer data.
#'
#' @param map The acmap data object
#' @param optimization_number The optimization data to access (defaults to the currently selected optimization)
#'
#' @return Returns a list with a matrix of numeric table distances and whether
#'   they are associated with more than or less than titers.
#' @export
#'
#' @family {map diagnostic functions}{functions relating to map stress calculation}
#'
tableDistances <- function(map, optimization_number = 1){

  if(numOptimizations(map) == 0){
    stop("This map has no optimizations for which to calculate table distances")
  }
  ac_table_distances(
    titer_table = titerTable(map),
    colbases = colBases(map, optimization_number)
  )

}


#' Return calculated map distances for an acmap
#'
#' Takes the acmap object and calculate distances between antigens and sera for the
#' currently selected or specified optimization.
#'
#' @param map The acmap data object
#' @param optimization_number The optimization data to access (defaults to the currently selected optimization)
#'
#' @return Returns a matrix of map distances with antigens as rows and sera as columns.
#' @export
#'
#' @family {map diagnostic functions}{functions relating to map stress calculation}
#'
mapDistances <- function(map, optimization_number = 1){

  if(numOptimizations(map) == 0){
    stop("This map has no optimizations for which to calculate map distances")
  }

  ac_coordDistMatrix(
    agCoords(map, optimization_number),
    srCoords(map, optimization_number)
  )

}


#' Get the log titers from an acmap
#'
#' @param map The acmap object
#' @param optimization_number The optimization data to access (defaults to the currently selected optimization)
#'
#' @return Returns a list of matrices with the logged titers and whether the titers were discrete, morethan or lessthan.
#' @export
#'
#' @family {map diagnostic functions}{functions relating to map stress calculation}
#'
logtiterTable <- function(map){

  matrix(
    log_titers(titerTable(map)),
    numAntigens(map),
    numSera(map)
  )

}

#' @export
numerictiterTable <- function(map){

  matrix(
    numeric_titers(titerTable(map)),
    numAntigens(map),
    numSera(map)
  )

}

#' @export
titertypesTable <- function(map){

  matrix(
    titer_types_int(titerTable(map)),
    numAntigens(map),
    numSera(map)
  )

}


#' Get a stress table from an acmap
#'
#' @param map The acmap object
#'
#' @return Returns a matrix of stresses, showing how much each antigen and sera
#'   measurement contributes to stress in the selected or specified optimization.
#' @export
#'
#' @family {map diagnostic functions}{functions relating to map stress calculation}
#'
stressTable <- function(map, optimization_number = 1){

  if(numOptimizations(map) == 0){
    stop("This map has no optimizations for which to calculate a stress table")
  }

  table_dist  <- tableDistances(map, optimization_number)
  titer_types <- titerTypesInt(titerTable(map))
  ag_coords   <- agBaseCoords(map, optimization_number)
  sr_coords   <- srBaseCoords(map, optimization_number)

  stress_table <- matrix(NaN, numAntigens(map), numSera(map))
  for(ag in seq_len(numAntigens(map))){
    for(sr in seq_len(numSera(map))){
      stress_table[ag, sr] <- ac_coords_stress(
        tabledist_matrix = table_dist[ag,sr,drop=F],
        titertype_matrix = titer_types[ag,sr,drop=F],
        ag_coords = ag_coords[ag,,drop=F],
        sr_coords = sr_coords[sr,,drop=F]
      )
    }
  }
  stress_table

}


#' Get a table of residuals from an acmap
#'
#' This is the difference between the table distance and the map distance
#'
#' @param map The acmap object
#'
#' @return Returns a matrix of stresses, showing how much each antigen and sera
#'   measurement contributes to stress in the selected or specified optimization.
#' @export
#'
#' @family {map diagnostic functions}{functions relating to map stress calculation}
#'
mapResiduals <- function(
  map,
  exclude_nd          = FALSE,
  optimization_number = 1
){

  if(numOptimizations(map) == 0){
    stop("This map has no optimizations for which to calculate a residual table")
  }

  map_dist    <- mapDistances(map, optimization_number)
  table_dist  <- tableDistances(map, optimization_number)
  titer_types <- titerTypesInt(titerTable(map))

  residuals <- table_dist - map_dist

  if(exclude_nd){
    residuals[map_dist > table_dist & titer_types == 2] <- NA
    residuals[map_dist < table_dist & titer_types == 3] <- NA
  } else {
    residuals[map_dist > table_dist & titer_types == 2] <- 0
    residuals[map_dist < table_dist & titer_types == 3] <- 0
  }

  residuals

}


# Stress ---------------

#' Recalculate the stress associated with an acmap optimization
#'
#' Recalculates the stress associated with the currently selected or user-specifed optimization.
#'
#' @param map The acmap data object
#' @param optimization_number The optimization data to access (defaults to the currently selected optimization)
#'
#' @return Returns the map stress
#'
#' @family {map diagnostic functions}{functions relating to map stress calculation}
#' @seealso See \link{pointStress} for getting the stress of individual points.
#' @export
recalculateStress <- function(map, optimization_number = NULL){
  ac_calcStress(
    ag_coords   = agBaseCoords(map, optimization_number),
    sr_coords   = srBaseCoords(map, optimization_number),
    titer_table = titerTableFlat(map),
    colbases    = colBases(map, optimization_number)
  )
}

#' Get individual point stress
#'
#' Functions to get stress associated with individual points in a map.
#'
#' @param map The acmap data object
#' @param optimization_number The optimization data to access (defaults to the currently selected optimization)
#' @param antigens Which antigens to check stress for, specified by index or name (defaults to all antigens).
#' @param sera Which sera to check stress for, specified by index or name (defaults to all sera).
#'
#' @seealso See \code{\link{mapStress}} for getting the total map stress directly.
#' @family {map diagnostic functions}{functions relating to map stress calculation}
#' @name pointStress
#'

#' @rdname pointStress
#' @export
agStress <- function(
  map,
  antigens            = TRUE,
  optimization_number = 1,
  warnings            = TRUE
){

  # Convert to indices
  antigens <- get_ag_indices(antigens, map, warnings = TRUE)

  # Calculate the stress
  stress_table <- stressTable(map, optimization_number)
  rowSums(stress_table[antigens,])

}

#' @rdname pointStress
#' @export
srStress <- function(
  map,
  sera                = TRUE,
  optimization_number = 1,
  warnings            = TRUE
){

  # Convert to indices
  sera <- get_sr_indices(sera, map, warnings = TRUE)

  # Calculate the stress
  stress_table <- stressTable(map, optimization_number)
  colSums(stress_table[,sera])

}

#' @rdname pointStress
#' @export
srStressPerTiter <- function(
  map,
  sera                = TRUE,
  optimization_number = 1,
  exclude_nd          = TRUE
){

  # Convert to indices
  sera <- get_sr_indices(sera, map, warnings = TRUE)

  # Get map residuals omitting anything that's not a measurable value
  map_residuals <- mapResiduals(
    map                 = map,
    optimization_number = optimization_number,
    exclude_nd          = exclude_nd
  )

  # Calculate the serum likelihood
  vapply(sera, function(serum){

    sr_residuals <- map_residuals[,serum]
    sr_residuals <- sr_residuals[!is.na(sr_residuals)]
    sqrt((sum(sr_residuals^2) / length(sr_residuals)))

  }, numeric(1))

}


#' @rdname pointStress
#' @export
agStressPerTiter <- function(
  map,
  antigens            = TRUE,
  optimization_number = 1,
  exclude_nd          = TRUE
){

  # Convert to indices
  antigens <- get_ag_indices(antigens, map, warnings = TRUE)

  # Get map residuals omitting anything that's not a measurable value
  map_residuals <- mapResiduals(
    map                 = map,
    optimization_number = optimization_number,
    exclude_nd          = exclude_nd
  )

  # Calculate the serum likelihood
  vapply(antigens, function(antigen){

    ag_residuals <- map_residuals[antigen,]
    ag_residuals <- ag_residuals[!is.na(ag_residuals)]
    sqrt((sum(ag_residuals^2) / length(ag_residuals)))

  }, numeric(1))

}




