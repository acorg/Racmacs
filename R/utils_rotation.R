
#' Translate a set of coordinates
#' @noRd
translate_coords <- function(coords, translation) {

  while (length(translation) < ncol(coords)) translation <- c(translation, 0)
  while (ncol(coords) < length(translation)) coords <- cbind(coords, 0)

  translation <- matrix(
    translation,
    nrow = nrow(coords),
    ncol = ncol(coords),
    byrow = T
  )

  coords + translation

}

#' Rotate a set of coordinates
#' @noRd
rotate_coords_by_radians <- function(coords, radians, axis = NULL) {

  if (ncol(coords) == 2) {
    rotation_matrix <- rotation_matrix_2D(radians)
  } else if (ncol(coords) == 3) {
    if (is.null(axis)) {
      stop(
        strwrap("Rotation axis must be specified for 3D rotations
                as either 'x', 'y' or 'z'."),
        call. = FALSE
      )
    }
    rotation_matrix <- rotation_matrix_3D(radians, axis)
  } else {
    stop("Coordinates must be 2 or 3 dimensions.")
  }
  coords %*% rotation_matrix

}

#' Rotate a set of coordinates
#' @noRd
rotate_coords_by_degrees <- function(coords, degrees, axis = NULL) {
  rotate_coords_by_radians(coords, pi * (degrees / 180), axis)
}


#' Generate a 2 dimensional rotation matrix
#' @noRd
rotation_matrix_2D <- function(radians) {

  matrix(c(cos(radians), sin(radians), -sin(radians), cos(radians)), 2, 2)

}


#' Generate a 3 dimensional rotation matrix
#' @noRd
rotation_matrix_3D <- function(radians, axis = "z") {

  if (axis == "x") {
    rotmat <- rbind(
      c(1, 0, 0),
      c(0, cos(radians), -sin(radians)),
      c(0, sin(radians), cos(radians))
    )
  }

  if (axis == "y") {
    rotmat <- rbind(
      c(cos(radians), 0, sin(radians)),
      c(0, 1, 0),
      c(-sin(radians), 0, cos(radians))
    )
  }

  if (axis == "z") {
    rotmat <- rbind(
      c(cos(radians), -sin(radians), 0),
      c(sin(radians), cos(radians), 0),
      c(0, 0, 1)
    )
  }

  # Return the matrix
  rotmat

}


#' Reflect coordinates
#' @noRd
reflect_coords_in_axis <- function(coords, axis) {

  dimensions <- ncol(coords)
  if (!dimensions %in% 2:3) {
    stop(
      "Reflection is only supported for coordinates of 2 or 3 dimensions.",
      call. = FALSE
    )
  }
  if (missing(axis)) {
    stop("Reflection axis must be provided.", call. = FALSE)
  }
  if (dimensions == 2 && axis == "z") {
    stop("Axis must be one of 'x' or 'y'.", call. = FALSE)
  }
  if (!axis %in% c("x", "y", "z")) {
    stop("Invalid reflection axis provided.", call. = FALSE)
  }

  reflection_matrix <- diag(dimensions) * -1
  if (axis == "x") reflection_matrix[1, 1] <- 1
  if (axis == "y") reflection_matrix[2, 2] <- 1
  if (axis == "z") reflection_matrix[3, 3] <- 1

  coords %*% reflection_matrix

}


# Clamp a value between limits
clamp <- function(value, min, max) {

  max(min, min(max, value))

}

# Get euler angles from a rotation matrix
eulerFromMatrix <- function(mat) {

  euler <- list(x = 0, y = 0, z = 0)
  mat4 <- matrix(nrow = 4, ncol = 4)
  mat4[1:3, 1:3] <- mat

  m11 <- mat4[1]; m12 <- mat4[5]; m13 <- mat4[9]
  m21 <- mat4[2]; m22 <- mat4[6]; m23 <- mat4[10]
  m31 <- mat4[3]; m32 <- mat4[7]; m33 <- mat4[11]

  euler$y <- asin(clamp(m13, -1, 1))

  if (abs(m13) < 0.99999) {

    euler$x <- atan2(-m23, m33)
    euler$z <- atan2(-m12, m11)

  } else {

    euler$x <- atan2(m32, m22)
    euler$z <- 0

  }

  euler

}

# Make matrix from euler angles
matrixFromEuler <- function(euler) {

  mat <- diag(4)

  x <- euler$x; y <- euler$y; z <- euler$z
  a <- cos(x); b <- sin(x)
  c <- cos(y); d <- sin(y)
  e <- cos(z); f <- sin(z)


  ae <- a * e; af <- a * f; be <- b * e; bf <- b * f

  mat[1]  <- c * e
  mat[5]  <- -c * f
  mat[9]  <- d

  mat[2]  <- af + be * d
  mat[6]  <- ae - bf * d
  mat[10] <- -b * c

  mat[3]  <- bf - ae * d
  mat[7]  <- be + af * d
  mat[11] <- a * c

  mat[1:3, 1:3]

}

# Convert a 3D rotation matrix to a 2D one
convert3Dto2DrotationMatrix <- function(rotation_matrix) {

  euler <- eulerFromMatrix(rotation_matrix)
  euler$x <- 0
  euler$y <- 0
  matrixFromEuler(euler)[1:2, 1:2]

}
