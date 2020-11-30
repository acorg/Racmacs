
#' Getting and setting map titers
#'
#' Functions to get and set the map titer table.
#'
#' @name titerTable
#' @family {map attribute functions}
#'

#' @export
#' @rdname titerTable
titerTable <- function(map){

  titers <- titerTableFlat(map)
  rownames(titers) <- agNames(map)
  colnames(titers) <- srNames(map)
  titers

}


#' @export
#' @rdname titerTable
`titerTable<-` <- function(map, value){

  # Set the flat titer table
  titerTableFlat(map) <- value

  # Set the titer table layers
  titerTableLayers(map) <- list(value)

  # Return the map
  map

}


#' @noRd
titerTableFlat <- function(map){
  map$titer_table_flat
}

#' @noRd
`titerTableFlat<-` <- function(map, value){
  if(is.data.frame(value)) value <- as.matrix(value)
  mode(value)        <- "character"
  map$titer_table_flat <- value
  map
}




