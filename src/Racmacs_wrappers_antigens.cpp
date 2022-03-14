
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
std::vector<std::string> ac_ag_get_clade( const AcAntigen &ag ){ return ag.get_clade(); }
// [[Rcpp::export(rng = false)]]
std::vector<std::string> ac_ag_get_annotations( const AcAntigen &ag ){ return ag.get_annotations(); }
// [[Rcpp::export(rng = false)]]
std::vector<std::string> ac_ag_get_labids( const AcAntigen &ag ){ return ag.get_labids(); }
// [[Rcpp::export(rng = false)]]
std::string ac_ag_get_name( const AcAntigen &ag ){ return ag.get_name(); }
// [[Rcpp::export(rng = false)]]
std::string ac_ag_get_extra( const AcAntigen &ag ){ return ag.get_extra(); }
// [[Rcpp::export(rng = false)]]
std::string ac_ag_get_lineage( const AcAntigen &ag ){ return ag.get_lineage(); }
// [[Rcpp::export(rng = false)]]
std::string ac_ag_get_reassortant( const AcAntigen &ag ){ return ag.get_reassortant(); }
// [[Rcpp::export(rng = false)]]
std::string ac_ag_get_strings( const AcAntigen &ag ){ return ag.get_strings(); }
// [[Rcpp::export(rng = false)]]
std::string ac_ag_get_continent( const AcAntigen &ag ){ return ag.get_continent(); }

// [[Rcpp::export(rng = false)]]
std::string ac_ag_get_match_id( const AcAntigen &ag ){ return ag.get_match_id(); }
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
AcAntigen ac_ag_set_clade( AcAntigen ag, std::vector<std::string> value ){ ag.set_clade(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_annotations( AcAntigen ag, std::vector<std::string> value ){ ag.set_annotations(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_labids( AcAntigen ag, std::vector<std::string> value ){ ag.set_labids(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_name( AcAntigen ag, std::string value ){ ag.set_name(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_extra( AcAntigen ag, std::string value ){ ag.set_extra(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_lineage( AcAntigen ag, std::string value ){ ag.set_lineage(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_reassortant( AcAntigen ag, std::string value ){ ag.set_reassortant(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_strings( AcAntigen ag, std::string value ){ ag.set_strings(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_continent( AcAntigen ag, std::string value ){ ag.set_continent(value); return ag; }

// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_group( AcAntigen ag, int value ){ ag.set_group(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcMap ac_ag_set_group_levels( AcMap map, std::vector<std::string> values ){ map.set_ag_group_levels( values ); return map; }

