
# include <RcppArmadillo.h>
# include "ac_optimizer_options.h"

#ifndef Racmacs__ac_relax_coords__h
#define Racmacs__ac_relax_coords__h

double ac_relax_coords(
    const arma::mat &tabledist_matrix,
    const arma::umat &titertype_matrix,
    arma::mat &ag_coords,
    arma::mat &sr_coords,
    const AcOptimizerOptions &options,
    const arma::uvec &fixed_antigens,
    const arma::uvec &fixed_sera
);

#endif
