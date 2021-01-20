
#include <RcppArmadillo.h>
#include "acmap_plotspec.h"

// --- GETTERS -----------------------------

// [[Rcpp::export(rng = false)]]
bool ac_plotspec_get_shown( const AcPlotspec ps ){ return ps.get_shown(); }
// [[Rcpp::export(rng = false)]]
double ac_plotspec_get_size( const AcPlotspec ps ){ return ps.get_size(); }
// [[Rcpp::export(rng = false)]]
std::string ac_plotspec_get_fill( const AcPlotspec ps ){ return ps.get_fill(); }
// [[Rcpp::export(rng = false)]]
std::string ac_plotspec_get_outline( const AcPlotspec ps ){ return ps.get_outline(); }
// [[Rcpp::export(rng = false)]]
double ac_plotspec_get_outline_width( const AcPlotspec ps ){ return ps.get_outline_width(); }
// [[Rcpp::export(rng = false)]]
double ac_plotspec_get_rotation( const AcPlotspec ps ){ return ps.get_rotation(); }
// [[Rcpp::export(rng = false)]]
double ac_plotspec_get_aspect( const AcPlotspec ps ){ return ps.get_aspect(); }
// [[Rcpp::export(rng = false)]]
std::string ac_plotspec_get_shape( const AcPlotspec ps ){ return ps.get_shape(); }


// --- SETTERS -----------------------------

// [[Rcpp::export(rng = false)]]
AcPlotspec ac_plotspec_set_shown( AcPlotspec ps, bool value ){ ps.set_shown(value); return ps; }
// [[Rcpp::export(rng = false)]]
AcPlotspec ac_plotspec_set_size( AcPlotspec ps, double value ){ ps.set_size(value); return ps; }
// [[Rcpp::export(rng = false)]]
AcPlotspec ac_plotspec_set_fill( AcPlotspec ps, std::string value ){ ps.set_fill(value); return ps; }
// [[Rcpp::export(rng = false)]]
AcPlotspec ac_plotspec_set_outline( AcPlotspec ps, std::string value ){ ps.set_outline(value); return ps; }
// [[Rcpp::export(rng = false)]]
AcPlotspec ac_plotspec_set_outline_width( AcPlotspec ps, double value ){ ps.set_outline_width(value); return ps; }
// [[Rcpp::export(rng = false)]]
AcPlotspec ac_plotspec_set_rotation( AcPlotspec ps, double value ){ ps.set_rotation(value); return ps; }
// [[Rcpp::export(rng = false)]]
AcPlotspec ac_plotspec_set_aspect( AcPlotspec ps, double value ){ ps.set_aspect(value); return ps; }
// [[Rcpp::export(rng = false)]]
AcPlotspec ac_plotspec_set_shape( AcPlotspec ps, std::string value ){ ps.set_shape(value); return ps; }

