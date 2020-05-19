
#' Apply the current map transformation
#'
#' Applies the current map transformation to a set of coordinates
#'
#' @param coords Coordinates to transform
#' @param map The acmap object
#' @param optimization_number The optimization number (by default the selected one)
#'
#' @family {functions relating to map transformation}
#' @export
#'
applyMapTransform <- function(
  coords,
  map,
  optimization_number = NULL
){

  # Transform the coordinates
  coords <- transform_coords(
    coords         = coords,
    transformation = mapTransformation(map, optimization_number)
  )

  # Translate the coordinates
  coords <- translate_coords(
    coords         = coords,
    translation    = mapTranslation(map, optimization_number)
  )

  # Return coords
  coords

}


#' Scale a map
#'
#' Scales map coordinates
#'
#' @param map The acmap object
#' @param scaling Scaling to apply
#' @param optimization_number The optimization number (by default the selected one)
#'
#' @family {functions relating to map transformation}
#' @export
#'
scaleMap <- function(map, scaling, optimization_number = NULL) {

  # Scale the map
  mapTransformation(map, optimization_number) <- mapTransformation(map, optimization_number)*scaling

  # And don't forget to scale any translations
  mapTranslation(map, optimization_number) <- mapTranslation(map, optimization_number)*scaling

  # Return the map
  map

}


#' Transform a map
#'
#' Transforms map coordinates
#'
#' @param map The acmap object
#' @param transformation_matrix Transformation to apply (as matrix)
#' @param optimization_number The optimization number (by default the selected one)
#'
#' @family {functions relating to map transformation}
#' @export
#'
transformMap <- function(
  map,
  transformation_matrix,
  optimization_number = NULL
) {

  # Get ndims of transformation_matrix
  numdims <- ncol(transformation_matrix)

  # Transform the translation
  mapTranslation(map, optimization_number) <- transform_translation(
    translate      = mapTranslation(map, optimization_number),
    transformation = transformation_matrix
  )

  # Set the map transformation matrix
  mapTransformation(map, optimization_number) <- transform_transformation(
    transform      = mapTransformation(map, optimization_number),
    transformation = transformation_matrix
  )

  # Return the map
  map

}


#' Translate a map
#'
#' Translates map coordinates
#'
#' @param map The acmap object
#' @param translation Translation to apply (as vector)
#' @param optimization_number The optimization number (by default the selected one)
#'
#' @family {functions relating to map transformation}
#' @export
#'
translateMap <- function(map, translation, optimization_number = NULL) {

  # Set the translation
  mapTranslation(map, optimization_number) <- translate_translation(
    translate   = mapTranslation(map, optimization_number),
    translation = translation
  )

  # Return the map
  map

}


#' Reflect a map
#'
#' Reflects map coordinates
#'
#' @param map The acmap object
#' @param axis Axis of reflection
#' @param optimization_number The optimization number (by default the selected one)
#'
#' @family {functions relating to map transformation}
#' @export
#'
reflectMap <- function(map, axis = "x", optimization_number = NULL) {

  # Work out the transformation matrix
  axis_num <- match(axis, c("x", "y", "z"))
  transformation_matrix <- diag(-1, nrow = mapDimensions(map, optimization_number))
  transformation_matrix[axis_num, axis_num] <- 1

  # Here we can simply apply the translation
  transformMap(map, transformation_matrix, optimization_number)

}

#' Rotate a map
#'
#' Apply a rotation to an antigenic map
#'
#' @param map The acmap object
#' @param degrees Degrees of rotation
#' @param axis Axis of rotation (if 3D)
#' @param optimization_number The optimization number (by default the selected one)
#'
#' @family {functions relating to map transformation}
#' @export
#'
rotateMap <- function(map, degrees, axis = NULL, optimization_number = NULL) {

  # Check the rotation
  if(mapDimensions(map, optimization_number) == 3 && is.null(axis)) stop("Rotation axis must be specified for 3D rotations as either 'x', 'y' or 'z'.")

  # Convert to radians
  radians <- pi*(degrees / 180)

  # Get the rotation matrix
  if(mapDimensions(map, optimization_number) == 2){
    transformation_matrix <- rotation_matrix_2D(radians)
  } else {
    transformation_matrix <- rotation_matrix_3D(radians, axis)
  }

  # Apply the transformation
  transformMap(map, transformation_matrix, optimization_number)

}


# Transformations
transform_coords <- function(transformation, coords){

  max_dim <- max(ncol(transformation), ncol(coords))
  coords         <- set_coord_dims(coords, max_dim)
  transformation <- set_transformation_dims(transformation, max_dim)
  coords %*% transformation

}

transform_transformation <- function(transform, transformation){

  max_dim <- max(ncol(transform), ncol(transformation))
  transform      <- set_transformation_dims(transform, max_dim)
  transformation <- set_transformation_dims(transformation, max_dim)
  transform %*% transformation

}

transform_translation <- function(translate, transformation){

  max_dim <- max(length(translate), ncol(transformation))
  translate    <- set_translation_dims(translate, max_dim)
  transformation <- set_transformation_dims(transformation, max_dim)
  translate %*% transformation

}


# Translations
translate_coords <- function(coords, translation){

  max_dim <- max(ncol(coords), length(translation))
  translation <- set_translation_dims(translation, max_dim)
  coords      <- set_coord_dims(coords, max_dim)
  coords + matrix(
    translation,
    nrow  = nrow(coords),
    ncol  = ncol(coords),
    byrow = TRUE
  )

}

translate_translation <- function(translate, translation){

  max_dim <- max(length(translate), length(translation))
  translate      <- set_translation_dims(translate, max_dim)
  translation    <- set_translation_dims(translation, max_dim)
  translate + translation

}


# Setting dimensions
set_transformation_dims <- function(transformation, dimensions){
  new_transform <- diag(nrow = dimensions)
  new_transform[
    seq_len(nrow(transformation)),
    seq_len(ncol(transformation))
  ] <- transformation
  new_transform
}

set_coord_dims <- function(coords, dimensions){
  while(ncol(coords) < dimensions) coords <- cbind(coords, 0)
  coords
}

set_translation_dims <- function(translation, dimensions){
  translation <- matrix(translation, nrow = 1)
  while(ncol(translation) < dimensions) translation <- cbind(translation, 0)
  translation
}
