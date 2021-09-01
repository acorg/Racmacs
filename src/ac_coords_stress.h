
#include <RcppArmadillo.h>
#include "acmap_titers.h"

#ifndef Racmacs__ac_coords_stress__h
#define Racmacs__ac_coords_stress__h

// Calculating stress
double ac_coords_stress(
    const AcTiterTable &titers,
    const std::string &min_colbasis,
    const arma::vec &fixed_colbases,
    const arma::vec &ag_reactivity_adjustments,
    arma::mat &ag_coords,
    arma::mat &sr_coords,
    double dilution_stepsize
);

#endif
