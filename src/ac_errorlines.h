
#include <RcppArmadillo.h>

#ifndef Racmacs__ac_errorlines__h
#define Racmacs__ac_errorlines__h

struct ErrorLineData
{
  arma::vec x;
  arma::vec xend;
  arma::vec y;
  arma::vec yend;
  arma::uvec color;
};

#endif
