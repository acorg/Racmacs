
#' Convert map to json format
#'
#' @param map The map data object
#'
#' @return Returns map data as .ace json format
#' @family {functions for working with map data}
#' @export
#'
as.json <- function(map){

  acmap_to_json(
    map = map,
    version = paste0("racmacs-ace-v", packageVersion("Racmacs"))
  )

}



