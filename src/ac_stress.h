
#include <RcppArmadillo.h>

#ifndef Racmacs__ac_stress__h
#define Racmacs__ac_stress__h

// The threshold penalty function
double sigmoid(double &x);

// The derivative of the threshold penalty function
double d_sigmoid(double &x);

// This is the point stress function
double ac_ptStress(
  double &map_dist,
  double &table_dist,
  arma::sword &titer_type,
  double &dilution_stepsize
);

// This is the point residual function
double ac_ptResidual(
    double &map_dist,
    double &table_dist,
    arma::sword &titer_type,
    double &dilution_stepsize
);

// This is the inc_base function used in the stress gradient function
double inc_base(
  double &map_dist,
  double &table_dist,
  arma::sword &titer_type,
  double &dilution_stepsize
);

#endif
