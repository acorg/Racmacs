
#include <RcppArmadillo.h>

#ifndef Racmacs__ac_matching__h
#define Racmacs__ac_matching__h

template <typename T>
arma::ivec ac_match_points(
    T const& points1,
    T const& points2
);

#endif
