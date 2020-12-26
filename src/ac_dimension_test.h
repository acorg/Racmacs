
#include <RcppArmadillo.h>
#include "acmap_titers.h"
#include "ac_optimizer_options.h"

#ifndef Racmacs__ac_dimension_test__h
#define Racmacs__ac_dimension_test__h

struct DimTestOutput
{
  arma::uvec test_indices;
  arma::uvec dim;
  std::vector<arma::mat> coords;
  std::vector<arma::vec> predictions;
};

DimTestOutput ac_dimension_test_map(
    AcTiterTable titer_table,
    arma::uvec dimensions_to_test,
    double test_proportion,
    std::string minimum_column_basis,
    bool column_bases_from_master,
    int number_of_optimizations,
    int replicates_per_proportion,
    AcOptimizerOptions options
);

#endif
