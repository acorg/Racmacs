
#include <Rcpp.h>
using namespace Rcpp;

//' Calculate the distance between two sets of coordinates
//'
//' This calculates the euclidean distance, row by row, of two sets of coordinates.
//'
//' @export
// [[Rcpp::export]]
NumericVector calc_coord_dist(NumericMatrix coords1,
                              NumericMatrix coords2) {

  // Check number of rows match
  if(coords1.nrow() != coords2.nrow()){
    stop("Number of coordinate rows do not match.");
  }

  // Setup storage vector
  int n = coords1.nrow();
  NumericVector all_dists(n);

  for(int i = 0; i < n; ++i) {

    // Calculate euclidean distance
    double euc_dist = sqrt(sum(pow(coords1(i,_) - coords2(i,_), 2)));
    all_dists[i] = euc_dist;

  }

  // Return distances
  return(all_dists);

}
