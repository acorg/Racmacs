
#include <RcppArmadillo.h>
#include "acmap_optimization.h"
#include "procrustes.h"

#ifndef Racmacs__RacmacsWrap__h
#define Racmacs__RacmacsWrap__h

// declaring the specialization
namespace Rcpp {

  // For converting from the optimization class back to R
  template <>
  SEXP wrap(const AcOptimization& acopt){
    return wrap(
      List::create(
        _["ag_base_coords"] = acopt.ag_base_coords,
        _["sr_base_coords"] = acopt.sr_base_coords,
        _["column_bases"] = acopt.colbases,
        _["transformation"] = acopt.transformation,
        _["translation"] = acopt.translation,
        _["stress"] = acopt.stress,
        _["comment"] = acopt.comment
      )
    );
  }

  template <>
  SEXP wrap(const Procrustes& p){
    return wrap(
      List::create(
        _["R"] = p.R,
        _["tt"] = p.tt,
        _["s"] = p.s
      )
    );
  }

  // For converting from R to optimization
  template <>
  AcOptimization as(SEXP sxp){
    List opt = as<List>(sxp);
    AcOptimization acopt = AcOptimization();
    acopt.ag_base_coords = as<arma::mat>(wrap(opt["ag_base_coords"]));
    acopt.sr_base_coords = as<arma::mat>(wrap(opt["sr_base_coords"]));
    acopt.colbases = as<arma::mat>(wrap(opt["colbases"]));
    acopt.comment = as<std::string>(wrap(opt["comment"]));
    acopt.stress = as<double>(wrap(opt["stress"]));
    acopt.transformation = as<arma::mat>(wrap(opt["transformation"]));
    acopt.translation = as<arma::mat>(wrap(opt["translation"]));
    return acopt;
  };

}

#endif
