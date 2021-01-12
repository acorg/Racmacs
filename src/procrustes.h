
#ifndef Racmacs__procrustes__h
#define Racmacs__procrustes__h

#include <RcppArmadillo.h>

struct Procrustes
{
  arma::mat R;
  arma::mat tt;
  double s;
};

struct AcCoords
{
  arma::mat ag_coords;
  arma::mat sr_coords;
};

struct ProcrustesData
{
  arma::vec ag_dists;
  arma::vec sr_dists;
  double ag_rmsd;
  double sr_rmsd;
  double total_rmsd;
};

Procrustes ac_procrustes(
    arma::mat X,
    arma::mat Xstar,
    bool translation = true,
    bool dilation = false
);

arma::mat transform_coords(
    const arma::mat &coords,
    const arma::mat &rotation,
    const arma::mat &translation,
    const double &scaling = 1
);

#endif

