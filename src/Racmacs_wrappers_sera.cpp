
#include <RcppArmadillo.h>
#include "acmap_map.h"
#include "acmap_point.h"


// [[Rcpp::export(rng = false)]]
AcSerum ac_new_serum( std::string name ){
  AcSerum sr;
  sr.set_name(name);
  return sr;
}


// --- GETTERS -----------------------------

// [[Rcpp::export(rng = false)]]
std::string ac_sr_get_id( const AcSerum &sr ){ return sr.get_id(); }
// [[Rcpp::export(rng = false)]]
std::string ac_sr_get_date( const AcSerum &sr ){ return sr.get_date(); }
// [[Rcpp::export(rng = false)]]
bool ac_sr_get_reference( const AcSerum &sr ){ return sr.get_reference(); }
// [[Rcpp::export(rng = false)]]
std::string ac_sr_get_passage( const AcSerum &sr ){ return sr.get_passage(); }
// [[Rcpp::export(rng = false)]]
std::string ac_sr_get_name( const AcSerum &sr ){ return sr.get_name(); }
// [[Rcpp::export(rng = false)]]
std::string ac_sr_get_name_full( const AcSerum &sr ){ return sr.get_name_full(); }
// [[Rcpp::export(rng = false)]]
std::string ac_sr_get_name_abbreviated( const AcSerum &sr ){ return sr.get_name_abbreviated(); }

// [[Rcpp::export(rng = false)]]
int ac_sr_get_group( const AcSerum &sr ){ return sr.get_group(); }
// [[Rcpp::export(rng = false)]]
std::vector<std::string> ac_sr_get_group_levels( const AcMap map ){ return map.get_sr_group_levels(); }


// --- SETTERS -----------------------------

// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_id( AcSerum sr, std::string value ){ sr.set_id(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_date( AcSerum sr, std::string value ){ sr.set_date(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_reference( AcSerum sr, bool value ){  sr.set_reference(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_passage( AcSerum sr, std::string value ){ sr.set_passage(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_name( AcSerum sr, std::string value ){ sr.set_name(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_name_full( AcSerum sr, std::string value ){  sr.set_name_full(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_name_abbreviated( AcSerum sr, std::string value ){ sr.set_name_abbreviated(value); return sr; }

// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_group( AcSerum sr, int value ){ sr.set_group(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcMap ac_sr_set_group_levels( AcMap map, std::vector<std::string> values ){ map.set_sr_group_levels( values ); return map; }
