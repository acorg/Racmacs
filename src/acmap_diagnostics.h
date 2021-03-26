
#include <RcppArmadillo.h>
#include "ac_hemi_test.h"
#include "ac_noisy_bootstrap.h"

#ifndef Racmacs__acmap_diagnostics__h
#define Racmacs__acmap_diagnostics__h

class AcDiagnostics {

  public:
    std::vector<HemiDiagnosis> hemi;

};

#endif
