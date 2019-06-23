
# apply(list_property_function_bindings("antigens"), 1, function(x){
#
#   cat("# ", x["description"]," -------")
#   cat("\n\n")
#
#   #cat("#' @rdname mapStrains\n")
#   cat("#' @export\n")
#   cat(x[2], ".racmap <- antigenGetterFunction('", x[2],"')\n\n", sep = "")
#
#   #cat("#' @rdname mapStrains\n")
#   cat("#' @export\n")
#   cat("set_", x[2], ".racmap <- antigenSetterFunction('", x[2],"')\n\n", sep = "")
#
#   cat("\n\n")
#
# })

## Antigen and sera names -------
#' @export
agNames.racmap <- function(map){
  map$ag_names
}

#' @export
set_agNames.racmap <- function(map, value){
  map$ag_names            <- value
  map$ag_full_name        <- value
  map$ag_abbreviated_name <- value
  if(!is.null(map$table))     rownames(map$table)     <- value
  if(!is.null(map$ag_coords)) rownames(map$ag_coords) <- value
  if(!is.null(map$optimizations)) {
    map$optimizations <- lapply(map$optimizations, function(optimization){
      if(!is.null(optimization$ag_coords)) rownames(optimization$ag_coords) <- value
      optimization
    })
  }
  map
}



## Antigen and sera full names -------
#' @export
agNamesFull.racmap <- function(map){
  map$ag_full_name
}

#' @export
set_agNamesFull.racmap <- function(map, value){
  map$ag_full_name <- value
  map
}



## Antigen and sera abbreviated names -------
#' @export
agNamesAbbreviated.racmap <- function(map){
  map$ag_abbreviated_name
}

#' @export
set_agNamesAbbreviated.racmap <- function(map, value){
  map$ag_abbreviated_name <- value
  map
}



## Antigen and sera dates -------
#' @export
agDates.racmap <- function(map){
  map$ag_dates
}

#' @export
set_agDates.racmap <- function(map, value){
  map$ag_dates <- as.Date(value, format = "%Y-%m-%d")
  map
}

