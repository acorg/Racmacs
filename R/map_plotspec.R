
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
applyPlotspec <- function(map,
                          source_map){

  ag_match <- match_mapAntigens(map, source_map, warnings = FALSE)
  sr_match <- match_mapSera(map, source_map, warnings = FALSE)

  plotspec_methods <- list_property_function_bindings("plotspec")$method
  for(method in plotspec_methods){
    if(!method %in% c("agDrawingOrder", "srDrawingOrder") || !"racchart" %in% class(map)){
      if(substr(method, 1, 2) == "ag") pt_match <- ag_match
      else                             pt_match <- sr_match
      getter     <- get(method)
      `getter<-` <- get(paste0(method, "<-"))
      getter(map)[!is.na(pt_match)] <- getter(source_map)[pt_match[!is.na(pt_match)]]
    }
  }

  map

}


#' @export
mapPoints <- function(map, optimization_number = NULL){

  list(
    type          = c(rep("ag", numAntigens(map)), rep("sr", numSera(map))),
    coords        = rbind(agCoords(map, optimization_number), srCoords(map, optimization_number)),
    shown         = c(agShown(map), srShown(map)),
    size          = c(agSize(map), srSize(map)),
    fill          = c(agFill(map), srFill(map)),
    outline       = c(agOutline(map), srOutline(map)),
    outline_width = c(agOutlineWidth(map), srOutlineWidth(map)),
    rotation      = c(agRotation(map), srRotation(map)),
    aspect        = c(agAspect(map), srAspect(map)),
    shape         = c(agShape(map), srShape(map)),
    drawing_order = c(agDrawingOrder(map), srDrawingOrder(map))
  )

}







