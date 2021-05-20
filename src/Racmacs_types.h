
#include <RcppArmadillo.h>
#include "acmap_optimization.h"
#include "acmap_titers.h"
#include "acmap_map.h"
#include "acmap_diagnostics.h"
#include "procrustes.h"
#include "ac_dimension_test.h"
#include "ac_bootstrap.h"
#include "ac_stress_blobs.h"
#include "ac_optim_map_stress.h"
#include "ac_hemi_test.h"
#include "utils_error.h"

#ifndef Racmacs__RacmacsWrap__h
#define Racmacs__RacmacsWrap__h

// declaring the specialization
namespace Rcpp {

  // FROM: ACCOORDS
  template <>
  SEXP wrap(const AcCoords& coords);

  // FROM: PROCRUSTES DATA
  template <>
  SEXP wrap(const ProcrustesData &pc);

  // FROM: ACTITER
  template <>
  SEXP wrap(const AcTiter& t);

  // FROM: ACTITER VECTOR
  template <>
  SEXP wrap(const std::vector<AcTiter>& titers);

  // FROM: ACTITERTABLE
  template <>
  SEXP wrap(const AcTiterTable& t);

  // FROM: PROCRUSTES
  template <>
  SEXP wrap(const Procrustes& p);

  // FROM: ARMA::VEC
  template <>
  SEXP wrap(const arma::vec& v);

  // FROM: ACPLOTSPEC
  SEXP wrap(const AcPlotspec& ps);

  // FROM: ACANTIGEN
  SEXP wrap(const AcAntigen& ag);

  // FROM: ACSERUM
  SEXP wrap(const AcSerum& sr);

  // FROM: ACDIAGNOSTICS
  template <>
  SEXP wrap(const HemiDiagnosis& hemidiag);

  template <>
  SEXP wrap(const AcDiagnostics& acdiag);

  // FROM: ACOPTIMIZATION
  template <>
  SEXP wrap(const AcOptimization& acopt);

  // FROM: ACMAP
  template <>
  SEXP wrap(const AcMap& acmap);

  // Dimtest results
  template <>
  SEXP wrap(const DimTestOutput& dimtestout);

  // Bootstrap results
  template <>
  SEXP wrap(const BootstrapOutput& bootstrapout);

  // Stress blob results 2d
  template <>
  SEXP wrap(const StressBlobGrid& blobgrid);

  // For converting from R to C++
  // TP: ACCOORDS
  template <>
  AcCoords as(SEXP sxp);

  // TO: std::string
  template <>
  std::string as(SEXP sxp);

  // TO: AcOptimizerOptions
  template <>
  AcOptimizerOptions as(SEXP sxp);

  // TO: ACTITER
  template <>
  AcTiter as(SEXP sxp);

  // TO: ACTITERTABLE
  template <>
  AcTiterTable as(SEXP sxp);

  // TO: ACTITER VECTOR
  template <>
  std::vector<AcTiter> as(SEXP sxp);

  // TO: ACTITERTABLE VECTOR
  template <>
  std::vector<AcTiterTable> as(SEXP sxp);

  // TO: ACPLOTSPEC
  template<>
  AcPlotspec as(SEXP sxp);

  // TO: ACANTIGEN
  template <>
  AcAntigen as(SEXP sxp);

  // TO: ACSERUM
  template <>
  AcSerum as(SEXP sxp);

  // TO: ACDIAGNOSTICS
  template <>
  AcDiagnostics as(SEXP sxp);

  // TO: ACOPTIMIZATION
  template <>
  AcOptimization as(SEXP sxp);

  // TO: ACMAP
  template <>
  AcMap as(SEXP sxp);

  // TO: ACMAP VECTOR
  template <>
  std::vector<AcMap> as(SEXP sxp);

}

#endif
