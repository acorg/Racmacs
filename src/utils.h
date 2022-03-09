
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

arma::mat unique_rows(
        const arma::mat &m
);

void uvec_push(arma::uvec &v, arma::uword value);

// Template for subsetting a vector
template<typename T>
std::vector<T> subset_vector(
        std::vector<T> vec,
        arma::uvec indices
){

    std::vector<T> subvec(indices.n_elem);
    for (arma::uword i=0; i < indices.n_elem; i++) {
        subvec[i] = vec[indices(i)];
    }
    return subvec;

}

#endif
