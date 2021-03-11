
#include <RcppArmadillo.h>

// [[Rcpp::export]]
arma::mat ac_coordDistMatrix(
    arma::mat coords1,
    arma::mat coords2
){

  arma::uword nrows = coords1.n_rows;
  arma::uword ncols = coords2.n_rows;
  arma::uword ndims = coords1.n_cols;

  arma::mat distmat( coords1.n_rows, coords2.n_rows );
  for(arma::uword i=0; i<nrows; i++){
    for(arma::uword j=0; j<ncols; j++){
      double stress = 0;
      for(arma::uword k=0; k<ndims; k++){
        stress += std::pow(coords1(i,k) - coords2(j,k), 2);
      }
      distmat(i, j) = std::sqrt(stress);
    }
  }

  return distmat;

}
