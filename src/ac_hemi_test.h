
#include <RcppArmadillo.h>
#include "acmap_titers.h"
#include "ac_optimizer_options.h"

#ifndef Racmacs__ac_hemi_test__h
#define Racmacs__ac_hemi_test__h

class HemiDiagnosis
{

public:
  std::string diagnosis;
  arma::vec coords;

};

class HemiData
{

public:
  arma::uword index;
  std::vector<HemiDiagnosis> diagnoses;

};

#endif
