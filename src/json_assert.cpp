
#include <RcppArmadillo.h>

void ac_assert(bool x){
  if(!x) Rf_error("Parsing failed");
}

