
#include <RcppArmadillo.h>

void ac_error(
    const char* msg
){

  Rf_error("%s", msg);

}

void ac_error(
    const std::string msg
){

  Rf_error("%s", msg.c_str());

}
