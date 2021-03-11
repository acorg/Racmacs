
#include <RcppArmadillo.h>
#include "acmap_titers.h"
#include "ac_optimizer_options.h"

#ifndef Racmacs__ac_noisy_bootstrap__h
#define Racmacs__ac_noisy_bootstrap__h

struct NoisyBootstrapOutput
{
  arma::vec ag_noise;
  arma::mat coords;
};

NoisyBootstrapOutput ac_noisy_bootstrap_map(
    AcTiterTable titer_table,
    double ag_noise_sd,
    double titer_noise_sd,
    std::string minimum_column_basis,
    bool column_bases_from_full_table,
    int num_optimizations,
    int num_dimensions,
    AcOptimizerOptions options
);

#endif
