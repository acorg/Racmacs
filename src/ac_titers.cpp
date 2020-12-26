
# include <RcppArmadillo.h>
# include "acmap_titers.h"

// Check titer validity
void check_valid_titer(
  std::string titer
){

  // titer_expr("^[<>]?[0-9]+$");

  // Remove first
  if(titer.at(0) == '<' || titer.at(0) == '>'){
    titer.erase(0,1);
  }

  // Check conversion
  if(titer.at(0) != '*' || titer.length() != 1){
    try {
      std::stod(titer);
    } catch(...) {
      std::string msg = "Invalid titer '"+titer+"'";
      Rf_error(msg.c_str());
    }
  }

}

// Get numeric titers from a vector of titers
//' @export
// [[Rcpp::export]]
arma::vec numeric_titers(
    std::vector<AcTiter> titers
){

  arma::vec numerictiters(titers.size());
  for(arma::uword i=0; i<titers.size(); i++){
    if(titers[i].type == 0){
      numerictiters[i] = arma::datum::nan;
    } else {
      numerictiters[i] = titers[i].numeric;
    }
  }
  return numerictiters;

}

// Get log titers from a vector of titers
//' @export
// [[Rcpp::export]]
arma::vec log_titers(
    std::vector<AcTiter> titers
){

  arma::vec logtiters(titers.size());
  for(arma::uword i=0; i<titers.size(); i++){
    logtiters[i] = titers[i].logTiter();
  }
  return logtiters;

}

// Get titer types from a vector of titers
//' @export
// [[Rcpp::export]]
arma::uvec titer_types_int(
    std::vector<AcTiter> titers
){

  arma::uvec titertypes(titers.size());
  for(arma::uword i=0; i<titers.size(); i++){
    titertypes[i] = titers[i].type;
  }
  return titertypes;

}



