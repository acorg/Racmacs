
#include <RcppArmadillo.h>

// [[Rcpp::export]]
arma::vec simd_test_without(
  arma::vec x,
  arma::vec y,
  arma::vec z
){

  int veclen = x.n_elem;
  arma::vec out(veclen);

  for(int i=0; i<veclen; i++) {
    out(i) = x(i) + y(i) * z(i);
  }

  return out;

}

// [[Rcpp::export]]
arma::vec simd_test_with(
    arma::vec x,
    arma::vec y,
    arma::vec z
){

  return x + y % z;

}
