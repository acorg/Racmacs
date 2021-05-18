
#include <RcppArmadillo.h>
#include "ac_optim_map_stress.h"
#include "ac_optimization.h"
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

// Align all optimizations of one map to the first optimization of another
// [[Rcpp::export]]
AcMap ac_align_map(
  AcMap source_map,
  AcMap target_map,
  bool translation,
  bool scaling
){

  // Do the alignment
  source_map.realign_to_map(
    target_map,
    0,
    translation,
    scaling
  );

  // Return the map
  return source_map;

}

// Align multiple optimizations to the first one
// [[Rcpp::export]]
std::vector<AcOptimization> ac_align_optimizations(
  std::vector<AcOptimization> optimizations
){

  align_optimizations(optimizations);
  return optimizations;

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
// [[Rcpp::export]]
arma::vec ac_table_colbases(
    const AcTiterTable titer_table,
    const std::string min_col_basis,
    const arma::vec fixed_col_bases
){

  return titer_table.colbases(
    min_col_basis,
    fixed_col_bases
  );

}


// Get table distances
// [[Rcpp::export]]
arma::mat ac_table_distances(
    const AcTiterTable titer_table,
    const arma::vec colbases
){

  return titer_table.table_distances(colbases);

}


// Relax an optimization
// [[Rcpp::export]]
AcOptimization ac_newOptimization(
    int dimensions,
    int num_antigens,
    int num_sera
){

  return AcOptimization(
    dimensions,
    num_antigens,
    num_sera
  );

}


// Relax an optimization
// [[Rcpp::export]]
AcOptimization ac_relaxOptimization(
    AcOptimization opt,
    AcTiterTable titers,
    arma::uvec fixed_antigens,
    arma::uvec fixed_sera,
    AcOptimizerOptions options,
    arma::vec ag_weights,
    arma::vec sr_weights
){

  opt.relax_from_titer_table(
    titers,
    options,
    fixed_antigens,
    fixed_sera,
    ag_weights,
    sr_weights
  );
  return opt;

}


// Relax an optimization
// [[Rcpp::export]]
AcMap ac_optimize_map(
    AcMap map,
    int num_dims,
    int num_optimizations,
    std::string min_col_basis,
    arma::vec fixed_col_bases,
    arma::vec ag_weights,
    arma::vec sr_weights,
    AcOptimizerOptions options
){

  map.optimize(
    num_dims,
    num_optimizations,
    min_col_basis,
    fixed_col_bases,
    options,
    ag_weights,
    sr_weights
  );

  return map;

}




