
#include <RcppArmadillo.h>
#include "acmap_titers.h"
#include "ac_optimizer_options.h"

#ifndef Racmacs__ac_dimension_test__h
#define Racmacs__ac_dimension_test__h

struct DimTestOutput
{
  arma::uvec test_indices;
  arma::uvec dim;
  std::vector<arma::mat> coords;
  std::vector<arma::vec> predictions;
};

#endif
