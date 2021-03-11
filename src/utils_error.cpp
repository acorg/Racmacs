
#include <RcppArmadillo.h>

void ac_error(
    const char* msg
){

  Rf_error(msg);

}

void ac_error(
    const char* format,
    int arg1
){

  char msg[400];
  std::sprintf(msg, format, arg1);
  Rf_error(msg);

}

void ac_error(
    const char* format,
    int arg1,
    int arg2
){

  char msg[400];
  std::sprintf(msg, format, arg1, arg2);
  Rf_error(msg);

}
