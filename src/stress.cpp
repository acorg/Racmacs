
#include <Rcpp.h>
#include <math.h>
using namespace Rcpp;

//' @export
// [[Rcpp::export]]
double euc_dist(NumericVector coords1,
                NumericVector coords2) {

  double sum_squares = 0;
  for(int i = 0; i < coords1.length(); ++i) {
    sum_squares += pow(coords1[i] - coords2[i], 2);
  }
  return(sqrt(sum_squares));

}


//' @export
// [[Rcpp::export]]
NumericMatrix ac_mapDists(NumericMatrix ag_coords,
                          NumericMatrix sr_coords) {

  int num_ags = ag_coords.nrow();
  int num_sr  = sr_coords.nrow();
  NumericMatrix map_dists(num_ags, num_sr);

  for(int ag = 0; ag < num_ags; ++ag) {
    for(int sr = 0; sr < num_sr; ++sr) {

        map_dists(ag, sr) = euc_dist(ag_coords( ag, _), sr_coords( sr, _));

    }
  }

  return(map_dists);

}


//' @export
// [[Rcpp::export]]
double ac_pointStress(double map_dist,
                      double table_dist,
                      bool   less_than){

  if(less_than){
    double x = table_dist - map_dist + 1;
    return(pow(x,2)*(1/(1+exp(-10*x))));
  } else {
    return(pow((table_dist - map_dist), 2));
  }

}

//' @export
// [[Rcpp::export]]
double ac_coordStress(NumericVector map_dist,
                      NumericVector table_dist,
                      LogicalVector less_than){

  double stress = 0;

  for(int i = 0; i < map_dist.length(); ++i) {
      stress += ac_pointStress(map_dist[i],
                               table_dist[i],
                               less_than[i]);
  }

  return(stress);

}

//' @export
// [[Rcpp::export]]
double ac_optimizationStress(NumericMatrix table_dist,
                           NumericMatrix ag_coords,
                           NumericMatrix sr_coords,
                           NumericMatrix lessthans,
                           NumericMatrix morethans,
                           NumericMatrix na_vals){

    // Calculate map distances
    NumericMatrix map_dists = ac_mapDists(ag_coords, sr_coords);

    // Calculate stress
    double stress = 0;
    int num_ags = ag_coords.nrow();
    int num_sr  = sr_coords.nrow();

    for(int ag = 0; ag < num_ags; ++ag) {
      for(int sr = 0; sr < num_sr; ++sr) {
        if(!na_vals(ag,sr) && !morethans(ag,sr)){
          stress += ac_pointStress(map_dists(ag,sr),
                                   table_dist(ag,sr),
                                   lessthans(ag,sr));
        }
      }
    }

    // Return total stress
    return(stress);

}

//' @export
// [[Rcpp::export]]
NumericVector grid_search(NumericMatrix test_coords,
                          NumericMatrix pair_coords,
                          NumericVector table_dist,
                          NumericVector lessthans,
                          NumericVector morethans,
                          NumericVector na_vals) {

  // Work out the number of tests
  int ntests = test_coords.nrow();
  NumericVector stresses(ntests);

  // Cycle through tests
  for (int i = 0; i < ntests; i++) {
    NumericVector i_coords = test_coords(i,_);
    double i_stress = 0;

    // Sum up stress
    for (int j = 0; j < pair_coords.nrow(); j++) {
      if(!na_vals[j] && !morethans[j]){
        double map_dist = euc_dist(i_coords, pair_coords(j,_));
        i_stress += ac_pointStress(map_dist,
                                   table_dist[j],
                                   lessthans[j]);
      }
    }

    stresses[i] = i_stress;

  }

  // Return the stresses
  return(stresses);

}


//' @export
// [[Rcpp::export]]
double ac_mapCoordStress(NumericVector coord_par,
                         int num_ags,
                         int num_sr,
                         int num_dims,
                         NumericMatrix table_dist,
                         NumericMatrix lessthans,
                         NumericMatrix morethans,
                         NumericMatrix na_vals){

  // Create coordinate matrix
  NumericMatrix coord_matrix(num_ags + num_sr,  num_dims);
  int num_pts = num_ags + num_sr;
  for (int i = 0; i < num_pts*num_dims; i++) {
    coord_matrix[i] = coord_par[i];
  }

  // Calculate stress
  return(ac_optimizationStress(table_dist,
                             coord_matrix(Range(0, num_ags-1), _),
                             coord_matrix(Range(num_ags, num_ags+num_sr-1), _),
                             lessthans,
                             morethans,
                             na_vals));

}







