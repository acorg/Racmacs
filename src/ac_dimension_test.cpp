
#include "acmap_map.h"
#include "acmap_titers.h"
#include "ac_optim_map_stress.h"
#include "ac_dimension_test.h"

// [[Rcpp::export]]
DimTestOutput ac_dimension_test_map(
  AcTiterTable titer_table,
  arma::uvec dimensions_to_test,
  double test_proportion,
  std::string minimum_column_basis,
  bool column_bases_from_full_table,
  int num_optimizations,
  std::string method,
  int maxit,
  bool dim_annealing
){

  // Declare variables
  arma::vec colbases;

  // Get column bases before setting don't cares if not setting from full table
  if(column_bases_from_full_table){
    colbases = titer_table.colbases(minimum_column_basis);
  }

  // Get a random index of measured titers to test
  int num_measured = titer_table.num_measured();
  int num_test = round(num_measured*test_proportion);

  arma::uvec indices_measured = titer_table.vec_indices_measured();
  arma::uvec sample = arma::randperm( num_measured, num_test );
  arma::uvec indices_test = indices_measured.elem( sample );
  arma::umat indices_test_mat = arma::ind2sub( titer_table.size(), indices_test );

  // Set test indices to unmeasured
  titer_table.set_unmeasured(indices_test);

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


