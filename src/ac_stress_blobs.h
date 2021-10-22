
#include <RcppArmadillo.h>

#ifndef Racmacs__ac_stress_blobs__h
#define Racmacs__ac_stress_blobs__h

struct StressBlobGrid {
  arma::cube grid;
  arma::vec xcoords;
  arma::vec ycoords;
  arma::vec zcoords;
  double stress_lim;
};

StressBlobGrid ac_stress_blob_grid(
    arma::vec testcoords,
    arma::mat coords,
    arma::vec tabledists,
    arma::ivec titertypes,
    double stress_lim = 1.0,
    double grid_spacing = 0.1,
    double dilution_stepsize = 1.0
);

#endif
