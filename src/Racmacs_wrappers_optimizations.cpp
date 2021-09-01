
#include <RcppArmadillo.h>
#include "acmap_optimization.h"

// --- GETTERS -----------------------------

// [[Rcpp::export(rng = false)]]
arma::mat ac_opt_get_ag_base_coords( const AcOptimization opt ){ return opt.get_ag_base_coords(); }
// [[Rcpp::export(rng = false)]]
arma::mat ac_opt_get_sr_base_coords( const AcOptimization opt ){ return opt.get_sr_base_coords(); }
// [[Rcpp::export(rng = false)]]
arma::mat ac_opt_get_transformation( const AcOptimization opt ){ return opt.get_transformation(); }
// [[Rcpp::export(rng = false)]]
arma::mat ac_opt_get_translation( const AcOptimization opt ){ return opt.get_translation(); }
// [[Rcpp::export(rng = false)]]
std::string ac_opt_get_mincolbasis( const AcOptimization opt ){ return opt.get_min_column_basis(); }
// [[Rcpp::export(rng = false)]]
arma::vec ac_opt_get_fixedcolbases( const AcOptimization opt ){ return opt.get_fixed_column_bases(); }
// [[Rcpp::export(rng = false)]]
arma::vec ac_opt_get_agreactivityadjustments( const AcOptimization opt ){ return opt.get_ag_reactivity_adjustments(); }
// [[Rcpp::export(rng = false)]]
double ac_opt_get_stress( const AcOptimization opt ){ return opt.get_stress(); }
// [[Rcpp::export(rng = false)]]
int ac_opt_get_dimensions( const AcOptimization opt ){ return opt.get_dimensions(); }
// [[Rcpp::export(rng = false)]]
std::string ac_opt_get_comment( const AcOptimization opt ){ return opt.get_comment(); }




// --- SETTERS -----------------------------

// [[Rcpp::export(rng = false)]]
AcOptimization ac_opt_set_ag_base_coords( AcOptimization opt, arma::mat value ){ opt.set_ag_base_coords(value); return opt; }
// [[Rcpp::export(rng = false)]]
AcOptimization ac_opt_set_sr_base_coords( AcOptimization opt, arma::mat value ){ opt.set_sr_base_coords(value); return opt; }
// [[Rcpp::export(rng = false)]]
AcOptimization ac_opt_set_transformation( AcOptimization opt, arma::mat value ){ opt.set_transformation(value); return opt; }
// [[Rcpp::export(rng = false)]]
AcOptimization ac_opt_set_translation( AcOptimization opt, arma::mat value ){ opt.set_translation(value); return opt; }
// [[Rcpp::export(rng = false)]]
AcOptimization ac_opt_set_mincolbasis( AcOptimization opt, std::string value ){ opt.set_min_column_basis(value); return opt; }
// [[Rcpp::export(rng = false)]]
AcOptimization ac_opt_set_fixedcolbases( AcOptimization opt, arma::vec value ){
  opt.set_fixed_column_bases(value);
  return opt;
}
// [[Rcpp::export(rng = false)]]
AcOptimization ac_opt_set_agreactivityadjustments( AcOptimization opt, arma::vec value ){
  opt.set_ag_reactivity_adjustments(value);
  return opt;
}
// [[Rcpp::export(rng = false)]]
AcOptimization ac_opt_set_stress( AcOptimization opt, double value ){ opt.set_stress(value); return opt; }
// [[Rcpp::export(rng = false)]]
AcOptimization ac_opt_set_comment( AcOptimization opt, std::string value ){ opt.set_comment(value); return opt; }



// --- OTHER -----------------------------
// [[Rcpp::export(rng = false)]]
AcOptimization ac_rotate_optimization( AcOptimization opt, double degrees, int axis_num ){
  opt.rotate( degrees, axis_num );
  return opt;
}

// [[Rcpp::export(rng = false)]]
AcOptimization ac_reflect_optimization( AcOptimization opt, int axis_num ){
  opt.reflect( axis_num );
  return opt;
}

// [[Rcpp::export(rng = false)]]
AcOptimization ac_translate_optimization( AcOptimization opt, arma::mat translation ){
  opt.translate( translation );
  return opt;
}

// [[Rcpp::export(rng = false)]]
arma::mat ac_apply_optimization_transform( AcOptimization opt, arma::mat coords ){
  return opt.applyTransformation( coords );
}

