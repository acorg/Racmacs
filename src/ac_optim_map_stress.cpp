
#include <math.h>
#include <RcppArmadillo.h>
#include <RcppEnsmallen.h>

#ifdef _OPENMP
#include <omp.h>
#endif
// [[Rcpp::plugins(openmp)]]
// #include <Rcpp/Benchmark/Timer.h>

#include "utils.h"
#include "utils_progress.h"
#include "ac_stress.h"
#include "ac_optim_map_stress.h"
#include "ac_optimization.h"
#include "ac_optimizer_options.h"
#include "acmap_optimization.h"
#include "acmap_titers.h"
#include "acmap_optimization.h"


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
      arma::uvec moveable_ags,
      arma::uvec moveable_sr,
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
       moveable_ags(moveable_ags),
       moveable_sr(moveable_sr),
       dilution_stepsize(dilution_stepsize)
      {

      // Set default weights to 1 if missing
      if (titer_weights_in.n_elem == 0) titer_weights.ones(num_ags, num_sr);
      else                              titer_weights = titer_weights_in;

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
      for(arma::uword sr = 0; sr < num_sr; ++sr) {
        for(arma::uword ag = 0; ag < num_ags; ++ag) {

          // Skip unmeasured titers
          if(titertype_matrix.at(ag, sr) <= 0){
            continue;
          }

          // Calculate inc_base
          double ibase = titer_weights.at(ag,sr) * inc_base(
            mapdist_matrix.at(ag, sr),
            tabledist_matrix.at(ag, sr),
            titertype_matrix.at(ag, sr),
            dilution_stepsize
          );

          // Now calculate the gradient for each coordinate
          for(arma::uword i = 0; i < num_dims; ++i) {
            gradient = ibase*(ag_coords.at(ag, i) - sr_coords.at(sr, i));
            ag_gradients.at(ag, i) -= gradient;
            sr_gradients.at(sr, i) += gradient;
          }

        }
      }

    }

    // CALCULATING MAP STRESS
    double calculate_stress(){

      // Set the start stress
      stress = 0;

      // Now we cycle through and sum up the stresses
      for(arma::uword sr = 0; sr < num_sr; ++sr) {
        for(arma::uword ag = 0; ag < num_ags; ++ag) {

          // Skip unmeasured titers
          if(titertype_matrix.at(ag,sr) <= 0){
            continue;
          }

          // Now calculate the stress
          stress += titer_weights.at(ag,sr) * ac_ptStress(
            mapdist_matrix.at(ag,sr),
            tabledist_matrix.at(ag,sr),
            titertype_matrix.at(ag,sr),
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

      for (arma::uword sr = 0; sr < num_sr; sr++) {
        for (arma::uword ag = 0; ag < num_ags; ag++) {

          // Only calculate distances where ag and sr were titrated
          if(titertype_matrix.at(ag,sr) <= 0) continue;

          // Calculate the euclidean distance
          mapdist_matrix.at(ag,sr) = sqrt(arma::accu(arma::square(
            ag_coords.row(ag) - sr_coords.row(sr)
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

  // Setup residual table
  arma::mat stress_table(num_ags, num_sr);

  // Populate residual table
  for (arma::uword ag = 0; ag < num_ags; ag++) {
    for (arma::uword sr = 0; sr < num_sr; sr++) {
      stress_table(ag, sr) = ac_ptStress(
        map_dists(ag, sr),
        numeric_table_dists(ag, sr),
        titer_types(ag, sr),
        dilution_stepsize
      );
    }
  }

  // Return the table
  return(stress_table);

}


// [[Rcpp::export]]
arma::mat ac_point_residuals(
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

  // Setup residual table
  arma::mat residual_table(num_ags, num_sr);

  // Populate residual table
  for (arma::uword ag = 0; ag < num_ags; ag++) {
    for (arma::uword sr = 0; sr < num_sr; sr++) {
      residual_table(ag, sr) = ac_ptResidual(
        map_dists(ag, sr),
        numeric_table_dists(ag, sr),
        titer_types(ag, sr),
        dilution_stepsize
      );
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

  // Set variables
  arma::uword num_dims = ag_coords.n_cols;
  arma::uvec moveable_antigens = arma::regspace<arma::uvec>(0, ag_coords.n_rows - 1);
  arma::uvec moveable_sera = arma::regspace<arma::uvec>(0, sr_coords.n_rows - 1);
  moveable_antigens.shed_rows(fixed_antigens);
  moveable_sera.shed_rows(fixed_sera);

  // Create the map object for the map optimizer
  MapOptimizer map(
    ag_coords,
    sr_coords,
    tabledist_matrix,
    titertype_matrix,
    num_dims,
    moveable_antigens,
    moveable_sera,
    titer_weights,
    dilution_stepsize
  );

  // Create the vector of parameters
  arma::mat pars = arma::join_cols(
    ag_coords.rows(moveable_antigens),
    sr_coords.rows(moveable_sera)
  );

  // Perform the optimization
  ens::L_BFGS lbfgs;
  lbfgs.MaxIterations() = options.maxit;
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

  // Run and return optimization results
  #pragma omp parallel for schedule(dynamic)
  for(int i=0; i<num_optimizations; i++){

    // Run the optimization
    if( !p.check_abort() ){
      p.increment();
      optimizations[i].relax_from_raw_matrices(
          tabledist_matrix,
          titertype_matrix,
          options,
          arma::uvec(), // Fixed ags
          arma::uvec(), // Fixed sr
          titer_weights,
          dilution_stepsize
      );
    }

  }

  // Report finished
  if( p.is_aborted() ){
    pb.complete("Optimization runs interrupted", false);
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

  // Set dimensions to cycle through, for e.g. dimensional annealing
  arma::uvec dim_set { num_dims };

  if (options.dim_annealing && num_dims < 5) {
    dim_set.set_size(2);
    dim_set(0) = 5;
    dim_set(1) = num_dims;
  }

  // Generate optimizations with random starting coords
  std::vector<AcOptimization> optimizations = ac_generateOptimizations(
    tabledist_matrix,
    titertype_matrix,
    minimum_col_basis,
    fixed_colbases,
    ag_reactivity_adjustments,
    dim_set(0),
    num_optimizations,
    options,
    dilution_stepsize
  );

  // Now cycle "anneal" through the dimensions
  for (arma::uword i=0; i<dim_set.n_elem; i++) {

    // Relax the optimizations
    ac_relaxOptimizations(
      optimizations,
      tabledist_matrix,
      titertype_matrix,
      options,
      titer_weights,
      dilution_stepsize
    );

    // Reduce dimensions to next step if doing dimensional annealing
    if (i + 1 < dim_set.n_elem) {
      for(auto &optimization : optimizations){
        optimization.reduceDimensions(dim_set(i + 1));
      }
    }

  }

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
