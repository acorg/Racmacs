
#include "acmap_titers.h"

#ifndef Racmacs__ac_titers__h
#define Racmacs__ac_titers__h

arma::vec numeric_titers(
    std::vector<AcTiter> titers
);

arma::vec log_titers(
    std::vector<AcTiter> titers,
    double dilution_stepsize
);

arma::ivec titer_types_int(
    std::vector<AcTiter> titers
);

void check_valid_titer(
    std::string titer
);

#endif
