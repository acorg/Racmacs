
#include <RcppArmadillo.h>

#ifndef Racmacs__utils_transformation__h
#define Racmacs__utils_transformation__h

// Transforming a transformation matrix
void ac_transform_transformation(
  arma::mat& transform,
  arma::mat transformation
);

// Transforming a translation matrix
void ac_transform_translation(
  arma::mat& translate,
  arma::mat transformation
);

// Translating a translation matrix
void ac_translate_translation(
  arma::mat& translate,
  arma::mat translation
);

// Creating a rotation transform matrix
arma::mat ac_rotation_matrix(
  double degrees,
  arma::uword dims,
  arma::uword axis_num = 2
);

// Creating a reflection transform matrix
arma::mat ac_reflection_matrix(
    const arma::uword &dims,
    const arma::uword &axis_num
);

// Creating a scaling transform matrix
arma::mat ac_scaling_matrix(
    const arma::uword &dims,
    double scaling
);

#endif

