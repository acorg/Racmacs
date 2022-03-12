
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
std::string ac_sr_get_species( const AcSerum &sr ){ return sr.get_species(); }
// [[Rcpp::export(rng = false)]]
std::vector<std::string> ac_sr_get_clade( const AcSerum &sr ){ return sr.get_clade(); }
// [[Rcpp::export(rng = false)]]
std::vector<std::string> ac_sr_get_annotations( const AcSerum &sr ){ return sr.get_annotations(); }
// [[Rcpp::export(rng = false)]]
std::string ac_sr_get_name( const AcSerum &sr ){ return sr.get_name(); }
// [[Rcpp::export(rng = false)]]
std::string ac_sr_get_extra( const AcSerum &sr ){ return sr.get_extra(); }
// [[Rcpp::export(rng = false)]]
std::string ac_sr_get_lineage( const AcSerum &sr ){ return sr.get_lineage(); }
// [[Rcpp::export(rng = false)]]
std::string ac_sr_get_reassortant( const AcSerum &sr ){ return sr.get_reassortant(); }
// [[Rcpp::export(rng = false)]]
std::string ac_sr_get_strings( const AcSerum &sr ){ return sr.get_strings(); }
// [[Rcpp::export(rng = false)]]
std::string ac_sr_get_continent( const AcSerum &sr ){ return sr.get_continent(); }

// [[Rcpp::export(rng = false)]]
std::string ac_sr_get_match_id( const AcSerum &sr ){ return sr.get_match_id(); }

// [[Rcpp::export(rng = false)]]
arma::uvec ac_sr_get_homologous_ags( const AcSerum &sr ){ return sr.get_homologous_ags(); }

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
AcSerum ac_sr_set_species( AcSerum sr, std::string value ){ sr.set_species(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_clade( AcSerum sr, std::vector<std::string> value ){ sr.set_clade(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_annotations( AcSerum sr, std::vector<std::string> value ){ sr.set_annotations(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_name( AcSerum sr, std::string value ){ sr.set_name(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_extra( AcSerum sr, std::string value ){ sr.set_extra(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_lineage( AcSerum sr, std::string value ){ sr.set_lineage(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_reassortant( AcSerum sr, std::string value ){ sr.set_reassortant(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_strings( AcSerum sr, std::string value ){ sr.set_strings(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_continent( AcSerum sr, std::string value ){ sr.set_continent(value); return sr; }


// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_homologous_ags( AcSerum sr, arma::uvec value ){ sr.set_homologous_ags(value); return sr; }

// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_group( AcSerum sr, int value ){ sr.set_group(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcMap ac_sr_set_group_levels( AcMap map, std::vector<std::string> values ){ map.set_sr_group_levels( values ); return map; }
