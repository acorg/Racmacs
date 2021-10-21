
#include <RcppArmadillo.h>
#include "utils_error.h"

// Resizing transformation to match new dimensions
void ac_set_transformation_dims(
    arma::mat& transformation,
    const arma::uword& dims
){

  if(transformation.n_cols == dims) return;
  arma::mat new_transform(dims, dims, arma::fill::eye);
  new_transform.submat(
    0, 0,
    transformation.n_rows - 1,
    transformation.n_cols - 1
  ) = transformation;
  transformation = new_transform;

}

// Resizing translation to match new dimensions
void ac_set_translation_dims(
    arma::mat& translation,
    const arma::uword& dims
){

  if(translation.n_cols != 1) ac_error("Translation must be an n x 1 matrix");
  if(translation.n_rows == dims) return;
  arma::mat new_translation(dims, 1, arma::fill::zeros);
  new_translation.rows(0, translation.n_rows - 1) = translation;
  translation = new_translation;

}

// Transforming a transformation matrix
void ac_transform_transformation(
    arma::mat& transform,
    arma::mat transformation
){

  arma::uword max_dim = arma::max(
    arma::uvec{
      transform.n_cols,
      transformation.n_cols
    }
  );
  ac_set_transformation_dims(transform, max_dim);
  ac_set_transformation_dims(transformation, max_dim);
  transform = transform * transformation;

}

// Transforming a translation matrix
void ac_transform_translation(
    arma::mat& translate,
    arma::mat transformation
){

  arma::uword max_dim = arma::max(
    arma::uvec{
      translate.n_rows,
      transformation.n_cols
    }
  );
  ac_set_translation_dims(translate, max_dim);
  ac_set_transformation_dims(transformation, max_dim);
  translate = arma::trans( translate.t() * transformation );

}

// Translating a translation matrix
void ac_translate_translation(
    arma::mat& translate,
    arma::mat translation
){

  arma::uword max_dim = arma::max(
    arma::uvec{
      translate.n_rows,
      translation.n_rows
    }
  );
  ac_set_translation_dims(translate, max_dim);
  ac_set_translation_dims(translation, max_dim);
  translate = translate + translation;

}

// Creating a rotation transform matrix
arma::mat ac_rotation_matrix(
    double degrees,
    arma::uword dims,
    arma::uword axis_num = 2
){

  // Check input
  if(dims != 2 && dims != 3) ac_error("Rotation is only supported in 2 or 3 dimensions");
  if(dims == 2 && axis_num != 2) ac_error("3D rotation of 2D coordinates is not supported");

  // Create the rotation matrix
  arma::mat rotmat;
  double radians = arma::datum::pi * degrees / 180.0;

  switch(axis_num) {
  case 0:
    // x axis rotation
    rotmat = {
      { 1, 0, 0 },
      { 0, std::cos(radians), -std::sin(radians) },
      { 0, std::sin(radians), std::cos(radians) }
    };
    break;
  case 1:
    // y axis rotation
    rotmat = {
      { std::cos(radians), 0, std::sin(radians) },
      { 0, 1, 0 },
      { -std::sin(radians), 0, std::cos(radians) }
    };
    break;
  case 2:
    // z axis rotation
    rotmat = {
      { std::cos(radians), -std::sin(radians), 0 },
      { std::sin(radians), std::cos(radians), 0 },
      { 0, 0, 1 }
    };
    break;
  default:
    ac_error("rotation is only supported in the first 3 dimensions, otherwise apply a transformation");
  }

  // Resize to the right number of dimensions (only relevant for trimming 2d)
  // and return the result
  rotmat.resize(dims, dims);
  return rotmat;

}

// Creating a reflection transform matrix
arma::mat ac_reflection_matrix(
    const arma::uword &dims,
    const arma::uword &axis_num
){

  arma::mat rotmat(dims, dims, arma::fill::zeros);
  arma::vec diag(dims);
  diag.fill(-1);
  rotmat.diag() = diag;
  rotmat(axis_num, axis_num) = 1;
  return rotmat;

}


// Creating a scaling matrix
arma::mat ac_scaling_matrix(
    const arma::uword &dims,
    double scaling
){

  arma::mat rotmat(dims, dims, arma::fill::zeros);
  arma::vec diag(dims);
  diag.fill(scaling);
  rotmat.diag() = diag;
  return rotmat;

}

