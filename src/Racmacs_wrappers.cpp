
#include <RcppArmadillo.h>
#include "acmap_map.h"
#include "acmap_optimization.h"
#include "procrustes.h"
using namespace Rcpp;

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
