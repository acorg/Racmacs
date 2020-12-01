
#include <RcppArmadillo.h>
#include "acmap_map.h"
#include "acmap_optimization.h"
#include "procrustes.h"
using namespace Rcpp;

// Get variables
// [[Rcpp::export]]
std::vector<std::string> ac_ag_names(
  AcMap map
){
  return map.agNames();
}

// Manipulate antigenic coordinates
// [[Rcpp::export]]
arma::mat ac_get_ag_coords(
  AcOptimization opt
){
  return opt.agCoords();
}

// [[Rcpp::export]]
arma::mat ac_get_sr_coords(
    AcOptimization opt
){
  return opt.srCoords();
}

// [[Rcpp::export]]
AcOptimization ac_set_ag_coords(
    AcOptimization opt,
    arma::mat coords
){
  opt.set_ag_coords(coords);
  return opt;
}

// [[Rcpp::export]]
AcOptimization ac_set_sr_coords(
    AcOptimization opt,
    arma::mat coords
){
  opt.set_sr_coords(coords);
  return opt;
}

// Align two optimizations
// [[Rcpp::export]]
AcOptimization ac_align_optimization(
  AcOptimization source_optimization,
  AcOptimization target_optimization
){

  source_optimization.alignToOptimization(target_optimization);
  return source_optimization;

}

// Subset a map
// [[Rcpp::export]]
AcMap ac_subset_map(
    AcMap map,
    arma::uvec ags,
    arma::uvec sr
){

  map.subset(ags, sr);
  return map;

}
