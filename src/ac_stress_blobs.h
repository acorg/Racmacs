
#include <RcppArmadillo.h>

#ifndef Racmacs__ac_stress_blobs__h
#define Racmacs__ac_stress_blobs__h

struct StressBlobGrid2d {
  arma::mat grid;
  arma::vec xcoords;
  arma::vec ycoords;
  double stress_lim;
};

StressBlobGrid2d ac_stress_blob_grid_2d(
    arma::vec testcoords,
    arma::mat coords,
    arma::vec tabledists,
    arma::uvec titertypes,
    double stress_lim = 1.0,
    double grid_spacing = 0.1
);

#endif
