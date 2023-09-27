
#include <RcppArmadillo.h>
#include "acmap_optimization.h"
#include "acmap_titers.h"
#include "ac_optimization.h"
#include "ac_optim_map_stress.h"

// [[Rcpp::export]]
double ac_reactivity_adjustment_stress(
    const arma::vec &par,
    const arma::vec &fixed_ag_reactivities,
    const std::string &minimum_column_basis,
    const arma::vec &fixed_column_bases,
    const AcTiterTable &titertable,
    arma::mat ag_coords,
    arma::mat sr_coords,
    AcOptimizerOptions &options,
    const arma::uvec &fixed_antigens,
    const arma::uvec &fixed_sera,
    const arma::mat &titer_weights,
    const double &reactivity_stress_weighting,
    const bool reoptimize,
    const arma::uword num_optimizations,
    const double &dilution_stepsize
) {

  // Update reactivities with values from par
  arma::vec ag_reactivity_adjustments = fixed_ag_reactivities;
  ag_reactivity_adjustments.elem(arma::find_nonfinite(ag_reactivity_adjustments)) = par;

  // Get adjusted map stress
  double stress;
  if (reoptimize) {

    // Do not report progress
    options.report_progress = false;

    // Run the optimization
    std::vector<AcOptimization> optimizations;
    optimizations = ac_runOptimizations(
      titertable,
      minimum_column_basis,
      fixed_column_bases,
      ag_reactivity_adjustments,
      ag_coords.n_cols,
      num_optimizations,
      options,
      titer_weights,
      dilution_stepsize
    );

    // Sort by stress and keep lowest stress
    sort_optimizations_by_stress(optimizations);
    stress = optimizations.at(0).stress;

  } else {

    stress = ac_relax_coords(
      titertable.numeric_table_distances(
        minimum_column_basis,
        fixed_column_bases,
        ag_reactivity_adjustments
      ),
      titertable.get_titer_types(),
      ag_coords,
      sr_coords,
      options,
      fixed_antigens,
      fixed_sera,
      titer_weights
    );

  }

  // Increase map stress according to adjustment applied
  for (arma::uword i=0; i<ag_reactivity_adjustments.n_elem; i++) {
    stress += std::pow(ag_reactivity_adjustments(i) * reactivity_stress_weighting, 2);
  }
  return(stress);

}
