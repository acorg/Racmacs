
# include <RcppArmadillo.h>
# include "acmap_optimization.h"
# include "acmap_titers.h"
# include "ac_optimizer_options.h"

#ifndef Racmacs__ac_optim_map_stress__h
#define Racmacs__ac_optim_map_stress__h

// Running optimizations
std::vector<AcOptimization> ac_runOptimizations(
    const AcTiterTable &titertable,
    arma::vec &colbases,
    const int &num_dims,
    const int &num_optimizations,
    const AcOptimizerOptions &options
);

void sort_optimizations_by_stress(
    std::vector<AcOptimization> &optimizations
);

#endif
