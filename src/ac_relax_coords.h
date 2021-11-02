
# include <RcppArmadillo.h>
# include "ac_optimizer_options.h"

#ifndef Racmacs__ac_relax_coords__h
#define Racmacs__ac_relax_coords__h

double ac_relax_coords(
    const arma::mat &tabledist_matrix,
    const arma::imat &titertype_matrix,
    arma::mat &ag_coords,
    arma::mat &sr_coords,
    const AcOptimizerOptions &options,
    const arma::uvec &fixed_antigens = arma::uvec(),
    const arma::uvec &fixed_sera = arma::uvec(),
    const arma::mat &titer_weights = arma::mat(),
    const double &dilution_stepsize = 1.0
);

#endif
