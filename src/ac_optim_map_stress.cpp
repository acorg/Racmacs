
#include <math.h>
#include <RcppArmadillo.h>
#include <RcppEnsmallen.h>

#include <omp.h>
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
    arma::mat tabledist_matrix;
    arma::umat titertype_matrix;
    arma::mat mapdist_matrix;
    arma::mat ag_coords;
    arma::mat sr_coords;
    arma::uword num_dims;
    arma::uword num_ags;
    arma::uword num_sr;
    arma::uvec moveable_ags;
    arma::uvec moveable_sr;

    arma::mat gradients;
    double gradient;
    double stress;

    // CONSTRUCTOR FUNCTION
    // Without fixed points
    MapOptimizer(
      arma::mat ag_start_coords,
      arma::mat sr_start_coords,
      arma::mat tabledist,
      arma::umat titertype,
      arma::uword dims
    ){

      tabledist_matrix = tabledist;
      titertype_matrix = titertype;
      num_dims = dims;

      num_ags = tabledist_matrix.n_rows;
      num_sr = tabledist_matrix.n_cols;

      mapdist_matrix = arma::mat(num_ags, num_sr, arma::fill::zeros);
      ag_coords = ag_start_coords;
      sr_coords = sr_start_coords;

      moveable_ags = arma::regspace<arma::uvec>(0, num_ags - 1);
      moveable_sr = arma::regspace<arma::uvec>(0, num_sr - 1);

      gradients.zeros(num_ags + num_sr, num_dims);
      update_map_dist_matrix();

    }

    // With fixed points
    MapOptimizer(
      arma::mat ag_start_coords,
      arma::mat sr_start_coords,
      arma::mat tabledist,
      arma::umat titertype,
      arma::uword dims,
      arma::uvec moveable_ags_in,
      arma::uvec moveable_sr_in
    ){

      tabledist_matrix = tabledist;
      titertype_matrix = titertype;
      num_dims = dims;

      num_ags = tabledist_matrix.n_rows;
      num_sr = tabledist_matrix.n_cols;

      mapdist_matrix = arma::mat(num_ags, num_sr, arma::fill::zeros);
      ag_coords = ag_start_coords;
      sr_coords = sr_start_coords;

      moveable_ags = moveable_ags_in;
      moveable_sr = moveable_sr_in;

      gradients.zeros(num_ags + num_sr, num_dims);
      update_map_dist_matrix();

    }

    // EVALUATE OBJECTIVE FUNCTION
    // This is needed for optimization methods that don't evaluate the gradient
    double Evaluate(
        const arma::mat &pars,
        arma::mat &grad
    ){

      update_map_coords(pars);
      update_map_dist_matrix();
      return calculate_stress();

    }

    // EVALUATE OBJECTIVE FUNCTION AND UPDATE GRADIENT
    // This is needed for optimization methods that do evaluate the gradient
    double EvaluateWithGradient(
        const arma::mat &pars,
        arma::mat &grad
    ){

      // Update coords from parameters and the distance matrix
      update_map_coords(pars);
      update_map_dist_matrix();

      // Update the gradients
      update_gradients();

      // Apply the gradients of moveable points to grad
      if( moveable_ags.n_elem > 0 ){
        grad.rows(0, moveable_ags.n_elem - 1) = gradients.rows( moveable_ags );
      }
      if( moveable_sr.n_elem > 0 ){
        grad.rows(moveable_ags.n_elem, moveable_ags.n_elem + moveable_sr.n_elem - 1) = gradients.rows( moveable_sr + num_ags );
      }

      // Calculate and return the stress
      return calculate_stress();

    }

    // CALCULATING STRESS GRADIENTS
    void update_gradients(){

      // Setup to update gradients
      gradients.zeros();

      // Now we cycle through each antigen and sera and calculate the gradient
      for(arma::uword ag = 0; ag < num_ags; ++ag) {
        for(arma::uword sr = 0; sr < num_sr; ++sr) {

          // Skip unmeasured titers
          if(titertype_matrix(ag,sr) == 0){
            continue;
          }

          // Calculate inc_base
          double ibase = inc_base(
            mapdist_matrix(ag,sr),
            tabledist_matrix(ag,sr),
            titertype_matrix(ag,sr)
          );

          // Now calculate the gradient for each coordinate
          for(arma::uword i = 0; i < num_dims; ++i) {
            gradient = ibase*(ag_coords(ag,i) - sr_coords(sr,i));
            gradients(ag,i) -= gradient;
            gradients(sr + num_ags,i) += gradient;
          }

        }
      }

    }

    // CALCULATING MAP STRESS
    double calculate_stress(){

      // Set the start stress
      stress = 0;

      // Now we cycle through and sum up the stresses
      for(arma::uword ag = 0; ag < num_ags; ++ag) {
        for(arma::uword sr = 0; sr < num_sr; ++sr) {

          // Skip unmeasured titers
          if(titertype_matrix(ag,sr) == 0){
            continue;
          }

          // Now calculate the stress
          stress += ac_ptStress(
            mapdist_matrix(ag,sr),
            tabledist_matrix(ag,sr),
            titertype_matrix(ag,sr)
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

      for(arma::uword i = 0; i < moveable_ags.n_elem; ++i) {
        for(arma::uword j = 0; j < num_dims; ++j) {

          // Update the coordinates
          ag_coords(moveable_ags(i),j) = pars(i, j);

        }
      }

      for(arma::uword i = 0; i < moveable_sr.n_elem; ++i) {
        for(arma::uword j = 0; j < num_dims; ++j) {

          // Update the coordinates
          sr_coords(moveable_sr(i),j) = pars(i + moveable_ags.n_elem, j);

        }
      }

    }

    // UPDATE THE MAP DISTANCE MATRIX
    void update_map_dist_matrix(){

      for (arma::uword ag = 0; ag < num_ags; ag++) {
        for (arma::uword sr = 0; sr < num_sr; sr++) {

          // Only calculate distances where ag and sr were titrated
          if(titertype_matrix(ag,sr) != 0){

            // Calculate the euclidean distance
            double map_dist = 0;
            for(arma::uword i = 0; i < num_dims; ++i) {
              map_dist += pow(ag_coords(ag, i) - sr_coords(sr, i), 2);
            }
            mapdist_matrix(ag,sr) = sqrt(map_dist);

          }

        }
      }

    }

};


// [[Rcpp::export]]
double ac_coords_stress(
    const arma::mat &tabledist_matrix,
    const arma::umat &titertype_matrix,
    arma::mat &ag_coords,
    arma::mat &sr_coords
){

  // Set variables
  int num_dims = ag_coords.n_cols;

  // Create the map object for the map optimizer
  MapOptimizer map(
      ag_coords,
      sr_coords,
      tabledist_matrix,
      titertype_matrix,
      num_dims
  );

  // Calculate and return the stress
  return map.calculate_stress();

}


// [[Rcpp::export]]
double ac_relax_coords(
    const arma::mat &tabledist_matrix,
    const arma::umat &titertype_matrix,
    arma::mat &ag_coords,
    arma::mat &sr_coords,
    const AcOptimizerOptions &options,
    const arma::uvec &fixed_antigens,
    const arma::uvec &fixed_sera
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
    moveable_sera
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

};


// Generate a bunch of optimizations with randomized coordinates
// this is a starting point for later relaxation
std::vector<AcOptimization> ac_generateOptimizations(
    const arma::vec &colbases,
    const arma::mat &tabledist_matrix,
    const arma::umat &titertype_matrix,
    const int &num_dims,
    const int &num_optimizations,
    const AcOptimizerOptions &options
){

  // Infer number of antigens and sera
  int num_ags = tabledist_matrix.n_rows;
  int num_sr = tabledist_matrix.n_cols;

  // First run a rough optimization using max table dist as the box size
  AcOptimization initial_optim = AcOptimization(
    num_dims,
    num_ags,
    num_sr
  );

  initial_optim.randomizeCoords( tabledist_matrix.max() );
  initial_optim.relax_from_raw_matrices(
    tabledist_matrix,
    titertype_matrix,
    options
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
        num_sr
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
  const arma::vec &colbases,
  const arma::mat &tabledist_matrix,
  const arma::umat &titertype_matrix,
  const AcOptimizerOptions &options
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
          options
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
    const arma::vec &colbases,
    const int &num_dims,
    const int &num_optimizations,
    const AcOptimizerOptions &options
){

  // Get table distance matrix and titer type matrix
  arma::mat tabledist_matrix = titertable.table_distances(colbases);
  arma::umat titertype_matrix = titertable.get_titer_types();

  // Generate optimizations with random starting coords
  std::vector<AcOptimization> optimizations = ac_generateOptimizations(
    colbases,
    tabledist_matrix,
    titertype_matrix,
    num_dims,
    num_optimizations,
    options
  );

  // Relax the optimizations
  ac_relaxOptimizations(
    optimizations,
    colbases,
    tabledist_matrix,
    titertype_matrix,
    options
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
//     const arma::umat &titertype_matrix,
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
