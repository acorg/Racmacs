

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
#' @family functions relating to map stress calculation
#'
tableDistances <- function(map, optimization_number = NULL){

  if(numOptimizations(map) == 0){
    stop("This map has no optimizations for which to calculate table distances")
  }
  ac_tableDists(
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
#' @family functions relating to map stress calculation
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
#' @family functions relating to map stress calculation
#'
logtiterTable <- function(map){

  titers <- titerTable(map)
  convert2log(titers)

}


#' Get a stress table from an acmap
#'
#' @param map The acmap object
#'
#' @return Returns a matrix of stresses, showing how much each antigen and sera
#'   measurement contributes to stress in the selected or specified optimization.
#' @export
#'
#' @family functions relating to map stress calculation
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

