
#include <RcppArmadillo.h>
#include "acmap_optimization.h"

#ifndef Racmacs__RacmacsWrap__h
#define Racmacs__RacmacsWrap__h

// declaring the specialization
namespace Rcpp {

  // For converting from the optimization class back to R
  template <>
  SEXP wrap(const Optimization& opt){
    return wrap(
      List::create(
        _["ag_coords"] = opt.ag_coords,
        _["sr_coords"] = opt.sr_coords,
        _["stress"] = opt.stress
      )
    );
  }

  // For converting from R to optimization

}

#endif
