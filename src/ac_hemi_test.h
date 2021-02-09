
#include <RcppArmadillo.h>
#include "acmap_titers.h"
#include "ac_optimizer_options.h"

#ifndef Racmacs__ac_hemi_test__h
#define Racmacs__ac_hemi_test__h

struct HemiDiagnosis
{
  std::string diagnosis;
  arma::vec coords;
};

struct HemiData
{
  arma::uword index;
  std::vector<HemiDiagnosis> diagnoses;
};

struct HemiTestOutput
{
  std::vector<HemiData> antigens;
  std::vector<HemiData> sera;
};

#endif
