
#include <RcppArmadillo.h>
#include "ac_hemi_test.h"
#include "ac_stress_blobs.h"
#include "acmap_optimization.h"
#include "utils.h"
#include "utils_error.h"

std::vector<HemiData> ac_hemi_test_points(
  arma::mat ag_coords,
  arma::mat sr_coords,
  arma::mat tabledists,
  arma::imat titertypes,
  double grid_spacing,
  double stress_lim,
  AcOptimizerOptions options,
  double dilution_stepsize
){

  // Set variables
  arma::uword num_ags = ag_coords.n_rows;
  arma::uword num_sr = sr_coords.n_rows;
  arma::uword dim = ag_coords.n_cols;

  // Check input
  if(dim < 2 || dim > 3){
    ac_error("Hemisphere testing is only supported for 2 or 3 dimensions");
  }

  // Setup for output
  std::vector<HemiData> output;

  // Set objects to use in loop
  arma::rowvec hemi_ag_orig_coords( dim );
  arma::rowvec hemi_ag_improved_coords( dim );
  arma::rowvec hemi_ag_relaxed_coords( dim );
  arma::uvec fixed_antigens;
  arma::uvec fixed_sera;

  // Check hemisphering antigens
  for(arma::uword ag=0; ag<num_ags; ag++){

    // Get the original ag coords and setup for any hemisphering coords
    hemi_ag_orig_coords = ag_coords.row(ag);
    std::vector<HemiDiagnosis> hemi_diagnoses;

    // Do a grid search
    StressBlobGrid grid_results = ac_stress_blob_grid(
      ag_coords.row(ag).as_col(),
      sr_coords,
      tabledists.row(ag).as_col(),
      titertypes.row(ag).as_col(),
      stress_lim,
      grid_spacing
    );

    // Get indices of those with lower stress
    arma::uvec indices = arma::find( grid_results.grid < stress_lim );

    // For those with lower stress see if they move back to the original position
    // on relaxing the map
    for(arma::uword i=0; i<indices.n_elem; i++){

      // Get the stress diff
      double stress_diff = grid_results.grid(indices(i));

      // Get the coords of the improved grid position
      arma::uvec sub = arma::ind2sub( arma::size(grid_results.grid), indices(i) );
      hemi_ag_improved_coords(0) = grid_results.xcoords( sub(0) );
      hemi_ag_improved_coords(1) = grid_results.ycoords( sub(1) );
      if(dim == 3){
        hemi_ag_improved_coords(2) = grid_results.zcoords( sub(2) );
      }

      // Move the antigen to the test position
      ag_coords.row(ag) = hemi_ag_improved_coords;

      // Set other points to be fixed
      fixed_antigens = arma::regspace<arma::uvec>( 0, num_ags - 1);
      fixed_sera = arma::regspace<arma::uvec>( 0, num_sr - 1);
      fixed_antigens.shed_row( ag );

      // Relax the coordinates
      ac_relax_coords(
        tabledists,
        titertypes,
        ag_coords,
        sr_coords,
        options,
        fixed_antigens,
        fixed_sera
      );

      // Get the coords of the relaxed position
      // and replace the antigen to the original position
      hemi_ag_relaxed_coords = ag_coords.row(ag);
      ag_coords.row(ag) = hemi_ag_orig_coords;

      // Check if the hemisphering point is in a new position
      bool equals_original_coords = arma::approx_equal(
        hemi_ag_orig_coords,
        hemi_ag_relaxed_coords,
        "absdiff",
        0.001
      );

      bool equals_previous_diagnosis = false;
      for (auto &diagnosis : hemi_diagnoses) {
        if (
          arma::approx_equal(
            diagnosis.coords,
            hemi_ag_relaxed_coords.as_col(),
            "absdiff",
            0.001
          )
        ) {
          equals_previous_diagnosis = true;
          break;
        }
      }

      // Add the record
      if (!equals_original_coords && !equals_previous_diagnosis) {

        // Set the diagnosis
        std::string diagnosis;
        if (stress_diff < -stress_lim) diagnosis = "trapped";
        else if ( stress_diff < 0)     diagnosis = "hemisphering-trapped";
        else                           diagnosis = "hemisphering";

        // Append a record of the coordinates
        hemi_diagnoses.push_back(
          HemiDiagnosis { diagnosis, hemi_ag_relaxed_coords.as_col() }
        );

      }

    }

    // Append the record of hemisphering coordinates
    if(hemi_diagnoses.size() > 0){
      HemiData hdata;
      hdata.diagnoses = hemi_diagnoses;
      hdata.index = ag;
      output.push_back( hdata );
    }

  }

  // Return the output
  return output;

}


// [[Rcpp::export]]
AcOptimization ac_hemi_test(
    AcOptimization optimization,
    AcTiterTable titertable,
    double grid_spacing,
    double stress_lim,
    AcOptimizerOptions options,
    double dilution_stepsize
){

  arma::mat tabledists = titertable.numeric_table_distances(
    optimization.get_min_column_basis(),
    optimization.get_fixed_column_bases(),
    optimization.get_ag_reactivity_adjustments()
  );
  arma::imat titertypes =titertable.get_titer_types();

  // Setup output
  arma::uword num_antigens = optimization.num_ags();
  arma::uword num_sera = optimization.num_sr();
  std::vector<HemiData> hemi_antigens(num_antigens);
  std::vector<HemiData> hemi_sera(num_sera);

  // Test antigens
  hemi_antigens = ac_hemi_test_points(
    optimization.get_ag_base_coords(),
    optimization.get_sr_base_coords(),
    tabledists,
    titertypes,
    grid_spacing,
    stress_lim,
    options,
    dilution_stepsize
  );

  // Test sera
  hemi_sera = ac_hemi_test_points(
    optimization.get_sr_base_coords(),
    optimization.get_ag_base_coords(),
    tabledists.t(),
    titertypes.t(),
    grid_spacing,
    stress_lim,
    options,
    dilution_stepsize
  );

  // Update optimization diagnostic info
  for (auto &hemidata : hemi_antigens) {
    optimization.ag_diagnostics[hemidata.index].hemi = hemidata.diagnoses;
  }
  for (auto &hemidata : hemi_sera) {
    optimization.sr_diagnostics[hemidata.index].hemi = hemidata.diagnoses;
  }
  return optimization;

}
