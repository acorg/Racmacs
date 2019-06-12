
# Apply plotspec from another map
#' @export
applyPlotspec.racmap <- function(map, source_map){

  # Get matching antigens and sera
  ag_matches <- match_mapAntigens(map, source_map, warnings = FALSE)
  sr_matches <- match_mapSera(map, source_map, warnings = FALSE)

  # Match up point indices and pairs
  ag_pt_pairs <- data.frame(
    indices = seq_len(numAntigens(map)),
    matches = ag_matches
  )

  sr_pt_pairs <- data.frame(
    indices = seq_len(numSera(map)),
    matches = sr_matches
  )

  # Discard NAs
  ag_pt_pairs <- ag_pt_pairs[!is.na(ag_pt_pairs$matches),,drop=FALSE]
  sr_pt_pairs <- sr_pt_pairs[!is.na(sr_pt_pairs$matches),,drop=FALSE]
  if(nrow(ag_pt_pairs) == 0 && nrow(sr_pt_pairs) == 0){
    warning("No matching points found in the plotspec source map")
    return(map)
  }

  # Apply styles
  agFill(map)[ag_pt_pairs$indices]         <- agFill(source_map)[ag_pt_pairs$matches]
  agOutline(map)[ag_pt_pairs$indices]      <- agOutline(source_map)[ag_pt_pairs$matches]
  agOutlineWidth(map)[ag_pt_pairs$indices] <- agOutlineWidth(source_map)[ag_pt_pairs$matches]
  agShape(map)[ag_pt_pairs$indices]        <- agShape(source_map)[ag_pt_pairs$matches]
  agSize(map)[ag_pt_pairs$indices]         <- agSize(source_map)[ag_pt_pairs$matches]
  agRotation(map)[ag_pt_pairs$indices]     <- agRotation(source_map)[ag_pt_pairs$matches]
  agAspect(map)[ag_pt_pairs$indices]       <- agAspect(source_map)[ag_pt_pairs$matches]

  srFill(map)[sr_pt_pairs$indices]         <- srFill(source_map)[sr_pt_pairs$matches]
  srOutline(map)[sr_pt_pairs$indices]      <- srOutline(source_map)[sr_pt_pairs$matches]
  srOutlineWidth(map)[sr_pt_pairs$indices] <- srOutlineWidth(source_map)[sr_pt_pairs$matches]
  srShape(map)[sr_pt_pairs$indices]        <- srShape(source_map)[sr_pt_pairs$matches]
  srSize(map)[sr_pt_pairs$indices]         <- srSize(source_map)[sr_pt_pairs$matches]
  srRotation(map)[sr_pt_pairs$indices]     <- srRotation(source_map)[sr_pt_pairs$matches]
  srAspect(map)[sr_pt_pairs$indices]       <- srAspect(source_map)[sr_pt_pairs$matches]

  ## Return the updated map
  map

}

## Antigen and sera fill colors
#' @export
agFill.racmap <- function(racmap){
  racmap$ag_cols_fill
}

#' @export
srFill.racmap <- function(racmap){
  racmap$sr_cols_fill
}

#' @export
set_agFill.racmap <- function(racmap, value){
  racmap$ag_cols_fill <- rep_len(value, numAntigens(racmap))
  racmap
}

#' @export
set_srFill.racmap <- function(racmap, value){
  racmap$sr_cols_fill <- rep_len(value, numSera(racmap))
  racmap
}



## Antigen and sera outline colors
#' @export
agOutline.racmap <- function(racmap){
  racmap$ag_cols_outline
}

#' @export
srOutline.racmap <- function(racmap){
  racmap$sr_cols_outline
}

#' @export
set_agOutline.racmap <- function(racmap, value){
  racmap$ag_cols_outline <- rep_len(value, numAntigens(racmap))
  racmap
}

#' @export
set_srOutline.racmap <- function(racmap, value){
  racmap$sr_cols_outline <- rep_len(value, numSera(racmap))
  racmap
}




## Antigen and sera outline widths
#' @export
agOutlineWidth.racmap <- function(racmap){
  racmap$ag_outline_width
}

#' @export
srOutlineWidth.racmap <- function(racmap){
  racmap$sr_outline_width
}

#' @export
set_agOutlineWidth.racmap <- function(racmap, value){
  racmap$ag_outline_width <- rep_len(value, numAntigens(racmap))
  racmap
}

#' @export
set_srOutlineWidth.racmap <- function(racmap, value){
  racmap$sr_outline_width <- rep_len(value, numSera(racmap))
  racmap
}


## Antigen and sera sizes
#' @export
agSize.racmap <- function(racmap){
  racmap$ag_size
}

#' @export
srSize.racmap <- function(racmap){
  racmap$sr_size
}

#' @export
set_agSize.racmap <- function(racmap, value){
  racmap$ag_size <- rep_len(value, numAntigens(racmap))
  racmap
}

#' @export
set_srSize.racmap <- function(racmap, value){
  racmap$sr_size <- rep_len(value, numSera(racmap))
  racmap
}



## Antigen and sera rotation
#' @export
agRotation.racmap <- function(racmap){
  racmap$ag_rotation
}

#' @export
srRotation.racmap <- function(racmap){
  racmap$sr_rotation
}

#' @export
set_agRotation.racmap <- function(racmap, value){
  racmap$ag_rotation <- rep_len(value, numAntigens(racmap))
  racmap
}

#' @export
set_srRotation.racmap <- function(racmap, value){
  racmap$sr_rotation <- rep_len(value, numSera(racmap))
  racmap
}



## Antigen and sera aspect
#' @export
agAspect.racmap <- function(racmap){
  racmap$ag_aspect
}

#' @export
srAspect.racmap <- function(racmap){
  racmap$sr_aspect
}

#' @export
set_agAspect.racmap <- function(racmap, value){
  racmap$ag_aspect <- rep_len(value, numAntigens(racmap))
  racmap
}

#' @export
set_srAspect.racmap <- function(racmap, value){
  racmap$sr_aspect <- rep_len(value, numSera(racmap))
  racmap
}



## Antigen and sera shapes
#' @export
agShape.racmap <- function(racmap){
  racmap$ag_shape
}

#' @export
srShape.racmap <- function(racmap){
  racmap$sr_shape
}

#' @export
set_agShape.racmap <- function(racmap, value){
  racmap$ag_shape <- rep_len(value, numAntigens(racmap))
  racmap
}

#' @export
set_srShape.racmap <- function(racmap, value){
  racmap$sr_shape <- rep_len(value, numSera(racmap))
  racmap
}


## Antigen and sera visibility
#' @export
agShown.racmap <- function(racmap){
  racmap$ag_shown
}

#' @export
srShown.racmap <- function(racmap){
  racmap$sr_shown
}

#' @export
set_agShown.racmap <- function(racmap, value){
  racmap$ag_shown <- rep_len(value, numAntigens(racmap))
  racmap
}

#' @export
set_srShown.racmap <- function(racmap, value){
  racmap$sr_shown <- rep_len(value, numSera(racmap))
  racmap
}



## Antigen and sera drawing order
#' @export
agDrawingOrder.racmap <- function(racmap){
  if(!is.null(racmap$ag_drawing_order)) {
    return(racmap$ag_drawing_order)
  } else {
    return(seq_len(numAntigens(racmap)))
  }
}

#' @export
srDrawingOrder.racmap <- function(racmap){
  if(!is.null(racmap$sr_drawing_order)) {
    return(racmap$sr_drawing_order)
  } else {
    return(seq_len(numSera(racmap)) + numAntigens(racmap))
  }
}

#' @export
set_agDrawingOrder.racmap <- function(racmap, value){
  racmap$ag_drawing_order <- rep_len(value, numAntigens(racmap))
  racmap
}

#' @export
set_srDrawingOrder.racmap <- function(racmap, value){
  racmap$sr_drawing_order <- rep_len(value, numSera(racmap))
  racmap
}


