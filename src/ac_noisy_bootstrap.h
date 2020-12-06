
#include <RcppArmadillo.h>
#include "acmap_titers.h"

#ifndef Racmacs__ac_noisy_bootstrap__h
#define Racmacs__ac_noisy_bootstrap__h

struct NoisyBootstrapOutput
{
  arma::uvec test_indices;
  arma::uvec dim;
  std::vector<arma::mat> coords;
  std::vector<arma::vec> predictions;
};

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
);

#endif
