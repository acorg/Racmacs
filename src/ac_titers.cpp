
# include <RcppArmadillo.h>
# include "acmap_titers.h"

// Check titer validity
void check_valid_titer(
  std::string titer
){

  // Skip if titer at 0
  if(titer.at(0) != '*' || titer.length() != 1){

    // Remove first
    if(titer.at(0) == '<' || titer.at(0) == '>'){
      titer.erase(0,1);
    }

    // Check remaining values are valid numeric
    if(
      titer.at(0) == '0'
      || titer.find_first_not_of("0123456789") != std::string::npos
      ) {

      std::string msg = "Invalid titer '"+titer+"'";
      Rf_error(msg.c_str());

    }

  }

}

// Get numeric titers from a vector of titers
// [[Rcpp::export]]
arma::vec numeric_titers(
    std::vector<AcTiter> titers
){

  arma::vec numerictiters(titers.size());
  for(arma::uword i=0; i<titers.size(); i++){
    if(titers[i].type <= 0){
      numerictiters[i] = arma::datum::nan;
    } else {
      numerictiters[i] = titers[i].numeric;
    }
  }
  return numerictiters;

}

// Get log titers from a vector of titers
// [[Rcpp::export]]
arma::vec log_titers(
    std::vector<AcTiter> titers,
    double dilution_stepsize
){

  arma::vec logtiters(titers.size());
  for(arma::uword i=0; i<titers.size(); i++){
    logtiters[i] = titers[i].logTiter(dilution_stepsize);
  }
  return logtiters;

}

// Get titer types from a vector of titers
// [[Rcpp::export]]
arma::ivec titer_types_int(
    std::vector<AcTiter> titers
){

  arma::ivec titertypes(titers.size());
  for(arma::uword i=0; i<titers.size(); i++){
    titertypes[i] = titers[i].type;
  }
  return titertypes;

}

// Make titers from numeric and titer types
// [[Rcpp::export]]
std::vector<AcTiter> make_titers(
    arma::vec numeric_titers,
    arma::ivec titer_types_int
){

  std::vector<AcTiter> titers(numeric_titers.n_elem);
  for(arma::uword i=0; i<numeric_titers.n_elem; i++){
    titers[i] = AcTiter(numeric_titers[i], titer_types_int[i]);
  }
  return titers;

}



