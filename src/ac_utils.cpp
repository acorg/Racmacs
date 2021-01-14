
#include <RcppArmadillo.h>

// Use principle component analysis to reduce coordinates to lower dimensions
// [[Rcpp::export]]
arma::mat reduce_matrix_dimensions(
    arma::mat m,
    int dim
){

  arma::mat coeff = arma::princomp(m);
  return m*coeff.cols(0, dim);

}

