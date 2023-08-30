
#include <math.h>
#include <RcppArmadillo.h>
#include <RcppEnsmallen.h>

#ifdef _OPENMP
#include <omp.h>
#endif
// [[Rcpp::plugins(openmp)]]
// [[Rcpp::depends(RcppProgress)]]
// #include <Rcpp/Benchmark/Timer.h>

#include "utils.h"
#include "utils_error.h"
#include "utils_progress.h"
#include "acmap_map.h"
#include "ac_stress.h"
#include "ac_optim_map_stress.h"
#include "ac_optimization.h"
#include "ac_optimizer_options.h"
#include "acmap_optimization.h"
#include "acmap_titers.h"


// SETUP THE MAP OPTIMIZER CLASS
class MapOptimizer {

  public:

    // ATTRIBUTES
    arma::mat ag_coords;
    arma::mat sr_coords;
    arma::mat tabledist_matrix;
    arma::imat titertype_matrix;
    arma::mat mapdist_matrix;
    arma::uword num_dims;
    arma::uword num_ags;
    arma::uword num_sr;
    arma::uvec moveable_ags;
    arma::uvec moveable_sr;
    arma::uvec included_ags;
    arma::uvec included_srs;
    arma::uvec::iterator agi;
    arma::uvec::iterator agi_end;
    arma::uvec::iterator sri;
    arma::uvec::iterator sri_end;
    arma::mat titer_weights;
    arma::mat ag_gradients;
    arma::mat sr_gradients;
    double dilution_stepsize;
    double gradient;
    double stress;

    // CONSTRUCTOR FUNCTION
    // Constructor without fixed points provided
    MapOptimizer(
      arma::mat ag_start_coords,
      arma::mat sr_start_coords,
      arma::mat tabledist,
      arma::imat titertype,
      arma::uword dims,
      double dilution_stepsize
    )
      :ag_coords(ag_start_coords),
       sr_coords(sr_start_coords),
       tabledist_matrix(tabledist),
       titertype_matrix(titertype),
       num_dims(dims),
       num_ags(tabledist.n_rows),
       num_sr(tabledist.n_cols),
       dilution_stepsize(dilution_stepsize)
    {

      // Set default moveable antigens and sera to all
      moveable_ags = arma::regspace<arma::uvec>(0, num_ags - 1);
      moveable_sr = arma::regspace<arma::uvec>(0, num_sr - 1);

      // Set included antigens and sera
      included_ags = arma::find_finite(ag_start_coords.col(0));
      included_srs = arma::find_finite(sr_start_coords.col(0));
      agi_end = included_ags.end();
      sri_end = included_srs.end();

      // Set default weights to 1
      titer_weights.ones(num_ags, num_sr);

      // Setup map dist matrices
      mapdist_matrix = arma::mat(num_ags, num_sr, arma::fill::zeros);

      // Setup the gradient vectors
      ag_gradients.zeros(num_ags, num_dims);
      sr_gradients.zeros(num_sr, num_dims);

      // Update the map distance matrix according to coordinates
      update_map_dist_matrix();

    }

    // Constructor with fixed points provided
    MapOptimizer(
      arma::mat ag_start_coords,
      arma::mat sr_start_coords,
      arma::mat tabledist,
      arma::imat titertype,
      arma::uword dims,
      arma::uvec ag_fixed,
      arma::uvec sr_fixed,
      arma::mat titer_weights_in,
      double dilution_stepsize
    )
      :ag_coords(ag_start_coords),
       sr_coords(sr_start_coords),
       tabledist_matrix(tabledist),
       titertype_matrix(titertype),
       num_dims(dims),
       num_ags(tabledist.n_rows),
       num_sr(tabledist.n_cols),
       dilution_stepsize(dilution_stepsize)
      {

      // Set default weights to 1 if missing
      if (titer_weights_in.n_elem == 0) titer_weights.ones(num_ags, num_sr);
      else                              titer_weights = titer_weights_in;

      // Set moveable antigens
      moveable_ags = arma::find(ag_fixed == 0);
      moveable_sr = arma::find(sr_fixed == 0);

      // Set included antigens and sera
      included_ags = arma::find_finite(ag_start_coords.col(0));
      included_srs = arma::find_finite(sr_start_coords.col(0));
      agi_end = included_ags.end();
      sri_end = included_srs.end();

      // Setup map dist matrices
      mapdist_matrix = arma::mat(num_ags, num_sr, arma::fill::zeros);

      // Setup the gradient vectors
      ag_gradients.zeros(num_ags, num_dims);
      sr_gradients.zeros(num_sr, num_dims);

      // Update the map distance matrix according to coordinates
      update_map_dist_matrix();

    }

    // EVALUATE OBJECTIVE FUNCTION
    // This is needed for optimization methods that don't evaluate the gradient
    double Evaluate(
        const arma::mat &pars
    ){

      // Update coords from parameters
      update_map_coords(pars);

      // Update the distance matrix according to the new coords
      update_map_dist_matrix();

      // Calculate and return the stress
      return calculate_stress();

    }

    // EVALUATE OBJECTIVE FUNCTION AND UPDATE GRADIENT
    // This is needed for optimization methods that do evaluate the gradient
    double EvaluateWithGradient(
        const arma::mat &pars,
        arma::mat &grad
    ){

      // Update coords from parameters
      update_map_coords(pars);

      // Update the gradients and distance matrix according to the new coords
      update_map_dist_matrix();
      update_gradients();

      // Apply the gradients of moveable points to grad
      grad = arma::join_cols(
        ag_gradients.rows( moveable_ags ),
        sr_gradients.rows( moveable_sr )
      );

      // Calculate and return the stress
      return calculate_stress();

    }

    // CALCULATING STRESS GRADIENTS
    void update_gradients() {

      // Setup to update gradients
      ag_gradients.zeros();
      sr_gradients.zeros();

      // Now we cycle through each antigen and sera and calculate the gradient
      for(sri = included_srs.begin(); sri != sri_end; ++sri) {
        for(agi = included_ags.begin(); agi != agi_end; ++agi) {

          // Skip unmeasured titers
          if(titertype_matrix.at(*agi, *sri) <= 0){
            continue;
          }

          // Calculate inc_base
          double ibase = titer_weights.at(*agi,*sri) * inc_base(
            mapdist_matrix.at(*agi, *sri),
            tabledist_matrix.at(*agi, *sri),
            titertype_matrix.at(*agi, *sri),
            dilution_stepsize
          );

          // Now calculate the gradient for each coordinate
          for(arma::uword i = 0; i < num_dims; ++i) {
            gradient = ibase*(ag_coords.at(*agi, i) - sr_coords.at(*sri, i));
            ag_gradients.at(*agi, i) -= gradient;
            sr_gradients.at(*sri, i) += gradient;
          }

        }
      }

    }

    // CALCULATING MAP STRESS
    double calculate_stress(){

      // Set the start stress
      stress = 0;

      // Now we cycle through and sum up the stresses
      for(sri = included_srs.begin(); sri != sri_end; ++sri) {
        for(agi = included_ags.begin(); agi != agi_end; ++agi) {

          // Skip unmeasured titers
          if(titertype_matrix.at(*agi,*sri) <= 0){
            continue;
          }

          // Now calculate the stress
          stress += titer_weights.at(*agi,*sri) * ac_ptStress(
            mapdist_matrix.at(*agi,*sri),
            tabledist_matrix.at(*agi,*sri),
            titertype_matrix.at(*agi,*sri),
            dilution_stepsize
          );

        }
      }

      // Return the map stress
      return stress;

    }

    // UPDATE MAP COORDINATES FROM PARAMETERS
    void update_map_coords(
      const arma::mat &pars
    ){

      for(arma::uword j = 0; j < num_dims; ++j) {
        for(arma::uword i = 0; i < moveable_ags.n_elem; ++i) {
          ag_coords.at(moveable_ags(i),j) = pars.at(i, j);
        }
      }

      for(arma::uword j = 0; j < num_dims; ++j) {
        for(arma::uword i = 0; i < moveable_sr.n_elem; ++i) {
          sr_coords.at(moveable_sr(i),j) = pars.at(i + moveable_ags.n_elem, j);
        }
      }

    }

    // UPDATE THE MAP DISTANCE MATRIX
    void update_map_dist_matrix(){

      for(sri = included_srs.begin(); sri != sri_end; ++sri) {
        for(agi = included_ags.begin(); agi != agi_end; ++agi) {

          // Only calculate distances where ag and sr were titrated
          if(titertype_matrix.at(*agi,*sri) <= 0) continue;

          // Calculate the euclidean distance
          mapdist_matrix.at(*agi,*sri) = sqrt(arma::accu(arma::square(
            ag_coords.row(*agi) - sr_coords.row(*sri)
          )));

        }
      }

    }

};


// [[Rcpp::export]]
double ac_coords_stress(
    const AcTiterTable &titers,
    const std::string &min_colbasis,
    const arma::vec &fixed_colbases,
    const arma::vec &ag_reactivity_adjustments,
    arma::mat &ag_coords,
    arma::mat &sr_coords,
    double dilution_stepsize
){

  // Set variables
  int num_dims = ag_coords.n_cols;

  // Create the map object for the map optimizer
  MapOptimizer map(
      ag_coords,
      sr_coords,
      titers.numeric_table_distances(
        min_colbasis,
        fixed_colbases,
        ag_reactivity_adjustments
      ),
      titers.get_titer_types(),
      num_dims,
      dilution_stepsize
  );

  // Calculate and return the stress
  return map.calculate_stress();

}

// [[Rcpp::export]]
arma::mat ac_point_stresses(
    AcTiterTable titer_table,
    std::string min_colbasis,
    arma::vec fixed_colbases,
    arma::vec ag_reactivity_adjustments,
    arma::mat map_dists,
    double dilution_stepsize
){

  // Fetch variables
  arma::uword num_ags = map_dists.n_rows;
  arma::uword num_sr  = map_dists.n_cols;
  arma::mat numeric_table_dists = titer_table.numeric_table_distances(
    min_colbasis,
    fixed_colbases,
    ag_reactivity_adjustments
  );
  arma::imat titer_types = titer_table.get_titer_types();

  // Setup stress table
  arma::mat stress_table(num_ags, num_sr);

  // Populate stress table
  for (arma::uword ag = 0; ag < num_ags; ag++) {
    for (arma::uword sr = 0; sr < num_sr; sr++) {
      if (std::isnan(map_dists(ag, sr))) {
        stress_table(ag, sr) = arma::datum::nan;
      } else {
        stress_table(ag, sr) = ac_ptStress(
          map_dists(ag, sr),
          numeric_table_dists(ag, sr),
          titer_types(ag, sr),
          dilution_stepsize
        );
      }
    }
  }

  // Return the table
  return(stress_table);

}


// [[Rcpp::export]]
arma::mat ac_point_residuals(
    const AcMap &map,
    const arma::uword &optimization_number
  ){

  // Get parameters
  arma::uword num_ags = map.antigens.size();
  arma::uword num_sr  = map.sera.size();
  arma::mat numeric_table_dists = map.optimizations.at(optimization_number).numeric_table_distances(
    map.titer_table_flat
  );
  arma::imat titer_types = map.titer_table_flat.get_titer_types();
  arma::mat map_dists = map.optimizations.at(optimization_number).distance_matrix();
  double dilution_stepsize = map.dilution_stepsize;

  // Setup residual table
  arma::mat residual_table(num_ags, num_sr);

  // Populate residual table
  for (arma::uword ag = 0; ag < num_ags; ag++) {
    for (arma::uword sr = 0; sr < num_sr; sr++) {
      if (std::isnan(map_dists(ag, sr))) {
        residual_table(ag, sr) = arma::datum::nan;
      } else {
        residual_table(ag, sr) = ac_ptResidual(
          map_dists(ag, sr),
          numeric_table_dists(ag, sr),
          titer_types(ag, sr),
          dilution_stepsize
        );
      }
    }
  }

  // Return the table
  return(residual_table);

}


// [[Rcpp::export]]
double ac_relax_coords(
    const arma::mat &tabledist_matrix,
    const arma::imat &titertype_matrix,
    arma::mat &ag_coords,
    arma::mat &sr_coords,
    const AcOptimizerOptions &options,
    const arma::uvec &fixed_antigens,
    const arma::uvec &fixed_sera,
    const arma::mat &titer_weights,
    const double &dilution_stepsize
){

  // Do not move antigens and sera with NA coords
  arma::uvec ag_fixed(ag_coords.n_rows, arma::fill::zeros);
  arma::uvec sr_fixed(sr_coords.n_rows, arma::fill::zeros);
  ag_fixed.elem(fixed_antigens).ones();
  sr_fixed.elem(fixed_sera).ones();
  ag_fixed.elem(arma::find_nonfinite(ag_coords.col(0))).ones();
  sr_fixed.elem(arma::find_nonfinite(sr_coords.col(0))).ones();

  // Create the map object for the map optimizer
  MapOptimizer map(
    ag_coords,
    sr_coords,
    tabledist_matrix,
    titertype_matrix,
    ag_coords.n_cols,
    ag_fixed,
    sr_fixed,
    titer_weights,
    dilution_stepsize
  );

  // Create the vector of parameters
  arma::mat pars = arma::join_cols(
    ag_coords.rows(arma::find(ag_fixed == 0)),
    sr_coords.rows(arma::find(sr_fixed == 0))
  );

  // Setup the optimizer
  ens::L_BFGS lbfgs(
    options.num_basis,
    options.maxit,
    options.armijo_constant,
    options.wolfe,
    options.min_gradient_norm,
    options.factr,
    options.max_line_search_trials,
    options.min_step,
    options.max_step
  );

  // Perform the optimization
  lbfgs.Optimize(map, pars);

  // Return the result
  ag_coords = map.ag_coords;
  sr_coords = map.sr_coords;
  return map.calculate_stress();

}


// Generate a bunch of optimizations with randomized coordinates
// this is a starting point for later relaxation
std::vector<AcOptimization> ac_generateOptimizations(
    const arma::mat &tabledist_matrix,
    const arma::imat &titertype_matrix,
    const std::string &min_colbasis,
    const arma::vec &fixed_colbases,
    const arma::vec &ag_reactivity_adjustments,
    const int &num_dims,
    const int &num_optimizations,
    const AcOptimizerOptions &options,
    const double &dilution_stepsize
){

  // Infer number of antigens and sera
  int num_ags = tabledist_matrix.n_rows;
  int num_sr = tabledist_matrix.n_cols;

  // First run a rough optimization using max table dist as the box size
  AcOptimization initial_optim = AcOptimization(
    num_dims,
    num_ags,
    num_sr,
    min_colbasis,
    fixed_colbases,
    ag_reactivity_adjustments
  );

  initial_optim.randomizeCoords( tabledist_matrix.max() );
  initial_optim.relax_from_raw_matrices(
    tabledist_matrix,
    titertype_matrix,
    options,
    arma::uvec(),
    arma::uvec(),
    arma::mat(),
    dilution_stepsize
  );

  // Set boxsize based on initial optimization result
  arma::mat distmat = initial_optim.distance_matrix();
  double coord_maxdist = distmat.max();
  double coord_boxsize = coord_maxdist*2;

  // Create starting optimizations with random coordinates
  std::vector<AcOptimization> optimizations;
  for(int i=0; i<num_optimizations; i++){

    AcOptimization optimization(
        num_dims,
        num_ags,
        num_sr,
        min_colbasis,
        fixed_colbases,
        ag_reactivity_adjustments
    );

    optimization.randomizeCoords(coord_boxsize);
    optimizations.push_back(optimization);

  }

  // Return the randomized optimizations
  return optimizations;

}


// Relax the optimizations generated randomly
void ac_relaxOptimizations(
  std::vector<AcOptimization>& optimizations,
  arma::uword num_dims,
  const arma::mat &tabledist_matrix,
  const arma::imat &titertype_matrix,
  const AcOptimizerOptions &options,
  const arma::mat &titer_weights,
  const double &dilution_stepsize
){

  // Set variables
  int num_optimizations = optimizations.size();

  // Set progress bar
  if(options.report_progress) REprintf("Performing %d optimizations\n", num_optimizations);
  AcProgressBar pb(options.progress_bar_length, options.report_progress);
  Progress p(num_optimizations, true, pb);

  // Set dimensions to cycle through, for e.g. dimensional annealing
  arma::uvec dim_set { num_dims };
  if (options.dim_annealing) {
    dim_set.set_size(2);
    dim_set(0) = 5;
    dim_set(1) = num_dims;
  }

  // Run and return optimization results
  #pragma omp parallel for schedule(dynamic) num_threads(options.num_cores)
  for (int i=0; i<num_optimizations; i++) {

    // Run the optimization
    if (!p.check_abort()) {
      p.increment();

      // Now cycle "anneal" through the dimensions
      for (arma::uword j=0; j<dim_set.n_elem; j++) {

        // Relax the optimizations
        optimizations.at(i).relax_from_raw_matrices(
            tabledist_matrix,
            titertype_matrix,
            options,
            arma::uvec(), // Fixed ags
            arma::uvec(), // Fixed sr
            titer_weights,
            dilution_stepsize
        );

        // Reduce dimensions to next step if doing dimensional annealing
        if (dim_set(j) != num_dims) {
          optimizations.at(i).reduceDimensions(dim_set(j + 1));
        }

      }

    }

  }

  // Report finished
  if (p.is_aborted()) {
    ac_error("Optimization runs interrupted");
  } else {
    pb.complete("Optimization runs complete");
  }

}


// [[Rcpp::export]]
std::vector<AcOptimization> ac_runOptimizations(
    const AcTiterTable &titertable,
    const std::string &minimum_col_basis,
    const arma::vec &fixed_colbases,
    const arma::vec &ag_reactivity_adjustments,
    const arma::uword &num_dims,
    const arma::uword &num_optimizations,
    const AcOptimizerOptions &options,
    const arma::mat &titer_weights,
    const double &dilution_stepsize
){

  // Get table distance matrix and titer type matrix
  arma::mat tabledist_matrix = titertable.numeric_table_distances(
    minimum_col_basis,
    fixed_colbases,
    ag_reactivity_adjustments
  );
  arma::imat titertype_matrix = titertable.get_titer_types();

  // Determine the number of dimensions in which to initially randomise
  arma::uword start_dims;
  if (options.dim_annealing && num_dims < 5) {
    start_dims = 5;
  } else {
    start_dims = num_dims;
  }

  // Generate optimizations with random starting coords
  std::vector<AcOptimization> optimizations = ac_generateOptimizations(
    tabledist_matrix,
    titertype_matrix,
    minimum_col_basis,
    fixed_colbases,
    ag_reactivity_adjustments,
    start_dims,
    num_optimizations,
    options,
    dilution_stepsize
  );

  // Relax the optimizations
  ac_relaxOptimizations(
    optimizations,
    num_dims,
    tabledist_matrix,
    titertype_matrix,
    options,
    titer_weights,
    dilution_stepsize
  );

  // Sort the optimizations by stress
  sort_optimizations_by_stress(optimizations);

  // Realign optimizations to the first one
  align_optimizations(optimizations);

  // Return the optimizations
  return optimizations;

}


// //' @export
// // [[Rcpp::export]]
// Rcpp::NumericVector benchmark_relaxation(
//     const arma::mat &tabledist_matrix,
//     const arma::imat &titertype_matrix,
//     arma::mat ag_coords,
//     arma::mat sr_coords,
//     const std::string method = "L-BFGS-B",
//     const int maxit = 10000
// ){
//
//   // Set variables
//   int num_dims = ag_coords.n_cols;
//   int num_ags  = ag_coords.n_rows;
//   int num_sr   = sr_coords.n_rows;
//   int parnum;
//
//   // Create the map object for the map optimizer
//   MapOptimizer map(
//       ag_coords,
//       sr_coords,
//       tabledist_matrix,
//       titertype_matrix,
//       num_dims
//   );
//
//   // Create the vector of parameters
//   arma::vec pars = arma::vec(num_ags*num_dims + num_sr*num_dims);
//   parnum = 0;
//
//   for(int ag = 0; ag < num_ags; ag++){
//     for(int i = 0; i < num_dims; i++){
//       pars(parnum) = ag_coords(ag, i);
//       parnum++;
//     }
//   }
//
//   for(int sr = 0; sr < num_sr; sr++){
//     for(int i = 0; i < num_dims; i++){
//       pars(parnum) = sr_coords(sr, i);
//       parnum++;
//     }
//   }
//
//   // Perform benchmarking
//   return map.benchmark(pars);
//
// }
