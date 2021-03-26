
#include "acmap_titers.h"

#ifndef Racmacs__ac_merge__h
#define Racmacs__ac_merge__h

// [[Rcpp::export]]
AcTiter ac_merge_titers(
    const std::vector<AcTiter>& titers,
    double sd_lim = 1.0
);

AcTiterTable ac_merge_titer_layers(
    const std::vector<AcTiterTable>& titer_layers
);

#endif
