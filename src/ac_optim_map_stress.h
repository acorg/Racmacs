
# include <RcppArmadillo.h>
# include "acmap_map.h"
# include "ac_optimizer_options.h"

#ifndef Racmacs__ac_optim_map_stress__h
#define Racmacs__ac_optim_map_stress__h

// Generating optimizations with randomised coords
std::vector<AcOptimization> ac_generateOptimizations(
    const arma::mat &tabledist_matrix,
    const arma::imat &titertype_matrix,
    const std::string &min_colbasis,
    const arma::vec &fixed_colbases,
    const arma::vec &ag_reactivity_adjustments,
    const int &num_dims,
    const int &num_optimizations,
    const AcOptimizerOptions &options,
    const double &dilution_stepsize = 1.0
);

// Relaxing optimizations
void ac_relaxOptimizations(
    std::vector<AcOptimization>& optimizations,
    arma::uword num_dims,
    const arma::mat &tabledist_matrix,
    const arma::imat &titertype_matrix,
    const AcOptimizerOptions &options,
    const arma::mat &titer_weights = arma::mat(),
    const double &dilution_stepsize = 1.0
);

// Running optimizations
std::vector<AcOptimization> ac_runOptimizations(
    const AcTiterTable &titertable,
    const std::string &min_colbasis,
    const arma::vec &fixed_colbases,
    const arma::vec &ag_reactivity_adjustments,
    const arma::uword &num_dims,
    const arma::uword &num_optimizations,
    const AcOptimizerOptions &options,
    const arma::mat &titer_weights = arma::mat(),
    const double &dilution_stepsize = 1.0
);

// Sorting optimizations by stress
void sort_optimizations_by_stress(
    std::vector<AcOptimization> &optimizations
);

// Calculating residual error
arma::mat ac_point_residuals(
    const AcMap &map,
    const arma::uword &optimization_number
);

#endif
