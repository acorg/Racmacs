
#include "acmap_titers.h"

#ifndef Racmacs__ac_merge__h
#define Racmacs__ac_merge__h

AcTiter ac_merge_titers(
    std::vector<AcTiter> titers,
    double sd_lim = 1.0
);

AcTiterTable ac_merge_titer_layers(
    std::vector<AcTiterTable> titer_layers
);

#endif
