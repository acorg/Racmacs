
#include <Rcpp.h>
#include <math.h>
using namespace Rcpp;

// Define external function prototypes
extern NumericMatrix ac_mapDists(NumericMatrix ag_coords,
                                 NumericMatrix sr_coords);

//' @export
// [[Rcpp::export]]
double ac_pointLogLik(double map_dist,
                      double max_table_dist,
                      double min_table_dist,
                      double error_sd){

  return(R::logspace_sub(R::pnorm5(max_table_dist, map_dist, error_sd,1,1),
                         R::pnorm5(min_table_dist, map_dist, error_sd,1,1)));

}

//' @export
// [[Rcpp::export]]
double ac_mapNegLogLik(NumericVector map_dist,
                       NumericVector max_table_dist,
                       NumericVector min_table_dist,
                       double error_sd)
{

  double total_negll = 0;
  for(int i = 0; i < map_dist.length(); ++i) {
    total_negll -= ac_pointLogLik(max_table_dist[i],
                                  min_table_dist[i],
                                  map_dist[i],
                                  error_sd);
  }
  return(total_negll);

}


//' @export
// [[Rcpp::export]]
double ac_optimizationNegLogLik(NumericMatrix max_table_dist,
                              NumericMatrix min_table_dist,
                              NumericMatrix ag_coords,
                              NumericMatrix sr_coords,
                              NumericMatrix na_vals,
                              double error_sd){

  // Calculate map distances
  NumericMatrix map_dists = ac_mapDists(ag_coords, sr_coords);

  // Calculate negative log likelihood
  double total_negll = 0;
  int num_ags = ag_coords.nrow();
  int num_sr  = sr_coords.nrow();

  for(int ag = 0; ag < num_ags; ++ag) {
    for(int sr = 0; sr < num_sr; ++sr) {
      if(!na_vals(ag,sr)){
        total_negll -= ac_pointLogLik(map_dists(ag,sr),
                                      max_table_dist(ag,sr),
                                      min_table_dist(ag,sr),
                                      error_sd);
      }
    }
  }

  // Return total stress
  return(total_negll);

}


//' @export
// [[Rcpp::export]]
double ac_mapCoordNegLogLik(NumericVector coord_par,
                            int num_ags,
                            int num_sr,
                            int num_dims,
                            NumericMatrix max_table_dist,
                            NumericMatrix min_table_dist,
                            NumericMatrix na_vals,
                            double error_sd){

  // Create coordinate matrix
  NumericMatrix coord_matrix(num_ags + num_sr,  num_dims);
  int num_pts = num_ags + num_sr;
  for (int i = 0; i < num_pts*num_dims; i++) {
    coord_matrix[i] = coord_par[i];
  }

  // Calculate stress
  return(ac_optimizationNegLogLik(max_table_dist,
                                min_table_dist,
                                coord_matrix(Range(0, num_ags-1), _),
                                coord_matrix(Range(num_ags, num_ags+num_sr-1), _),
                                na_vals,
                                error_sd));

}



