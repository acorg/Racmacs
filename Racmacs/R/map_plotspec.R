
#' Apply a plotspec from another acmap
#'
#' Copy point style from matching antigens and sera in another acmap
#'
#' @param map The acmap object
#' @param source_map An acmap object from which to copy point styles
#'
#' @return Returns the acmap object with updated point styles (unmatched point styles unchanged)
#' @export
#'
applyPlotspec <- function(map,
                          source_map){

  UseMethod("applyPlotspec", map)

}


#' Setting point appearance in an antigenic map
#'
#' @param map The map object
#' @param value Value to be used (recycled as necessary)
#' @name mapPlotspec
#'
#' @return Returns an updated racmap object
#'
NULL

checkColor <- function(value){
  col2rgb(value)
  value
}


#' @rdname mapPlotspec
#' @export
agFill <- function(map) {
  UseMethod("agFill", map)
}

#' @rdname mapPlotspec
#' @export
srFill <- function(map) {
  UseMethod("srFill", map)
}

#' @rdname mapPlotspec
#' @export
`agFill<-` <- function(map, value) {
  value <- checkColor(value)
  set_agFill(map, value)
}

set_agFill <- function(map, value) {
  UseMethod("set_agFill", map)
}

#' @rdname mapPlotspec
#' @export
`srFill<-` <- function(map, value) {
  value <- checkColor(value)
  set_srFill(map, value)
}

set_srFill <- function(map, value) {
  UseMethod("set_srFill", map)
}


#' @rdname mapPlotspec
#' @export
agOutline <- function(map) {
  UseMethod("agOutline", map)
}

#' @rdname mapPlotspec
#' @export
srOutline <- function(map) {
  UseMethod("srOutline", map)
}

#' @rdname mapPlotspec
#' @export
`agOutline<-` <- function(map, value) {
  value <- checkColor(value)
  set_agOutline(map, value)
}

set_agOutline <- function(map, value) {
  UseMethod("set_agOutline", map)
}

#' @rdname mapPlotspec
#' @export
`srOutline<-` <- function(map, value) {
  value <- checkColor(value)
  set_srOutline(map, value)
}

set_srOutline <- function(map, value) {
  UseMethod("set_srOutline", map)
}




checkOutlineWidth <- function(value){
  if(mode(value) != "numeric"){
    stop("Point outline widths must be numeric.")
  }
  value
}

#' @rdname mapPlotspec
#' @export
agOutlineWidth <- function(map) {
  UseMethod("agOutlineWidth", map)
}

#' @rdname mapPlotspec
#' @export
srOutlineWidth <- function(map) {
  UseMethod("srOutlineWidth", map)
}

#' @rdname mapPlotspec
#' @export
`agOutlineWidth<-` <- function(map, value) {
  value <- checkOutlineWidth(value)
  set_agOutlineWidth(map, value)
}

set_agOutlineWidth <- function(map, value) {
  UseMethod("set_agOutlineWidth", map)
}

#' @rdname mapPlotspec
#' @export
`srOutlineWidth<-` <- function(map, value) {
  value <- checkOutlineWidth(value)
  set_srOutlineWidth(map, value)
}

set_srOutlineWidth <- function(map, value) {
  UseMethod("set_srOutlineWidth", map)
}




checkSize <- function(value){
  if(mode(value) != "numeric"){
    stop("Point sizes must be numeric.")
  }
  value
}

#' @rdname mapPlotspec
#' @export
agSize <- function(map) {
  UseMethod("agSize", map)
}

#' @rdname mapPlotspec
#' @export
srSize <- function(map) {
  UseMethod("srSize", map)
}

#' @rdname mapPlotspec
#' @export
`agSize<-` <- function(map, value) {
  value <- checkSize(value)
  set_agSize(map, value)
}

set_agSize <- function(map, value) {
  UseMethod("set_agSize", map)
}

#' @rdname mapPlotspec
#' @export
`srSize<-` <- function(map, value) {
  value <- checkSize(value)
  set_srSize(map, value)
}

set_srSize <- function(map, value) {
  UseMethod("set_srSize", map)
}



## Point rotation
checkRotation <- function(value){
  if(mode(value) != "numeric"){
    stop("Point rotation must be numeric.")
  }
  value
}

#' @rdname mapPlotspec
#' @export
agRotation <- function(map) {
  UseMethod("agRotation", map)
}

#' @rdname mapPlotspec
#' @export
srRotation <- function(map) {
  UseMethod("srRotation", map)
}

#' @rdname mapPlotspec
#' @export
`agRotation<-` <- function(map, value) {
  value <- checkRotation(value)
  set_agRotation(map, value)
}

set_agRotation <- function(map, value) {
  UseMethod("set_agRotation", map)
}

#' @rdname mapPlotspec
#' @export
`srRotation<-` <- function(map, value) {
  value <- checkRotation(value)
  set_srRotation(map, value)
}

set_srRotation <- function(map, value) {
  UseMethod("set_srRotation", map)
}


## Point aspect
checkAspect <- function(value){
  if(mode(value) != "numeric"){
    stop("Point aspect must be numeric.")
  }
  value
}

#' @rdname mapPlotspec
#' @export
agAspect <- function(map) {
  UseMethod("agAspect", map)
}

#' @rdname mapPlotspec
#' @export
srAspect <- function(map) {
  UseMethod("srAspect", map)
}

#' @rdname mapPlotspec
#' @export
`agAspect<-` <- function(map, value) {
  value <- checkAspect(value)
  set_agAspect(map, value)
}

set_agAspect <- function(map, value) {
  UseMethod("set_agAspect", map)
}

#' @rdname mapPlotspec
#' @export
`srAspect<-` <- function(map, value) {
  value <- checkAspect(value)
  set_srAspect(map, value)
}

set_srAspect <- function(map, value) {
  UseMethod("set_srAspect", map)
}



checkShape <- function(value){
  value <- toupper(value)
  supported_shapes <- c("BOX", "CIRCLE", "TRIANGLE")
  if(sum(!value %in% supported_shapes) > 0){
    stop("Point shapes must be one of ", paste(supported_shapes, collapse = ", "), ".")
  }
  value
}

#' @rdname mapPlotspec
#' @export
agShape <- function(map) {
  UseMethod("agShape", map)
}

#' @rdname mapPlotspec
#' @export
srShape <- function(map) {
  UseMethod("srShape", map)
}

#' @rdname mapPlotspec
#' @export
`agShape<-` <- function(map, value) {
  value <- checkShape(value)
  set_agShape(map, value)
}

set_agShape <- function(map, value){
  UseMethod("set_agShape", map)
}

#' @rdname mapPlotspec
#' @export
`srShape<-` <- function(map, value) {
  value <- checkShape(value)
  set_srShape(map, value)
}

set_srShape <- function(map, value){
  UseMethod("set_srShape", map)
}


# Antigen and sera visibility
checkShown <- function(value){
  as.logical(value)
}

#' @rdname mapPlotspec
#' @export
agShown <- function(map) {
  UseMethod("agShown", map)
}

#' @rdname mapPlotspec
#' @export
srShown <- function(map) {
  UseMethod("srShown", map)
}

#' @rdname mapPlotspec
#' @export
`agShown<-` <- function(map, value) {
  value <- checkShown(value)
  set_agShown(map, value)
}

set_agShown <- function(map, value){
  UseMethod("set_agShown", map)
}

#' @rdname mapPlotspec
#' @export
`srShown<-` <- function(map, value) {
  value <- checkShown(value)
  set_srShown(map, value)
}

set_srShown <- function(map, value){
  UseMethod("set_srShown", map)
}



# Antigen and sera drawing order
checkDrawingOrder <- function(value){
  as.numeric(value)
}

#' @rdname mapPlotspec
#' @export
agDrawingOrder <- function(map) {
  UseMethod("agDrawingOrder", map)
}

#' @rdname mapPlotspec
#' @export
srDrawingOrder <- function(map) {
  UseMethod("srDrawingOrder", map)
}

#' @rdname mapPlotspec
#' @export
`agDrawingOrder<-` <- function(map, value) {
  value <- checkDrawingOrder(value)
  set_agDrawingOrder(map, value)
}

set_agDrawingOrder <- function(map, value){
  UseMethod("set_agDrawingOrder", map)
}

#' @rdname mapPlotspec
#' @export
`srDrawingOrder<-` <- function(map, value) {
  value <- checkDrawingOrder(value)
  set_srDrawingOrder(map, value)
}

set_srDrawingOrder <- function(map, value){
  UseMethod("set_srDrawingOrder", map)
}


#' @rdname mapPlotspec
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


# #' Match plotting styles for map data
# #'
# #' Match the plotting styles for two map data objects.
# #'
# #' @param orig_mapData The map data object to be updated.
# #' @param ref_mapData The map data object from which values will be taken
# #'
# #' @return Returns an updated map data object
# #' @export
# #'
# match_plotspecData <- function(mapData,
#                                ref_mapData){
#
#   # Match up antigens
#   ag_match <- match(mapData$ag_names, ref_mapData$ag_names)
#   sr_match <- match(mapData$sr_names, ref_mapData$sr_names)
#
#   # Issue a message about those antigens and sera not found in the reference map
#   if(sum(is.na(ag_match) > 0)){
#     message('\nOriginal style values have been kept for the following antigens since no matches were found:\n\n"',
#             paste(mapData$ag_names[is.na(ag_match)], collapse = '"\n"'), '"\n')
#   }
#   if(sum(is.na(sr_match) > 0)){
#     message('\nOriginal style values have been kept for the following sera since no matches were found:\n\n"',
#             paste(mapData$sr_names[is.na(sr_match)], collapse = '"\n"'), '"\n')
#   }
#
#   # Set point styles
#   point_styles <- c("aspect",
#                     "cols_fill",
#                     "shown",
#                     "cols_outline",
#                     "outline_width",
#                     "rotation",
#                     "shape",
#                     "size")
#
#   ag_point_styles <- paste0("ag_", point_styles)
#   sr_point_styles <- paste0("sr_", point_styles)
#
#
#   # Write new map data
#   assign_attributes <- function(map_attribute,
#                                 attribute_match){
#
#     # Get the original value
#     orig_val <- mapData[[map_attribute]]
#
#     # Assign the new values
#     new_val  <- ref_mapData[[map_attribute]][attribute_match]
#
#     # Replace any NA matches with the original values
#     new_val[is.na(attribute_match)] <- orig_val[is.na(attribute_match)]
#
#     # Assign the new values to map data
#     mapData[[map_attribute]] <- new_val
#
#     # Overwrite the map data outside the function
#     assign("mapData", mapData, envir = parent.env(environment()))
#
#   }
#
#   lapply(ag_point_styles, assign_attributes, attribute_match = ag_match)
#   lapply(sr_point_styles, assign_attributes, attribute_match = sr_match)
#
#   # Return the new map data
#   mapData
#
# }




