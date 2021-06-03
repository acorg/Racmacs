
#include <RcppArmadillo.h>
#include "acmap_titers.h"

#ifndef Racmacs__ac_coords_stress__h
#define Racmacs__ac_coords_stress__h

// Calculating stress
double ac_coords_stress(
    const AcTiterTable &titers,
    const arma::vec &colbases,
    arma::mat &ag_coords,
    arma::mat &sr_coords
);

#endif
