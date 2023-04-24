
#include "acmap_titers.h"

#ifndef Racmacs__ac_merge__h
#define Racmacs__ac_merge__h


// Merge options
struct AcMergeOptions {
  double sd_limit;
  double dilution_stepsize;
  Rcpp::Function merge_function;
  std::string method;
};


// Merge titers
AcTiter ac_merge_titers(
    const std::vector<AcTiter>& titers,
    const AcMergeOptions& options
);


// Merge titer layers
AcTiterTable ac_merge_titer_layers(
    const std::vector<AcTiterTable>& titer_layers,
    const AcMergeOptions& options
);

#endif
