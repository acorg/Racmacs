
#include <RcppArmadillo.h>

#ifndef Racmacs__utils_error__h
#define Racmacs__utils_error__h

void ac_error(
  const char* msg
);

void ac_error(
  const char* format,
  int arg1
);

void ac_error(
    const char* format,
    int arg1,
    int arg2
);

#endif
