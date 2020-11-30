
#include "acmap_titers.h"

#ifndef Racmacs__ac_titers__h
#define Racmacs__ac_titers__h

arma::vec numeric_titers(
    std::vector<AcTiter> titers
);

arma::vec log_titers(
    std::vector<AcTiter> titers
);

arma::uvec titer_types_int(
    std::vector<AcTiter> titers
);

arma::vec ac_table_colbases(
    AcTiterTable titer_table,
    std::string min_col_basis = "none"
);

#endif
