
#include <RcppArmadillo.h>

#ifndef Racmacs__ac_bootstrap_output__h
#define Racmacs__ac_bootstrap_output__h

struct BootstrapOutput
{
  arma::vec sampling;
  arma::mat coords;
  double stress;
};

#endif
