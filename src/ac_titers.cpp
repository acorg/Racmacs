
# include <RcppArmadillo.h>
# include "acmap_titers.h"

// Get numeric titers from a vector of titers
//' @export
// [[Rcpp::export]]
arma::vec numeric_titers(
    std::vector<AcTiter> titers
){

  arma::vec numerictiters(titers.size());
  for(int i=0; i<titers.size(); i++){
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
  for(int i=0; i<titers.size(); i++){
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
  for(int i=0; i<titers.size(); i++){
    titertypes[i] = titers[i].type;
  }
  return titertypes;

}


// Get table column bases
//' @export
// [[Rcpp::export]]
arma::vec ac_table_colbases(
  AcTiterTable titer_table,
  std::string min_col_basis = "none"
){

  int num_sr = titer_table.nsr();
  arma::vec column_bases(num_sr);

  // Get column basis for each sera
  for(int i=0; i<num_sr; i++){
    column_bases(i) = arma::max(
      log_titers(titer_table.srTiters(i))
    );
  }

  // Clamp to the minimum column basis
  if(min_col_basis != "none"){
    AcTiter col_basis_titer(min_col_basis);
    column_bases = arma::clamp(
      column_bases,
      col_basis_titer.logTiter(),
      column_bases.max()
    );
  }

  return column_bases;

}


