
## Antigen and sera names -------
#' @export
srNames.racmap <- function(map){
  map$sr_names
}

#' @export
set_srNames.racmap <- function(map, value){
  map$sr_names            <- value
  map$sr_full_name        <- value
  map$sr_abbreviated_name <- value
  if(!is.null(map$table))     colnames(map$table)     <- value
  if(!is.null(map$sr_coords)) rownames(map$sr_coords) <- value
  if(!is.null(map$colbases))  names(map$colbases)     <- value
  if(!is.null(map$optimizations)) {
    map$optimizations <- lapply(map$optimizations, function(optimization){
      if(!is.null(optimization$sr_coords)) rownames(optimization$sr_coords) <- value
      if(!is.null(optimization$colbases))  names(optimization$colbases)     <- value
      optimization
    })
  }
  map
}



## Antigen and sera full names -------
#' @export
srNamesFull.racmap <- function(map){
  map$sr_full_name
}

#' @export
set_srNamesFull.racmap <- function(map, value){
  map$sr_full_name <- value
  map
}




## Antigen and sera abbreviated names -------
#' @export
srNamesAbbreviated.racmap <- function(map){
  map$sr_abbreviated_name
}

#' @export
set_srNamesAbbreviated.racmap <- function(map, value){
  map$sr_abbreviated_name <- value
  map
}




## Antigen and sera dates -------
#' @export
srDates.racmap <- function(map){
  map$sr_date
}

#' @export
set_srDates.racmap <- function(map, value){
  map$sr_date <- as.Date(value, format = "%Y-%m-%d")
  map
}

