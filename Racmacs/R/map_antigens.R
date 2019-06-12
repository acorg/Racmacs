
# apply(list_property_function_bindings("antigens"), 1, function(x){
#
#   cat("# ", x["description"]," -------")
#   cat("\n\n")
#
#   cat("#' @rdname mapStrains\n")
#   cat("#' @export\n")
#   cat(x[2], " <- function(map) UseMethod('", x[2],"')\n\n", sep = "")
#
#   cat("#' @rdname mapStrains\n")
#   cat("#' @export\n")
#   cat("`", x[2], "<-` <- antigenSetterFunction('", x[2],"')\n", sep = "")
#
#   cat("set_", x[2], " <- function(map, value) UseMethod('set_", x[2],"')\n\n", sep = "")
#
#   cat("\n\n\n")
#
# })

#' Strains in an antigenic map
#'
#' @param map The map object
#' @param value Value to be used (recycled as necessary)
#' @name mapStrains
#'
#' @return Returns an updated racmap object
#'
NULL


antigenSetterFunction <- function(attribute){

  setter <- function(map, value){
    UseMethod(paste0("set_", attribute), map)
  }

  function(map, value){
    setter(map, value)
  }

}


#  Antigen names  -------

#' @rdname mapStrains
#' @export
agNames <- function(map) UseMethod('agNames')

#' @rdname mapStrains
#' @export
`agNames<-` <- antigenSetterFunction('agNames')
set_agNames <- function(map, value) UseMethod('set_agNames')




#  Full antigen names  -------

#' @rdname mapStrains
#' @export
agNamesFull <- function(map) UseMethod('agNamesFull')

#' @rdname mapStrains
#' @export
`agNamesFull<-` <- function(map, value) stop("Setting of full antigen names is not supported, set antigen names instead.", call. = FALSE)




#  Abbreviated antigen names  -------

#' @rdname mapStrains
#' @export
agNamesAbbreviated <- function(map) UseMethod('agNamesAbbreviated')

#' @rdname mapStrains
#' @export
`agNamesAbbreviated<-` <- function(map, value) stop("Setting of abbreviated antigen names is not supported, set antigen names instead.", call. = FALSE)




#  Antigen dates  -------

#' @rdname mapStrains
#' @export
agDates <- function(map) UseMethod('agDates')

#' @rdname mapStrains
#' @export
`agDates<-` <- antigenSetterFunction('agDates')
set_agDates <- function(map, value) UseMethod('set_agDates')




#  Is antigen a reference virus  -------

#' @rdname mapStrains
#' @export
agReference <- function(map) UseMethod('agReference')

#' @rdname mapStrains
#' @export
`agReference<-` <- antigenSetterFunction('agReference')
set_agReference <- function(map, value) UseMethod('set_agReference')

