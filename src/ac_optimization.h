
#include <RcppArmadillo.h>
#include "acmap_optimization.h"

#ifndef Racmacs__ac_optimization__h
#define Racmacs__ac_optimization__h

void sort_optimizations_by_stress(
    std::vector<AcOptimization> &optimizations
);


// For optimization alignment
void align_optimizations(
    std::vector<AcOptimization> &optimizations
);

#endif
