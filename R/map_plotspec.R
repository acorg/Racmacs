
#' Apply a plotspec from another acmap
#'
#' Copy point style from matching antigens and sera in another acmap
#'
#' @param map The acmap object
#' @param source_map An acmap object from which to copy point styles
#'
#' @returns Returns the acmap object with updated point styles (unmatched point
#'   styles unchanged)
#' @export
#' @family map point style functions
#'
applyPlotspec <- function(
  map,
  source_map
  ) {

  ag_match <- match_mapAntigens(map, source_map)
  sr_match <- match_mapSera(map, source_map)

  for (i in which(!is.na(ag_match))) {
    map$antigens[[i]]$plotspec <- source_map$antigens[[ag_match[i]]]$plotspec
  }
  for (i in which(!is.na(sr_match))) {
    map$sera[[i]]$plotspec <- source_map$sera[[sr_match[i]]]$plotspec
  }

  map

}
