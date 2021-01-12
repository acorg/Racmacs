
#include <RcppArmadillo.h>

#ifndef Racmacs__ac_coords_stress__h
#define Racmacs__ac_coords_stress__h

// Calculating stress
double ac_coords_stress(
    const arma::mat &tabledist_matrix,
    const arma::umat &titertype_matrix,
    arma::mat &ag_coords,
    arma::mat &sr_coords
);

#endif
