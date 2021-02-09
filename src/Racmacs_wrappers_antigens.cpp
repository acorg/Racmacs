
#include <RcppArmadillo.h>
#include "acmap_map.h"
#include "acmap_point.h"


// [[Rcpp::export(rng = false)]]
AcAntigen ac_new_antigen( std::string name ){
  AcAntigen ag;
  ag.set_name(name);
  return ag;
}


// --- GETTERS -----------------------------

// [[Rcpp::export(rng = false)]]
std::string ac_ag_get_id( const AcAntigen &ag ){ return ag.get_id(); }
// [[Rcpp::export(rng = false)]]
std::string ac_ag_get_date( const AcAntigen &ag ){ return ag.get_date(); }
// [[Rcpp::export(rng = false)]]
bool ac_ag_get_reference( const AcAntigen &ag ){ return ag.get_reference(); }
// [[Rcpp::export(rng = false)]]
std::string ac_ag_get_passage( const AcAntigen &ag ){ return ag.get_passage(); }
// [[Rcpp::export(rng = false)]]
std::string ac_ag_get_name( const AcAntigen &ag ){ return ag.get_name(); }
// [[Rcpp::export(rng = false)]]
std::string ac_ag_get_name_full( const AcAntigen &ag ){ return ag.get_name_full(); }
// [[Rcpp::export(rng = false)]]
std::string ac_ag_get_name_abbreviated( const AcAntigen &ag ){ return ag.get_name_abbreviated(); }

// [[Rcpp::export(rng = false)]]
int ac_ag_get_group( const AcAntigen &ag ){ return ag.get_group(); }
// [[Rcpp::export(rng = false)]]
std::vector<std::string> ac_ag_get_group_levels( const AcMap map ){ return map.get_ag_group_levels(); }


// --- SETTERS -----------------------------

// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_id( AcAntigen ag, std::string value ){ ag.set_id(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_date( AcAntigen ag, std::string value ){ ag.set_date(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_reference( AcAntigen ag, bool value ){  ag.set_reference(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_passage( AcAntigen ag, std::string value ){ ag.set_passage(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_name( AcAntigen ag, std::string value ){ ag.set_name(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_name_full( AcAntigen ag, std::string value ){  ag.set_name_full(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_name_abbreviated( AcAntigen ag, std::string value ){ ag.set_name_abbreviated(value); return ag; }

// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_group( AcAntigen ag, int value ){ ag.set_group(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcMap ac_ag_set_group_levels( AcMap map, std::vector<std::string> values ){ map.set_ag_group_levels( values ); return map; }

