
#include <RcppArmadillo.h>
#include "acmap_map.h"
#include "acmap_optimization.h"
#include "procrustes.h"
using namespace Rcpp;

// Get variables
// [[Rcpp::export]]
std::vector<std::string> ac_ag_names(
  const AcMap map
){
  return map.agNames();
}

// Manipulate antigenic coordinates
// [[Rcpp::export]]
arma::mat ac_get_ag_coords(
  const AcOptimization opt
){
  return opt.agCoords();
}

// [[Rcpp::export]]
arma::mat ac_get_sr_coords(
    const AcOptimization opt
){
  return opt.srCoords();
}

// [[Rcpp::export]]
AcOptimization ac_set_ag_coords(
    AcOptimization opt,
    const arma::mat coords
){
  opt.set_ag_coords(coords);
  return opt;
}

// [[Rcpp::export]]
AcOptimization ac_set_sr_coords(
    AcOptimization opt,
    const arma::mat coords
){
  opt.set_sr_coords(coords);
  return opt;
}

// Align two optimizations
// [[Rcpp::export]]
AcOptimization ac_align_optimization(
  AcOptimization source_optimization,
  const AcOptimization target_optimization
){

  source_optimization.alignToOptimization(target_optimization);
  return source_optimization;

}

// Subset a map
// [[Rcpp::export]]
AcMap ac_subset_map(
    AcMap map,
    const arma::uvec ags,
    const arma::uvec sr
){

  map.subset(ags, sr);
  return map;

}


// Get column bases
//' @export
// [[Rcpp::export]]
arma::vec ac_table_colbases(
    const AcTiterTable titer_table,
    const std::string min_col_basis
){

  return titer_table.colbases(min_col_basis);

}


// Get table distances
//' @export
// [[Rcpp::export]]
arma::mat ac_table_distances(
    const AcTiterTable titer_table,
    const arma::vec colbases
){

  return titer_table.table_distances(colbases);

}

