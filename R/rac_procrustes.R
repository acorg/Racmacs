
#' Calculate a procrustes object
#'
#' @param source_coords Source coordinates.
#' @param target_coords Target coordinates.
#' @param translation Should translation be applied?
#' @param scaling Should scaling be applied?
#' @param dim_match Should automatic dimension matching be done?
#'
#' @return Returns a procrustes object.
#' @noRd
#' @export
calc_procrustes <- function(source_coords,
                            target_coords,
                            translation = TRUE,
                            scaling     = FALSE,
                            dim_match   = TRUE){

  # Remove NAs
  na_coords <- apply(!is.na(source_coords), 1, sum) == 0 | apply(!is.na(target_coords), 1, sum) == 0

  # Match the number of dimensions
  if(dim_match){
    while(ncol(source_coords) < ncol(target_coords)){ source_coords <- cbind(source_coords,0) }
    while(ncol(target_coords) < ncol(source_coords)){ target_coords <- cbind(target_coords,0) }
  }

  # Get MCMC result
  result <- MCMCpack::procrustes(X           = source_coords[!na_coords,,drop=FALSE],
                                 Xstar       = target_coords[!na_coords,,drop=FALSE],
                                 dilation    = scaling,
                                 translation = translation)

  # Set up a procrustes object
  pc_object <- list()
  pc_object$translation <- t(result$tt)
  pc_object$rotation    <- result$R
  pc_object$scaling     <- result$s
  pc_object

}



#' Apply a procrustes object
#'
#' @param coords Coordinates to be rotated.
#' @param pc_object Procrustes object to be applied.
#'
#' @return Returns the coordinates with the procrustes transformation applied
#'
#' @noRd
#' @export
#'
apply_procrustes <- function(coords,
                             pc_object,
                             dim_match    = TRUE,
                             rotate2Dto3D = FALSE){

  # Match up dimensions if requested
  if(rotate2Dto3D){
    while(ncol(coords) < ncol(pc_object$rotation)){
      coords <- cbind(coords, 0)
    }
  }

  dim_pc     <- nrow(pc_object$rotation)
  dim_coords <- ncol(coords)
  if(dim_match && dim_pc != dim_coords){

    if(dim_coords < dim_pc){
      rotation    <- convert3Dto2DrotationMatrix(pc_object$rotation)
      translation <- pc_object$translation[1:dim_coords]
    }

    if(dim_coords > dim_pc){
      rotation <- diag(dim_coords)
      translation <- rep(0, dim_coords)

      rotation[1:dim_pc, 1:dim_pc] <- pc_object$rotation
      translation[1:dim_pc]        <- pc_object$translation
    }

    pc_object$rotation    <- rotation
    pc_object$translation <- translation

  }

  if(ncol(coords) != ncol(pc_object$rotation))      { stop("Procrustes rotation and coordinate dimensions do not match")    }
  if(ncol(coords) != length(pc_object$translation)) { stop("Procrustes translation and coordinate dimensions do not match") }

  # Apply the procrustes
  new_coords <- coords*pc_object$scaling
  new_coords <- new_coords %*% pc_object$rotation
  new_coords <- new_coords + matrix(pc_object$translation, nrow(new_coords), ncol(new_coords), byrow = TRUE)

  # Return new coords
  new_coords

}








