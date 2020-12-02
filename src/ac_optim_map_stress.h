
# include <RcppArmadillo.h>
# include "acmap_optimization.h"
# include "acmap_titers.h"

#ifndef Racmacs__ac_optim_map_stress__h
#define Racmacs__ac_optim_map_stress__h

std::vector<AcOptimization> ac_runOptimizations(
    const AcTiterTable &titertable,
    arma::vec &colbases,
    const int &num_dims,
    const int &num_optimizations,
    const std::string &method = "L-BFGS-B",
    const int &maxit = 1000,
    const bool &dim_annealing = false
);

void sort_optimizations_by_stress(
    std::vector<AcOptimization> &optimizations
);

#endif
