
# apply(list_property_function_bindings("sera"), 1, function(x){
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



seraSetterFunction <- function(attribute){

  setter <- function(map, value){
    UseMethod(paste0("set_", attribute), map)
  }

  function(map, value){
    setter(map, value)
  }

}


#  Sera names  -------

#' @rdname mapStrains
#' @export
srNames <- function(map) UseMethod('srNames')

#' @rdname mapStrains
#' @export
`srNames<-` <- antigenSetterFunction('srNames')
set_srNames <- function(map, value) UseMethod('set_srNames')




#  Full sera names  -------

#' @rdname mapStrains
#' @export
srNamesFull <- function(map) UseMethod('srNamesFull')

#' @rdname mapStrains
#' @export
`srNamesFull<-` <- function(map, value) stop("Setting of full serum names is not supported, set serum names instead.", call. = FALSE)




#  Abbreviated sera names  -------

#' @rdname mapStrains
#' @export
srNamesAbbreviated <- function(map) UseMethod('srNamesAbbreviated')

#' @rdname mapStrains
#' @export
`srNamesAbbreviated<-` <-  function(map, value) stop("Setting of abbreviated serum names is not supported, set serum names instead.", call. = FALSE)


