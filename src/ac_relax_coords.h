
# include <RcppArmadillo.h>

#ifndef Racmacs__ac_relax_coords__h
#define Racmacs__ac_relax_coords__h

double ac_relax_coords(
    const arma::mat &tabledist_matrix,
    const arma::umat &titertype_matrix,
    arma::mat &ag_coords,
    arma::mat &sr_coords,
    const std::string method = "L-BFGS-B",
    const int maxit = 10000,
    bool check_gradient_fn = false
);

#endif
