
#include <RcppArmadillo.h>

double euc_dist(
  arma::vec x1,
  arma::vec x2
){

  return std::sqrt(
    arma::sum(arma::square(x2 - x1))
  );

}

