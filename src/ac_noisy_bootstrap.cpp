
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


  // Get column bases after setting don't cares if not setting from full table
  if(!column_bases_from_full_table){
    colbases = titer_table.colbases(minimum_column_basis);
  }

  // Setup for output
  struct DimTestOutput results = {
    indices_test,
    dimensions_to_test,
    std::vector<arma::mat>(dimensions_to_test.n_elem),
    std::vector<arma::vec>(dimensions_to_test.n_elem)
  };

  // Run the optimization for each set of dimensions
  std::vector<AcOptimization> optimizations;
  arma::vec predicted_titers(indices_test.n_elem);
  for(int i = 0; i < dimensions_to_test.n_elem; i++){

    // Check for user interrupt
    Rcpp::checkUserInterrupt();

    // Get optimizations
    optimizations = ac_runOptimizations(
      titer_table,
      colbases,
      dimensions_to_test[i],
                        num_optimizations,
                        method,
                        maxit,
                        dim_annealing
    );

    // Sort by stress and keep lowest stress coords
    sort_optimizations_by_stress(optimizations);

    // Work out predicted titers for each of the test cases
    for(int j=0; j<predicted_titers.n_elem; j++){
      double dist = optimizations[0].ptDist(
        indices_test_mat(0,j),
        indices_test_mat(1,j)
      );
      double colbase = colbases(indices_test_mat(1,j));
      predicted_titers[j] = colbase - dist;
    }

    // Store results
    arma::mat ptcoords = optimizations[0].ptCoords();
    results.coords.at(i) = ptcoords;
    results.predictions.at(i) = predicted_titers;

  }

  // Return results
  return results;

}


