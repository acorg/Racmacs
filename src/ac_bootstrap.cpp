
#include "acmap_map.h"
#include "acmap_titers.h"
#include "ac_optim_map_stress.h"
#include "ac_bootstrap.h"
#include "ac_optimizer_options.h"

// Function for sampling from a dirichilet
arma::vec rdirichilet(
    arma::uword n
) {

  arma::vec beta_sample = arma::randg<arma::vec>( n );
  return beta_sample / arma::accu(beta_sample);

}

// [[Rcpp::export]]
BootstrapOutput ac_bootstrap_map(
    const AcMap map,
    std::string method,
    bool bootstrap_ags,
    bool bootstrap_sr,
    bool reoptimize,
    double ag_noise_sd,
    double titer_noise_sd,
    std::string minimum_column_basis,
    arma::vec fixed_column_bases,
    arma::vec ag_reactivity_adjustments,
    int num_optimizations,
    int num_dimensions,
    AcOptimizerOptions options
){

  // Fetch titer table
  AcTiterTable titer_table = map.titer_table_flat;
  arma::uword num_ags = titer_table.nags();
  arma::uword num_sr = titer_table.nsr();

  // Declare variables
  arma::vec colbases;
  arma::vec pt_sampling;

  // Add noise to the titer table
  if (method == "noisy") {

    // First a matrix of shared antigen noise
    arma::vec ag_noise = arma::randn<arma::vec>(num_ags)*ag_noise_sd;
    arma::mat ag_noise_matrix(num_ags, num_sr, arma::fill::zeros);
    ag_noise_matrix.each_col() += ag_noise;
    titer_table.add_log_titers(ag_noise_matrix);

    // Then a full matrix of titer noise
    arma::mat titer_noise = arma::randn<arma::mat>(num_ags, num_sr)*titer_noise_sd;
    titer_table.add_log_titers(titer_noise);

    // Save ag weights into point weights
    arma::vec sr_noise = arma::vec(num_sr, arma::fill::zeros);
    pt_sampling = arma::join_cols(ag_noise, sr_noise);

  }

  // Get column bases (after setting any noise)
  colbases = titer_table.calc_colbases(
    minimum_column_basis,
    fixed_column_bases,
    ag_reactivity_adjustments
  );

  // Set antigen and sera weights
  arma::vec ag_weights = arma::vec(num_ags, arma::fill::ones);
  arma::vec sr_weights = arma::vec(num_sr, arma::fill::ones);

  // Set weights according to a random resample
  if (method == "resample") {

    if (bootstrap_ags) {
      ag_weights.zeros();
      arma::uvec ag_sample = arma::randi<arma::uvec>(num_ags, arma::distr_param(0, num_ags - 1));
      for (arma::uword i=0; i<num_ags; i++) ag_weights(ag_sample(i)) += 1.0;
    }

    if (bootstrap_sr) {
      sr_weights.zeros();
      arma::uvec sr_sample = arma::randi<arma::uvec>(num_sr, arma::distr_param(0, num_sr - 1));
      for (arma::uword i=0; i<num_sr; i++) sr_weights(sr_sample(i)) += 1.0;
    }

    // Save into point weights
    pt_sampling = arma::join_cols(ag_weights, sr_weights);

  }

  // Set weights according to a dirichilet distribution
  if (method == "bayesian") {

    if (bootstrap_ags) ag_weights = rdirichilet(num_ags);
    if (bootstrap_sr) sr_weights = rdirichilet(num_sr);

    // Save into point weights
    pt_sampling = arma::join_cols(ag_weights, sr_weights);

  }

  // Calculate titer weights
  arma::mat titer_weights = arma::mat(num_ags, num_sr, arma::fill::ones);
  titer_weights.each_row() %= sr_weights.as_row();
  titer_weights.each_col() %= ag_weights.as_col();

  // Set variables
  double stress;
  arma::mat ag_coords;
  arma::mat sr_coords;
  if (reoptimize) { // If reoptimizing from scratch

    // Run the optimization
    std::vector<AcOptimization> optimizations;
    optimizations = ac_runOptimizations(
      titer_table,
      minimum_column_basis,
      fixed_column_bases,
      ag_reactivity_adjustments,
      num_dimensions,
      num_optimizations,
      options,
      titer_weights,
      map.dilution_stepsize
    );

    // Sort by stress and keep lowest stress coords
    sort_optimizations_by_stress(optimizations);
    ag_coords = optimizations.at(0).agCoords();
    sr_coords = optimizations.at(0).srCoords();
    stress = optimizations.at(0).stress;

  } else { // If simply relaxing the map

    ag_coords = map.optimizations.at(0).agCoords();
    sr_coords = map.optimizations.at(0).srCoords();

    stress = ac_relax_coords(
      titer_table.numeric_table_distances(
        minimum_column_basis,
        fixed_column_bases,
        ag_reactivity_adjustments
      ),
      titer_table.get_titer_types(),
      ag_coords,
      sr_coords,
      options,
      arma::uvec(), // Fixed ags
      arma::uvec(), // Fixed sera
      titer_weights,
      map.dilution_stepsize
    );

  }

  // Set coordinates for ag and sr coords weighted 0 to NaN
  for (arma::uword i=0; i<num_ags; i++) if(ag_weights(i) == 0) ag_coords.row(i).fill(arma::datum::nan);
  for (arma::uword i=0; i<num_sr; i++)  if(sr_weights(i) == 0) sr_coords.row(i).fill(arma::datum::nan);

  // Setup for output
  struct BootstrapOutput results{
    pt_sampling,
    arma::join_cols(
      ag_coords,
      sr_coords
    ),
    stress
  };

  // Return results
  return results;

}



