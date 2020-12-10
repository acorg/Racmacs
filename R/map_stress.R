
convert_titers <- function(titers){
  titers[is.na(titers)] <- "*"
  mode(titers) <- "character"
  titers
}

#' @export
tableColbases <- function(
  titer_table,
  min_col_basis
  ){

  ac_table_colbases(
    titer_table   = convert_titers(titer_table),
    min_col_basis = min_col_basis
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
mapDistances <- function(map, optimization_number = NULL){

  if(numOptimizations(map) == 0){
    stop("This map has no optimizations for which to calculate map distances")
  }

  distances <- ac_mapDists(agCoords(map, optimization_number), srCoords(map, optimization_number))
  rownames(distances) <- agNames(map)
  colnames(distances) <- srNames(map)
  distances

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
stressTable <- function(map, optimization_number = NULL){

  if(numOptimizations(map) == 0){
    stop("This map has no optimizations for which to calculate a stress table")
  }

  map_dist     <- mapDistances(map, optimization_number)
  table_dist   <- tableDistances(map, optimization_number)

  stress_table <- map_dist
  stress_table[] <- vapply(
    seq_along(map_dist),
    function(x){
      ac_calculate_stress(map_dist   = map_dist[x],
                          table_dist = table_dist$distances[x],
                          lessthans  = table_dist$lessthans[x],
                          morethans  = table_dist$morethans[x])
    },
    numeric(1)
  )

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
  optimization_number = NULL
){

  if(numOptimizations(map) == 0){
    stop("This map has no optimizations for which to calculate a residual table")
  }

  map_dist    <- mapDistances(map, optimization_number)
  table_dist  <- tableDistances(map, optimization_number)$distances
  titer_types <- titerTypes(map)

  residuals <- table_dist - map_dist

  if(exclude_nd){
    residuals[map_dist > table_dist & titer_types == "lessthan"] <- NA
    residuals[map_dist < table_dist & titer_types == "morethan"] <- NA
  } else {
    residuals[map_dist > table_dist & titer_types == "lessthan"] <- 0
    residuals[map_dist < table_dist & titer_types == "morethan"] <- 0
  }

  residuals

}

