
#include <RcppArmadillo.h>

#ifndef Racmacs__utils__h
#define Racmacs__utils__h

double rmsd(
    const arma::vec &x
);

double euc_dist(
    const arma::vec &x1,
    const arma::vec &x2
);

arma::vec ac_coord_dists(
    arma::mat coords1,
    arma::mat coords2
);

arma::mat subset_rows(
    const arma::mat &matrix,
    const arma::ivec &subset
);

arma::uvec na_row_indices(
    const arma::mat &X
);

#endif
