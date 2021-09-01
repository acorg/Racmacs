
#include <RcppArmadillo.h>
#include "acmap_titers.h"
#include "ac_optimizer_options.h"
#include "acmap_map.h"
#include "ac_bootstrap_output.h"

#ifndef Racmacs__ac_bootstrap__h
#define Racmacs__ac_bootstrap__h

BootstrapOutput ac_bootstrap_map(
    AcMap map,
    std::string method,
    bool bootstrap_ags,
    bool bootstrap_sr,
    bool reoptimize,
    double ag_noise_sd,
    double titer_noise_sd,
    std::string minimum_column_basis,
    arma::vec fixed_column_bases,
    arma::vec ag_reactivity_adjustments,
    int num_optimizations,
    int num_dimensions,
    AcOptimizerOptions options
);

#endif
