
#include <RcppArmadillo.h>

#ifdef _OPENMP
#include <omp.h>
#endif
// [[Rcpp::plugins(openmp)]]

#include "acmap_optimization.h"
#include "ac_stress_blobs.h"
#include "ac_optimizer_options.h"

// Check for trapped antigens
arma::mat check_ag_trapped_points(
    const AcOptimization &optimization,
    const arma::mat &tabledists,
    const arma::imat &titertypes,
    const double &grid_spacing,
    AcOptimizerOptions options
){

  // Variables
  double stress_lim = 0;
  int num_ags = optimization.num_ags();
  arma::mat ag_coords = optimization.get_ag_base_coords();
  arma::mat sr_coords = optimization.get_sr_base_coords();

  arma::mat trapped_ag_improved_coords(arma::size(ag_coords));
  trapped_ag_improved_coords.fill(arma::datum::nan);

  // Check trapped antigens
  #pragma omp parallel for schedule(dynamic) num_threads(options.num_cores)
  for(int ag=0; ag<num_ags; ag++){

    // Do a grid search
    StressBlobGrid grid_results = ac_stress_blob_grid(
      ag_coords.row(ag).as_col(),
      sr_coords,
      tabledists.row(ag).as_col(),
      titertypes.row(ag).as_col(),
      stress_lim,
      grid_spacing
    );

    // Check if any grid points have lower stress than the minimum
    if(grid_results.grid.min() < 0.0){
      arma::uword index = grid_results.grid.index_min();
      arma::uvec sub = arma::ind2sub( arma::size(grid_results.grid), index );
      trapped_ag_improved_coords(ag,0) = grid_results.xcoords( sub(0) );
      trapped_ag_improved_coords(ag,1) = grid_results.ycoords( sub(1) );
    }

  }

  // Return trapped point information
  return trapped_ag_improved_coords;

}


// Check for trapped sera
arma::mat check_sr_trapped_points(
    const AcOptimization &optimization,
    const arma::mat &tabledists,
    const arma::imat &titertypes,
    const double &grid_spacing,
    AcOptimizerOptions options
){

  // Variables
  double stress_lim = 0;
  int num_sr = optimization.num_sr();
  arma::mat ag_coords = optimization.get_ag_base_coords();
  arma::mat sr_coords = optimization.get_sr_base_coords();

  arma::mat trapped_sr_improved_coords(arma::size(sr_coords));
  trapped_sr_improved_coords.fill(arma::datum::nan);

  // Check trapped sera
  #pragma omp parallel for schedule(dynamic) num_threads(options.num_cores)
  for(int sr=0; sr<num_sr; sr++){

    // Do a grid search
    StressBlobGrid grid_results = ac_stress_blob_grid(
      sr_coords.row(sr).as_col(),
      ag_coords,
      tabledists.col(sr),
      titertypes.col(sr),
      stress_lim,
      grid_spacing
    );

    // Check if any grid points have lower stress than the minimum
    if(grid_results.grid.min() < 0.0){
      arma::uword index = grid_results.grid.index_min();
      arma::uvec sub = arma::ind2sub( arma::size(grid_results.grid), index );
      trapped_sr_improved_coords(sr,0) = grid_results.xcoords( sub(0) );
      trapped_sr_improved_coords(sr,1) = grid_results.ycoords( sub(1) );
    }

  }

  // Return trapped point information
  return trapped_sr_improved_coords;

}


// Function to find and move trapped coordinates
// [[Rcpp::export]]
AcOptimization ac_move_trapped_points(
  AcOptimization optimization,
  AcTiterTable titertable,
  double grid_spacing,
  AcOptimizerOptions options,
  int max_iterations = 10,
  double dilution_stepsize = 1.0
){


  // Check antigen and sera trapped points recursively
  if(options.report_progress) REprintf("Checking for trapped points recursively:");

  arma::imat titertypes = titertable.get_titer_types();
  arma::mat tabledists = titertable.numeric_table_distances(
    optimization.get_min_column_basis(),
    optimization.get_fixed_column_bases(),
    optimization.get_ag_reactivity_adjustments()
  );

  int num_iterations = 0;
  while(num_iterations < max_iterations){

    // Variables
    arma::mat ag_coords = optimization.get_ag_base_coords();
    arma::mat sr_coords = optimization.get_sr_base_coords();

    // Check for any improved coordinates
    arma::mat ag_trapped_improved_coords = check_ag_trapped_points(optimization, tabledists, titertypes, grid_spacing, options);
    arma::mat sr_trapped_improved_coords = check_sr_trapped_points(optimization, tabledists, titertypes, grid_spacing, options);

    // Get any improved indices
    arma::uvec ag_trapped_coord_indices = arma::find_finite(ag_trapped_improved_coords);
    arma::uvec sr_trapped_coord_indices = arma::find_finite(sr_trapped_improved_coords);

    // Break if no improvements found
    if((ag_trapped_coord_indices.n_elem == 0) && (sr_trapped_coord_indices.n_elem == 0)){
      break;
    }

    // Move antigen and serum coordinates to improved positions
    ag_coords.elem(ag_trapped_coord_indices) = ag_trapped_improved_coords.elem(ag_trapped_coord_indices);
    sr_coords.elem(sr_trapped_coord_indices) = sr_trapped_improved_coords.elem(sr_trapped_coord_indices);

    optimization.set_ag_base_coords(ag_coords);
    optimization.set_sr_base_coords(sr_coords);

    // Relax the optimization
    optimization.relax_from_raw_matrices(
      tabledists,
      titertypes,
      options,
      arma::uvec(),
      arma::uvec(),
      arma::mat(),
      dilution_stepsize
    );

    // Increment loop num
    if(options.report_progress) REprintf(".");
    num_iterations++;

  }

  // Output message indicating if some were found
  if(options.report_progress){
    if(num_iterations == 0){
      REprintf(" no trapped points found.\n");
    } else if(num_iterations == max_iterations){
      REprintf(" maximum iteration number reached.\n");
    } else {
      REprintf(" all trapped points moved.\n");
    }
  }

  // Return the improved optimization
  return optimization;

}

