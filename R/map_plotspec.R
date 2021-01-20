
#' Apply a plotspec from another acmap
#'
#' Copy point style from matching antigens and sera in another acmap
#'
#' @param map The acmap object
#' @param source_map An acmap object from which to copy point styles
#'
#' @return Returns the acmap object with updated point styles (unmatched point styles unchanged)
#' @export
#' @family {map point style functions}
#'
applyPlotspec <- function(
  map,
  source_map
  ){

  ag_match <- match_mapAntigens(map, source_map)
  sr_match <- match_mapSera(map, source_map)

  for(method in plotspec_methods){
    if(substr(method, 1, 2) == "ag") pt_match <- ag_match
    else                             pt_match <- sr_match
    getter     <- get(method)
    `getter<-` <- get(paste0(method, "<-"))
    getter(map)[!is.na(pt_match)] <- getter(source_map)[pt_match[!is.na(pt_match)]]
  }

  map

}


