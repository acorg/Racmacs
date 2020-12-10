
#include <RcppArmadillo.h>

#ifndef Racmacs__ac_stress_blobs__h
#define Racmacs__ac_stress_blobs__h

struct StressBlobGrid2d {
  arma::mat grid;
  arma::vec xcoords;
  arma::vec ycoords;
  double stress_lim;
};

#endif
