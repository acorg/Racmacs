
#include "acmap_map.h"
#include "acmap_titers.h"
#include "ac_optim_map_stress.h"
#include "ac_noisy_bootstrap.h"

// [[Rcpp::export]]
NoisyBootstrapOutput ac_noisy_bootstrap_map(
    AcTiterTable titer_table,
    double ag_noise_sd,
    double titer_noise_sd,
    std::string minimum_column_basis,
    bool column_bases_from_full_table,
    int num_optimizations,
    int num_dimensions,
    std::string method,
    int maxit,
    bool dim_annealing
){

  // Declare variables
  arma::vec colbases;

  // Get column bases before adding noise if not setting from full table
  if(column_bases_from_full_table){
    colbases = titer_table.colbases(minimum_column_basis);
  }

  // Add noise to the titer table
  int num_ags = titer_table.nags();
  int num_sr = titer_table.nsr();

  // First a matrix of shared antigen noise
  arma::vec ag_noise = arma::randn<arma::vec>(num_ags)*ag_noise_sd;
  arma::mat ag_noise_matrix(num_ags, num_sr, arma::fill::zeros);
  ag_noise_matrix.each_col() += ag_noise;
  titer_table.add_log_titers(ag_noise_matrix);

  // Then a full matrix of titer noise
  arma::mat titer_noise = arma::randn<arma::mat>(num_ags, num_sr)*titer_noise_sd;
  titer_table.add_log_titers(titer_noise);

  // Get column bases after setting noise if not setting from full table
  if(!column_bases_from_full_table){
    colbases = titer_table.colbases(minimum_column_basis);
  }

  // Run the optimization
  std::vector<AcOptimization> optimizations;
  optimizations = ac_runOptimizations(
    titer_table,
    colbases,
    num_dimensions,
    num_optimizations,
    method,
    maxit,
    dim_annealing
  );

  // Sort by stress and keep lowest stress coords
  sort_optimizations_by_stress(optimizations);
  arma::mat coords = arma::join_cols(
    optimizations[0].agCoords(),
    optimizations[0].srCoords()
  );

  // Setup for output
  struct NoisyBootstrapOutput results{
    ag_noise,
    coords
  };

  // Return results
  return results;

}



