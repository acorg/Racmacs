
#include <RcppArmadillo.h>
#include "acmap_point.h"

// --- GETTERS -----------------------------

// [[Rcpp::export(rng = false)]]
bool ac_ag_get_shown( const AcAntigen ag ){ return ag.get_shown(); }
// [[Rcpp::export(rng = false)]]
double ac_ag_get_size( const AcAntigen ag ){ return ag.get_size(); }
// [[Rcpp::export(rng = false)]]
std::string ac_ag_get_fill( const AcAntigen ag ){ return ag.get_fill(); }
// [[Rcpp::export(rng = false)]]
std::string ac_ag_get_outline( const AcAntigen ag ){ return ag.get_outline(); }
// [[Rcpp::export(rng = false)]]
double ac_ag_get_outline_width( const AcAntigen ag ){ return ag.get_outline_width(); }
// [[Rcpp::export(rng = false)]]
double ac_ag_get_rotation( const AcAntigen ag ){ return ag.get_rotation(); }
// [[Rcpp::export(rng = false)]]
double ac_ag_get_aspect( const AcAntigen ag ){ return ag.get_aspect(); }
// [[Rcpp::export(rng = false)]]
std::string ac_ag_get_shape( const AcAntigen ag ){ return ag.get_shape(); }

// [[Rcpp::export(rng = false)]]
bool ac_sr_get_shown( const AcSerum sr ){ return sr.get_shown(); }
// [[Rcpp::export(rng = false)]]
double ac_sr_get_size( const AcSerum sr ){ return sr.get_size(); }
// [[Rcpp::export(rng = false)]]
std::string ac_sr_get_fill( const AcSerum sr ){ return sr.get_fill(); }
// [[Rcpp::export(rng = false)]]
std::string ac_sr_get_outline( const AcSerum sr ){ return sr.get_outline(); }
// [[Rcpp::export(rng = false)]]
double ac_sr_get_outline_width( const AcSerum sr ){ return sr.get_outline_width(); }
// [[Rcpp::export(rng = false)]]
double ac_sr_get_rotation( const AcSerum sr ){ return sr.get_rotation(); }
// [[Rcpp::export(rng = false)]]
double ac_sr_get_aspect( const AcSerum sr ){ return sr.get_aspect(); }
// [[Rcpp::export(rng = false)]]
std::string ac_sr_get_shape( const AcSerum sr ){ return sr.get_shape(); }


// --- SETTERS -----------------------------

// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_shown( AcAntigen ag, bool value ){ ag.set_shown(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_size( AcAntigen ag, double value ){ ag.set_size(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_fill( AcAntigen ag, std::string value ){ ag.set_fill(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_outline( AcAntigen ag, std::string value ){ ag.set_outline(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_outline_width( AcAntigen ag, double value ){ ag.set_outline_width(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_rotation( AcAntigen ag, double value ){ ag.set_rotation(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_aspect( AcAntigen ag, double value ){ ag.set_aspect(value); return ag; }
// [[Rcpp::export(rng = false)]]
AcAntigen ac_ag_set_shape( AcAntigen ag, std::string value ){ ag.set_shape(value); return ag; }


// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_shown( AcSerum sr, bool value ){ sr.set_shown(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_size( AcSerum sr, double value ){ sr.set_size(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_fill( AcSerum sr, std::string value ){ sr.set_fill(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_outline( AcSerum sr, std::string value ){ sr.set_outline(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_outline_width( AcSerum sr, double value ){ sr.set_outline_width(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_rotation( AcSerum sr, double value ){ sr.set_rotation(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_aspect( AcSerum sr, double value ){ sr.set_aspect(value); return sr; }
// [[Rcpp::export(rng = false)]]
AcSerum ac_sr_set_shape( AcSerum sr, std::string value ){ sr.set_shape(value); return sr; }


